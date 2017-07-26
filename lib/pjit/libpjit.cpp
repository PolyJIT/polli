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

using namespace llvm;
using namespace polli;

REGISTER_LOG(console, DEBUG_TYPE);

static ManagedStatic<PolyJIT> JitContext;
static ManagedStatic<SpecializingCompiler> Compiler;

namespace polli {
using MainFnT = std::function<void(int, char **)>;

static void DoCreateVariant(std::shared_ptr<SpecializerRequest> Request,
                            CacheKey K) {
  JitContext->increment(JitRegion::VARIANTS, 1);

  Function &Prototype = Request->prototype();
  RunValueList Values = runValues(*Request);
  std::string FnName;

  auto Variant = createVariant(Prototype, Values, FnName);
  assert(Variant && "Failed to get a new variant.");
  auto MaybeModule = Compiler->addModule(std::move(Variant));

  console->error_if(!(bool)MaybeModule, "Adding the module failed!");
  assert((bool)MaybeModule && "Adding the module failed!");

  Module &PM = Request->prototypeModule();
  llvm::JITSymbol FPtr = Compiler->findSymbol(FnName, PM.getDataLayout());
  auto Addr = FPtr.getAddress();
  console->error_if(!(bool)Addr, "Could not get the address of the JITSymbol.");
  assert((bool)Addr && "Could not get the address of the JITSymbol.");

  auto &Cache = JitContext->cache();
  auto CacheIt = Cache.insert(std::make_pair(K, std::move(FPtr)));
  if (!CacheIt.second) {
    console->critical("Key collision in function cache, abort.");
    llvm_unreachable("Key collision in function cace, abort.");
  }
  printRunValues(Values);
}

static void
GetOrCreateVariantFunction(std::shared_ptr<SpecializerRequest> Request,
                           CacheKey K) {
  auto &Cache = JitContext->cache();
  if (Cache.find(K) != Cache.end()) {
    JitContext->increment(JitRegion::CACHE_HIT, 0);
    return;
  }

  JitContext->increment(JitRegion::VARIANTS, 1);
  auto Ctx = Compiler->getContext(Request->key());
  Ctx->RunInCS(DoCreateVariant, Request, K);
}

extern "C" {
void pjit_trace_fnstats_entry(uint64_t Id) {
  JitContext->enter(Id, papi::PAPI_get_real_usec());
  console->info("Starting execution of {:d}", Id);
}

void pjit_trace_fnstats_exit(uint64_t Id) {
  JitContext->exit(Id, papi::PAPI_get_real_usec());
  console->info("Finished execution of {:d}", Id);
}

/**
 * @brief Runtime callback for PolyJIT.
 *
 * All calls to the PolyJIT runtime will land here.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
void *pjit_main(const char *fName, void *ptr, uint64_t ID,
                unsigned paramc, char **params) {

  bool CacheHit;
  auto M = Compiler->getModule(fName, CacheHit);
  auto Request =
      std::make_shared<SpecializerRequest>((uint64_t)fName, paramc, params, M);
  JitContext->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  RunValueList Values = runValues(*Request);
  llvm::Function &F = Request->prototype();

  if (!CacheHit)
    JitContext->addRegion(F.getName().str(), ID);

  CacheKey K{Request->key(), Values.hash()};
  auto FutureFn = JitContext->async(GetOrCreateVariantFunction, Request, K);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!CacheHit)
    FutureFn.wait();
  JitContext->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  auto &Cache = JitContext->cache();
  auto FnIt = Cache.find(K);
  if (FnIt != Cache.end()) {
    auto &Symbol = FnIt->second;
    auto Addr = Symbol.getAddress();
    if (Addr)
      return (void *)*Addr;
  }
  return ptr;
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
bool pjit_main_no_recompile(const char *fName, void *ptr, uint64_t ID,
                            unsigned paramc, char **params) {
  bool CacheHit;
  auto M = Compiler->getModule(fName, CacheHit);
  auto Request =
      std::make_shared<SpecializerRequest>((uint64_t)fName, paramc, params, M);
  JitContext->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  if (!CacheHit) {
    llvm::Function &F = Request->prototype();
    JitContext->addRegion(F.getName().str(), ID);
  }
  JitContext->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());
  return ptr;
}
} /* extern "C" */

struct PolliShutdown {
  ~PolliShutdown() {
    JitContext->wait();
  }
private:
  llvm_shutdown_obj Shutdown;
};

static PolliShutdown Cleanup;
} /* polli */
