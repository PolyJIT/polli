//===-- libpjit.cpp - PolyJIT Just in Time Compiler -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2014 Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
//
// This tool implements a just-in-time compiler for LLVM, allowing direct
// execution of LLVM bitcode in an efficient manner.
//
//===----------------------------------------------------------------------===//
#include <likwid.h>

#include <atomic>
#include <condition_variable>
#include <cstdlib>
#include <deque>
#include <memory>
#include <stdlib.h>
#include <thread>
#include <unordered_map>
#include <vector>

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/RuntimeDyld.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/IR/Mangler.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/DynamicLibrary.h"

#include "polli/Caching.h"
#include "polli/Compiler.h"
#include "polli/Jit.h"
#include "polli/Options.h"
#include "polli/RunValues.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/RuntimeValues.h"
#include "polli/Stats.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"
#include "polli/log.h"
#include "polly/RegisterPasses.h"
#include "pprof/Tracing.h"

#define DEBUG_TYPE "polyjit"

REGISTER_LOG(console, "libpjit");

using namespace llvm;
using namespace polli;

namespace polli {
static ManagedStatic<PolyJITEngine> Compiler;
static ManagedStatic<PolyJIT> JitContext;

/**
 * @brief Get the protoype function stored in this module.
 *
 * This assumes that it operates on a prototype module of PolyJIT. Such
 * a module contains at most one function with the 'polyjit-jit-candidate'
 * attribute.
 *
 * @param M The prototype module.
 * @return llvm::Function* The first function in the given module.
 */
static Function &getFunction(Module &M) {
  for (Function &F : M) {
    if (F.hasFnAttribute("polyjit-jit-candidate")) {
      SPDLOG_DEBUG(console, "fn-jit-candidate: {:s}", F.getName().str());
      return F;
    }
  }

  errs() << "No JIT candidate in prototype!\n";
  llvm_unreachable("No JIT candidate found in prototype!");
}

static inline Function &getPrototype(const char *function, bool &cache_hit) {
  POLLI_TRACING_REGION_START(PJIT_REGION_GET_PROTOTYPE,
                             "polyjit.prototype.get");
  Module &M = Compiler->getModule(function, cache_hit);
  Function &F = getFunction(M);
  POLLI_TRACING_REGION_STOP(PJIT_REGION_GET_PROTOTYPE, "polyjit.prototype.get");
  return F;
}

using MainFnT = std::function<void(int, char **)>;

static std::pair<CacheKey, bool> GetCacheKey(SpecializerRequest &Request) {
  bool cache_hit;
  Request.F = &getPrototype(Request.IR, cache_hit);
  RunValueList Values = runValues(Request);
  return std::make_pair(CacheKey(Request.IR, Values.hash()), cache_hit);
}

static void
GetOrCreateVariantFunction(std::shared_ptr<SpecializerRequest> Request,
                           CacheKey K, uint64_t prefix) {
  if (JitContext->find(K) != JitContext->end()) {
    JitContext->increment(JitRegion::CACHE_HIT, 0);
    return;
  }

  JitContext->increment(JitRegion::VARIANTS, 1);

  POLLI_TRACING_REGION_START(PJIT_REGION_CODEGEN, "polyjit.codegen");

  VariantFunctionTy VarFun = JitContext->getOrCreateVariantFunction(Request->F);
  RunValueList Values = runValues(*Request);
  std::string FnName;

  auto Variant = VarFun->createVariant(Values, FnName);
  assert(Variant && "Failed to get a new variant.");

  auto status = Compiler->addModule(std::move(Variant));
  console->error_if((bool)status, "Adding the module failed!");
  assert((bool)status && "Adding the module failed!");

  llvm::JITSymbol FPtr = Compiler->findSymbol(FnName);
  auto Addr = FPtr.getAddress();
  console->error_if((bool)Addr, "Could not get the address of the JITSymbol.");
  assert((bool)Addr && "Could not get the address of the JITSymbol.");

  bool inserted =
      JitContext
          ->insert(std::make_pair(K, MainFnT((void (*)(int, char **))(*Addr))))
          .second;
  if (!inserted) {
    console->critical("Key collision in function cache, abort.");
    llvm_unreachable("Key collision in function cace, abort.");
  }
  DEBUG(printRunValues(Values));
  POLLI_TRACING_REGION_STOP(PJIT_REGION_CODEGEN, "polyjit.codegen");
}

extern "C" {
void pjit_trace_fnstats_entry(uint64_t *prefix, bool is_variant) {
  const Function *F = JitContext->FromPrefix((uint64_t)prefix);
  JitContext->enter(GetCandidateId(*F), papi::PAPI_get_real_usec());
}

void pjit_trace_fnstats_exit(uint64_t *prefix, bool is_variant) {
  const Function *F = JitContext->FromPrefix((uint64_t)prefix);
  JitContext->exit(GetCandidateId(*F), papi::PAPI_get_real_usec());
}

void pjit_library_init();

/**
 * @brief Runtime callback for PolyJIT.
 *
 * All calls to the PolyJIT runtime will land here.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
bool pjit_main(const char *fName, uint64_t *prefix, unsigned paramc,
               char **params) {
  auto Request = std::make_shared<SpecializerRequest>(fName, paramc, params);
  JitContext->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  llvm::Function *F = Request->F;

  if (!K.second) {
    JitContext->UpdatePrefixMap((uint64_t)prefix, F);
    JitContext->addRegion(Request->F->getName().str(),
                       GetCandidateId(*Request->F));
  }

  CacheKey Key = K.first;
  auto FutureFn = JitContext->async(GetOrCreateVariantFunction, Request, Key,
                                    (uint64_t)prefix);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!K.second)
    FutureFn.wait();
  JitContext->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  auto FnIt = JitContext->find(Key);
  if (FnIt != JitContext->end()) {
    pjit_trace_fnstats_entry(prefix, true);
    (FnIt->second)(paramc, params);
    pjit_trace_fnstats_exit(prefix, true);
    return true;
  }

  return false;
}

/**
 * @brief Runtime callback for PolyJIT.
 *
 * This entry-point will just return false and invoke the non-optimized
 * version of the scop we want to jit.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
bool pjit_main_no_recompile(const char *fName, uint64_t *prefix,
                            unsigned paramc, char **params) {
  auto Request = std::make_shared<SpecializerRequest>(fName, paramc, params);
  JitContext->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());
  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  if (!K.second) {
    llvm::Function *F = Request->F;
    JitContext->UpdatePrefixMap((uint64_t)prefix, F);
    JitContext->addRegion(Request->F->getName().str(),
                       GetCandidateId(*Request->F));
  }
  JitContext->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());
  return false;
}
} /* extern "C" */

static llvm_shutdown_obj StaticDestructor;
} /* polli */
