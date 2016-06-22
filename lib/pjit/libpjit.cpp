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

#include <stdlib.h>
#include <pthread.h>
#include <cstdlib>
#include <atomic>
#include <vector>
#include <condition_variable>
#include <deque>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>

#include "cppformat/format.h"

#define BOOST_THREAD_PROVIDES_FUTURE
#include <boost/thread/future.hpp>

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/APInt.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/PrettyStackTrace.h"

#include "polli/BlockingMap.h"
#include "polli/Caching.h"
#include "polli/CodeGen.h"
#include "polli/Options.h"
#include "polli/RuntimeValues.h"
#include "polli/RunValues.h"
#include "polli/Stats.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"
#include "polly/RegisterPasses.h"
#include "pprof/Tracing.h"

#include "papi.h"
#include "catch.hpp"

#define DEBUG_TYPE "polyjit"

using namespace llvm;
using namespace polli;

namespace {
using UniqueMod = std::unique_ptr<Module>;
using UniqueCtx = std::unique_ptr<LLVMContext>;

using fmt::format;
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;
static StackTracePtr StackTrace;

class ModManager {
public:
  using ModuleIndexT = DenseMap<const char *, UniqueMod>;
  using ContextIndexT = SmallVector<UniqueCtx, 8>;
private:
  ModuleIndexT ModuleIndex;
  ContextIndexT CtxIndex;

public:
  ModuleIndexT &modules() { return ModuleIndex; }
  ContextIndexT &contexts() { return CtxIndex; }

  ~ModManager() {
    ModuleIndex.clear();
    CtxIndex.clear();
  }
};

/**
 * @brief Read the LLVM-IR module from the given prototype string.
 *
 * @param prototype The prototype string we want to read in.
 * @return llvm::Module& The LLVM-IR module we just read.
 */
static Module &getModule(const char *prototype, bool &cache_hit) {
  static ModManager MM;
  static mutex _m;
  ModManager::ModuleIndexT &ModuleIndex = MM.modules();
  ModManager::ContextIndexT &ContextIndex = MM.contexts();
  std::lock_guard<std::mutex> L(_m);

  cache_hit = true;
  if (!MM.modules().count(prototype)) {
    UniqueCtx Ctx = UniqueCtx(new LLVMContext());
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;

    if (UniqueMod Mod = parseIR(Buf, Err, *Ctx)) {
      DEBUG(Mod->dump());
      ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
      ContextIndex.push_back(std::move(Ctx));
    } else {
      errs() << format("{:s}:{:d}:{:d} {:s}\n", Err.getFilename().str(),
                       Err.getLineNo(), Err.getColumnNo(),
                       Err.getMessage().str());
      errs() << format("{:s}\n", prototype);
    }
    assert(ModuleIndex[prototype] &&
           "Parsing the prototype module failed!");
    cache_hit = false;
  }

  return *ModuleIndex[prototype];
}

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
    if (F.hasFnAttribute("polyjit-jit-candidate"))
      return F;
  }

  errs() << "No JIT candidate in prototype!\n";
  llvm_unreachable("No JIT candidate found in prototype!");
}

static inline void do_shutdown() {
  // This forces the linker to keep the symbols around, if tracing is
  // enabled.
  if (std::getenv("POLLI_BOGUS_VAR") != nullptr) {
    POLLI_TRACING_SCOP_START(-1, "polli.invalid.scop");
    POLLI_TRACING_SCOP_STOP(-1, "polli.invalid.scop");
  }

  POLLI_TRACING_REGION_STOP(PJIT_REGION_MAIN, "polyjit.main");
  POLLI_TRACING_FINALIZE;
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;
  opt::EmitJitDebugInfo = std::getenv("POLLI_EMIT_JIT_DEBUG_INFO") != nullptr;
}

} // end of anonymous namespace

/**
* @brief Get a new Execution engine for the given module.
*
* @param M The module that needs a new execution engine.
*
* @return A new execution engine for M.
*/
static ExecutionEngine *getEngine(std::unique_ptr<Module> M) {
  std::string ErrorMsg;

  // If we are supposed to override the target triple, do so now.
  if (!opt::TargetTriple.empty())
    M->setTargetTriple(Triple::normalize(opt::TargetTriple));

  EngineBuilder builder(std::move(M));
  auto MemManager = std::unique_ptr<llvm::SectionMemoryManager>();

  CodeGenOpt::Level OLvl;
  switch (opt::OptLevel) {
  default:
    OLvl = CodeGenOpt::Aggressive;
    break;
  case '0':
    OLvl = CodeGenOpt::None;
    break;
  case '1':
    OLvl = CodeGenOpt::Less;
    break;
  case '2':
    OLvl = CodeGenOpt::Default;
    break;
  case '3':
    OLvl = CodeGenOpt::Aggressive;
    break;
  }

  builder.setMArch(opt::MArch);
  builder.setMCPU(opt::MCPU);
  builder.setMAttrs(opt::MAttrs);
  builder.setRelocationModel(opt::RelocModel);
  builder.setCodeModel(opt::CModel);
  builder.setErrorStr(&ErrorMsg);
  builder.setEngineKind(EngineKind::JIT);
  builder.setMCJITMemoryManager(std::move(MemManager));
  builder.setOptLevel(OLvl);

  llvm::TargetOptions Options;
  if (opt::FloatABIForCalls != FloatABI::Default)
    Options.FloatABIType = opt::FloatABIForCalls;
  if (opt::GenerateSoftFloatCalls)
    opt::FloatABIForCalls = FloatABI::Soft;

  builder.setTargetOptions(Options);
  ExecutionEngine *EE = builder.create();
  if (!EE)
    std::cerr << "ERROR: " << ErrorMsg << "\n";
  return EE;
}

static inline Function &getPrototype(const char *function, bool &cache_hit) {
  POLLI_TRACING_REGION_START(PJIT_REGION_GET_PROTOTYPE, "polyjit.prototype.get");
  Module &M = getModule(function, cache_hit);
  Function &F = getFunction(M);
  POLLI_TRACING_REGION_STOP(PJIT_REGION_GET_PROTOTYPE, "polyjit.prototype.get");
  return F;
}

namespace polli {

class PolyJIT {
public:
  explicit PolyJIT() : VariantFunctions(), CodeCache(), EE(nullptr) {}
  ~PolyJIT() {
    System.cancel_pending_jobs();
  }

  /**
   * @name CodeCache interface.
   * @{ */
  using CodeCacheT =
      std::unordered_map<CacheKey, std::function<void(int, char **)>>;
  using iterator = CodeCacheT::iterator;
  using const_iterator = CodeCacheT::const_iterator;
  using value_type = CodeCacheT::mapped_type;

  const_iterator find(const CacheKey &K) const {
    return CodeCache.find(K);
  }
  iterator begin() { return CodeCache.begin(); }
  const_iterator begin() const { return CodeCache.begin(); }

  iterator end() { return CodeCache.end(); }
  const_iterator end() const { return CodeCache.end(); }

  value_type operator[](CacheKey &K) {
    return CodeCache[K];
  }

  const value_type operator[](const CacheKey &K) {
    return CodeCache[K];
  }

  std::pair<iterator, bool> insert(const CodeCacheT::value_type &el) {
    return CodeCache.insert(el);
  }
  /**  @} */

  ExecutionEngine &engine(std::unique_ptr<Module> NewM) {
    if (!EE)
      EE = getEngine(std::move(NewM));
    else
      EE->addModule(std::move(NewM));
    return *EE;
  }

  /**
   * @name Asynchronous task scheduling interface.
   * @{ */
  struct deref_functor {
    template <typename Pointer> void operator()(Pointer const &p) const {
      (*p)();
    }
  };

  template <typename F, typename... Args>
  auto async(F &&f, Args &&... args)
      -> boost::future<typename std::result_of<F(Args...)>::type> {
    using result_type = typename std::result_of<F(Args...)>::type;
    using task_type = boost::packaged_task<result_type>;

    auto Task = std::make_shared<task_type>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));

    boost::future<result_type> ft = Task->get_future();

    System.async(std::move(std::bind(deref_functor(), Task)));
    return std::move(ft);
  }
  /**  @} */

  /**
   * @brief Get or Create a new variant function for the given Function.
   *
   * @param F The function we get or create the variant function for.
   *
   * @return A variant function for function F
   */
  VariantFunctionTy getOrCreateVariantFunction(Function *F) {
    // We have already specialized this function at least once.
    if (VariantFunctions.count(F))
      return VariantFunctions.at(F);

    // Create a variant function & specialize a new variant, based on key.
    VariantFunctionTy VarFun = std::make_shared<VariantFunction>(*F);

    VariantFunctions.insert(std::make_pair(F, VarFun));
    return VarFun;
  }
private:
  VariantFunctionMapTy VariantFunctions;
  CodeCacheT CodeCache;
  ExecutionEngine *EE;
  TaskSystem System;
};

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
                           CacheKey K, JitT Context) {
  if (Context->find(K) != Context->end())
    return;

  POLLI_TRACING_REGION_START(PJIT_REGION_CODEGEN, "polyjit.codegen");
  llvm::Function *F = Request->F;
  VariantFunctionTy VarFun = Context->getOrCreateVariantFunction(F);
  RunValueList Values = runValues(*Request);
  std::string FnName;
  auto Variant = VarFun->createVariant(Values, FnName);
  if (!Variant)
    return;

  ExecutionEngine &EE = Context->engine(std::move(Variant));

  DEBUG(printRunValues(Values));

  // Using the MCJIT: This does _NOT_ recompile all added modules.
  // The fact that MCJIT does not support recompilation, saves us here.
  EE.finalizeObject();

  uint64_t FPtr = EE.getFunctionAddress(FnName);
  assert(FPtr && "Specializer returned nullptr.");
  if (!Context->insert(
          std::make_pair(K, MainFnT((void (*)(int, char **))FPtr))).second) {
    llvm_unreachable("Key collision");
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_CODEGEN, "polyjit.codegen");
}

extern "C" {
static void printStats(const Stats &S, raw_ostream &OS) {
  outs() << "ID: " << &S << " N: " << S.NumCalls << " LT: " << S.LookupTime
         << " RT: " << S.LastRuntime
         << " Overhead: " << S.LookupTime * 100 / (double)S.LastRuntime << "%\n";
}

void pjit_trace_fnstats_entry(uint64_t *prefix, bool is_variant) {
  dbgs() << "ID: " << prefix << " IsVariant? " << is_variant << "\n";
  polli::Stats *FnStats = reinterpret_cast<polli::Stats *>(prefix);
  if (!FnStats)
    return;
  FnStats->NumCalls++;
  FnStats->RegionEnter = PAPI_get_real_nsec();
}

void pjit_trace_fnstats_exit(uint64_t *prefix, bool is_variant) {
  polli::Stats *FnStats = reinterpret_cast<polli::Stats *>(prefix);
  if (!FnStats)
    return;

  FnStats->RegionExit = PAPI_get_real_nsec();
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
bool pjit_main(const char *fName, uint64_t *prefix, unsigned paramc,
               char **params) {
  static int ok = PAPI_library_init(PAPI_VERSION);
  polli::Stats *FnStats = reinterpret_cast<polli::Stats *>(prefix);
  if (opt::DisableRecompile)
    return false;

  uint64_t start = PAPI_get_real_nsec();
  auto Request = std::make_shared<SpecializerRequest>(fName, paramc, params);
  JitT Context = getOrCreateJIT();

  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  Function *F = Request->F;
  auto FutureFn =
      Context->async(GetOrCreateVariantFunction, Request, K.first, Context);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!K.second)
    FutureFn.wait();

  auto FnIt = Context->find(K.first);

  bool JitReady = false;
  if (FnIt != Context->end()) {
    FnStats->LookupTime = PAPI_get_real_nsec() - start;
    pjit_trace_fnstats_entry(prefix, true);
    (FnIt->second)(paramc, params);
    pjit_trace_fnstats_exit(prefix, true);
    FnStats->LastRuntime = FnStats->RegionExit - FnStats->RegionEnter;
    JitReady = true;
  } else {
    FnStats->LookupTime = PAPI_get_real_nsec() - start;
  }

  if (FnStats) {
    printStats(*FnStats, outs());
  }

  return JitReady;
}
} /* extern "C" */
} /* polli */

namespace {
class StaticInitializer {
public:
  StaticInitializer() {
    using polly::initializePollyPasses;

    set_options_from_environment();

    StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

    // Make sure to initialize tracing before planting the atexit handler.
    POLLI_TRACING_INIT;
    POLLI_TRACING_REGION_START(PJIT_REGION_MAIN, "polyjit.main");

    // We want to register this after the tracing atexit handler.
    atexit(do_shutdown);

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
    initializeRewriteSymbolsPass(Registry);

    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();
    InitializeNativeTargetAsmParser();
  }
};

static StaticInitializer InitializeEverything;
}
