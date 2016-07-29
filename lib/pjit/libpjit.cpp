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
#include <cstdlib>
#include <atomic>
#include <vector>
#include <condition_variable>
#include <deque>
#include <memory>
#include <thread>
#include <unordered_map>

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/APInt.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/IR/Mangler.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/ObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/DynamicLibrary.h"

#include "polli/Caching.h"
#include "polli/Jit.h"
#include "polli/Options.h"
#include "polli/RuntimeValues.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/RunValues.h"
#include "polli/Stats.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"
#include "polli/log.h"
#include "polly/RegisterPasses.h"
#include "pprof/Tracing.h"

#define DEBUG_TYPE "polyjit"

using namespace llvm;
using namespace polli;
namespace fmt = spdlog::details::fmt;

namespace {
using UniqueMod = std::shared_ptr<Module>;
using UniqueCtx = std::shared_ptr<LLVMContext>;

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
//    ModuleIndex.clear();
//    CtxIndex.clear();
  }
};

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


namespace polli {
class PolyJITEngine {
public:
  using ObjLayerT = orc::ObjectLinkingLayer<>;
  using CompileLayerT = orc::IRCompileLayer<ObjLayerT>;
  using ModuleHandleT = CompileLayerT::ModuleSetHandleT;
  using UniqueModule = std::unique_ptr<Module>;
private:
  using OptimizeFunction = std::function<UniqueModule(UniqueModule)>;
public:
  PolyJITEngine()
      : TM(EngineBuilder().selectTarget()), DL(TM->createDataLayout()),
        CompileLayer(ObjectLayer, orc::SimpleCompiler(*TM)),
        OptimizeLayer(CompileLayer, [this](UniqueModule M) {
          return polli::OptimizeForRuntime(std::move(M));
        }) {
    llvm::sys::DynamicLibrary::LoadLibraryPermanently(nullptr);
  }

  /**
   * @brief Read the LLVM-IR module from the given prototype string.
   *
   * @param prototype The prototype string we want to read in.
   * @return llvm::Module& The LLVM-IR module we just read.
   */
  Module &getModule(const char *prototype, bool &cache_hit) {
    static ModManager MM;
    static mutex _m;
    ModManager::ModuleIndexT &ModuleIndex = MM.modules();
    //ModManager::ContextIndexT &ContextIndex = MM.contexts();
    std::lock_guard<std::mutex> L(_m);

    cache_hit = true;
    if (!MM.modules().count(prototype)) {
      //UniqueCtx Ctx = UniqueCtx(new LLVMContext());
      MemoryBufferRef Buf(prototype, "polli.prototype.module");

      SMDiagnostic Err;
      if (UniqueMod Mod = parseIR(Buf, Err, Ctx)) {
        ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
      } else {
        std::string FileName = Err.getFilename().str();
        errs() << fmt::format("{:s}:{:d}:{:d} {:s}\n", FileName,
                         Err.getLineNo(), Err.getColumnNo(),
                         Err.getMessage().str());
        errs() << fmt::format("{0}\n", prototype);
      }
      assert(ModuleIndex[prototype] &&
             "Parsing the prototype module failed!");
      cache_hit = false;
    }

    return *ModuleIndex[prototype];
  }

  ModuleHandleT addModule(std::unique_ptr<Module> M) {
    if (CompiledModules.count(M.get()))
      return CompiledModules[M.get()];

    auto Resolver = orc::createLambdaResolver(
        [&](const std::string &Name) {
          if (auto Sym = findSymbol(Name))
            return RuntimeDyld::SymbolInfo(Sym.getAddress(), Sym.getFlags());
          return RuntimeDyld::SymbolInfo(nullptr);
        },
        [] (const std::string &S) {
          if (auto SymAddr = RTDyldMemoryManager::getSymbolAddressInProcess(S))
            return RuntimeDyld::SymbolInfo(SymAddr, JITSymbolFlags::Exported);
          return RuntimeDyld::SymbolInfo(nullptr);
        }
    );

    std::vector<std::unique_ptr<Module>> MS;
    MS.push_back(std::move(M));
    ModuleHandleT MH = CompileLayer.addModuleSet(std::move(MS), make_unique<SectionMemoryManager>(), std::move(Resolver));
    CompiledModules.insert(std::make_pair(M.get(), MH));
    return MH;
  }

  void removeModule(ModuleHandleT H) {
    CompileLayer.removeModuleSet(H);
  }

  orc::JITSymbol findSymbol(const std::string &Name) {
    std::string MangledName;
    raw_string_ostream MangledNameStream(MangledName);
    Mangler::getNameWithPrefix(MangledNameStream, Name, DL);
    orc::JITSymbol S =CompileLayer.findSymbol(MangledNameStream.str(), false);
    uint64_t *Addr = (uint64_t *)S.getAddress();
    log()->debug("FindSymbol: {0:s} Addr: {0:x}", Name, (uint64_t)Addr);
    return S;
  }

private:
  llvm::LLVMContext Ctx;
  std::unique_ptr<TargetMachine> TM;
  const DataLayout DL;
  ObjLayerT ObjectLayer;
  CompileLayerT CompileLayer;
  orc::IRTransformLayer<CompileLayerT, OptimizeFunction> OptimizeLayer;
  llvm::DenseMap<const char *, Module *> LoadedModules;
  llvm::DenseMap<Module *, ModuleHandleT> CompiledModules;
};

static PolyJITEngine &getEE() {
  static PolyJITEngine EE;
  return EE;
}
}

static inline Function &getPrototype(const char *function, bool &cache_hit) {
  POLLI_TRACING_REGION_START(PJIT_REGION_GET_PROTOTYPE, "polyjit.prototype.get");
  Module &M = getEE().getModule(function, cache_hit);
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
                           CacheKey K, JitT Context) {
  static PolyJITEngine EE;
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

  EE.addModule(std::move(Variant));
  DEBUG(printRunValues(Values));


  orc::JITSymbol FPtr = EE.findSymbol(FnName);
  assert(FPtr && "Specializer returned nullptr.");
  if (!Context
           ->insert(std::make_pair(
               K, MainFnT((void (*)(int, char **))FPtr.getAddress())))
           .second) {
    llvm_unreachable("Key collision");
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_CODEGEN, "polyjit.codegen");
}

/*
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
*/

extern "C" {
static void printStats(const Stats &S) {
  log()->debug(
    "ID: {0:x} N: {1:d} LT: {2:d} RT: {3:d} Overhead: {4:3.2f}%",
    (uint64_t)(&S), S.NumCalls, S.LookupTime, S.LastRuntime, S.LookupTime,
    (S.LookupTime * 100 / (double)S.LastRuntime)
  );
}

void pjit_trace_fnstats_entry(uint64_t *prefix, bool is_variant) {
  log()->debug("ID: {0:x} IsVariant? {1}\n", (uint64_t)prefix, is_variant);
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
  if (!PAPI_is_initialized())
    PAPI_library_init(PAPI_VERSION);
  polli::Stats *FnStats = reinterpret_cast<polli::Stats *>(prefix);
  if (opt::DisableRecompile)
    return false;

  uint64_t start = PAPI_get_real_nsec();
  auto Request = std::make_shared<SpecializerRequest>(fName, paramc, params);
  JitT Context = getOrCreateJIT();

  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
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

  if (FnStats)
    trackStatsChange(Request->F, *FnStats);

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
