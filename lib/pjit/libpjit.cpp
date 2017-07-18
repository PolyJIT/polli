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
#include "llvm/ExecutionEngine/RuntimeDyld.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/Mangler.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/CommandLine.h"
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

namespace {
using UniqueMod = std::shared_ptr<Module>;
using UniqueCtx = std::shared_ptr<LLVMContext>;

using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;
static StackTracePtr StackTrace;

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

static inline void set_options_from_environment() {
  cl::ParseEnvironmentOptions("libpjit", "PJIT_ARGS", "");
}

} // end of anonymous namespace

namespace polli {
/// @brief Simple compile functor: Takes a single IR module and returns an
///        ObjectFile.
class PolySectionMemoryManager : public SectionMemoryManager {
  uint8_t *allocateCodeSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID,
                               StringRef SectionName) override {
    uint8_t *ptr = SectionMemoryManager::allocateCodeSection(
        Size, Alignment, SectionID, SectionName);
    SPDLOG_DEBUG(
        console, "cs @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str());
    return ptr;
  }

  uint8_t *allocateDataSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID, StringRef SectionName,
                               bool isReadOnly) override {
    uint8_t *ptr = SectionMemoryManager::allocateDataSection(
        Size, Alignment, SectionID, SectionName, isReadOnly);
    SPDLOG_DEBUG(console,
        "ds @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s} ro: {:d}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str(),
        isReadOnly);
    return ptr;
  }
};

static PolyJITEngine &getOrCreateEngine() {
  static PolyJITEngine EE;
  return EE;
}
}

static inline Function &getPrototype(const char *function, bool &cache_hit) {
  POLLI_TRACING_REGION_START(PJIT_REGION_GET_PROTOTYPE,
                             "polyjit.prototype.get");
  Module &M = getOrCreateEngine().getModule(function, cache_hit);
  Function &F = getFunction(M);
  POLLI_TRACING_REGION_STOP(PJIT_REGION_GET_PROTOTYPE, "polyjit.prototype.get");
  return F;
}

namespace polli {
using JitT = std::shared_ptr<PolyJIT>;
static JitT &getOrCreateJIT() {
  static auto JIT = std::make_shared<PolyJIT>();
  return JIT;
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
                           CacheKey K, uint64_t prefix, JitT Context) {
  if (Context->find(K) != Context->end()) {
    /* CACHE_HIT */
    Context->enter(3, 0);
    Context->exit(3, 1);
    return;
  }

  /* VARIANTS */
  Context->enter(2, 0);
  Context->exit(2, 1);

  SPDLOG_DEBUG(console, "{:s}: Create new Variant.",
               Request->F->getName().str());
  SPDLOG_DEBUG(console, "Hash: {:x} IR: {:x}", K.ValueHash, (uint64_t)K.IR);
  POLLI_TRACING_REGION_START(PJIT_REGION_CODEGEN, "polyjit.codegen");

  VariantFunctionTy VarFun = Context->getOrCreateVariantFunction(Request->F);
  RunValueList Values = runValues(*Request);
  std::string FnName;

  auto Variant = VarFun->createVariant(Values, FnName);
  assert(Variant && "Failed to get a new variant.");

  PolyJITEngine &EE = getOrCreateEngine();
  auto status = EE.addModule(std::move(Variant));
  console->error_if((bool)status, "Adding the module failed!");
  assert((bool)status && "Adding the module failed!");

  DEBUG(printRunValues(Values));

  llvm::JITSymbol FPtr = EE.findSymbol(FnName);
  Expected<JITTargetAddress> Addr = FPtr.getAddress();

  SPDLOG_DEBUG(console, "fn ptr: 0x{:x}", *Addr);
  assert(FPtr && "Specializer returned nullptr.");
  if (!Context
           ->insert(std::make_pair(
               K, MainFnT((void (*)(int, char **))(*Addr))))
           .second) {
    console->critical("Key collision in function cache, abort.");
    llvm_unreachable("Key collision");
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_CODEGEN, "polyjit.codegen");
}

namespace {
class StaticInitializer {
public:
  StaticInitializer() {
    using polly::initializePollyPasses;

    set_options_from_environment();

    StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

    // Make sure to initialize tracing before planting the atexit handler.
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    polly::initializePollyPasses(Registry);
    initializeCore(Registry);
    initializeScalarOpts(Registry);
    initializeVectorization(Registry);
    initializeIPO(Registry);
    initializeAnalysis(Registry);
    initializeTransformUtils(Registry);
    initializeInstCombine(Registry);
    initializeInstrumentation(Registry);
    initializeTarget(Registry);
    initializeCodeGenPreparePass(Registry);
    initializeAtomicExpandPass(Registry);

    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();
    InitializeNativeTargetAsmParser();

    getOrCreateEngine();
    getOrCreateJIT();
  }

  ~StaticInitializer() {}
};
}

extern "C" {
void pjit_trace_fnstats_entry(uint64_t *prefix, bool is_variant) {
  JitT Context = getOrCreateJIT();
  const Function *F = Context->FromPrefix((uint64_t)prefix);
  Context->enter(GetCandidateId(*F), papi::PAPI_get_real_usec());
}

void pjit_trace_fnstats_exit(uint64_t *prefix, bool is_variant) {
  JitT Context = getOrCreateJIT();
  const Function *F = Context->FromPrefix((uint64_t)prefix);
  Context->exit(GetCandidateId(*F), papi::PAPI_get_real_usec());
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
  JitT Context = getOrCreateJIT();
  Context->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  llvm::Function *F = Request->F;

  if (!K.second) {
    Context->UpdatePrefixMap((uint64_t)prefix, F);
    Context->addRegion(Request->F->getName().str(),
                       GetCandidateId(*Request->F));
  }

  CacheKey Key = K.first;
  auto FutureFn = Context->async(GetOrCreateVariantFunction, Request, Key,
                                 (uint64_t)prefix, Context);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!K.second)
    FutureFn.wait();
  Context->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());

  auto FnIt = Context->find(Key);
  if (FnIt != Context->end()) {
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
  JitT Context = getOrCreateJIT();
  Context->enter(JitRegion::CODEGEN, papi::PAPI_get_real_usec());
  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  if (!K.second) {
    llvm::Function *F = Request->F;
    Context->UpdatePrefixMap((uint64_t)prefix, F);
    Context->addRegion(Request->F->getName().str(),
                       GetCandidateId(*Request->F));
  }
  Context->exit(JitRegion::CODEGEN, papi::PAPI_get_real_usec());
  return false;
}

void pjit_library_init() {
  static bool initialized = false;
  if (initialized)
    return;
  static StaticInitializer InitializeEverything;
  // atexit(do_shutdown);
  initialized = true;
}
} /* extern "C" */
} /* polli */
