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
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/Orc/ObjectLinkingLayer.h"
#include "llvm/IR/Mangler.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/DynamicLibrary.h"

#include "polli/Caching.h"
#include "polli/Jit.h"
#include "polli/Options.h"
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

#include <dlfcn.h>

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
      SPDLOG_DEBUG("libpjit", "fn-jit-candidate: {:s}", F.getName().str());
      return F;
    }
  }

  errs() << "No JIT candidate in prototype!\n";
  llvm_unreachable("No JIT candidate found in prototype!");
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;
  opt::EmitJitDebugInfo = std::getenv("POLLI_EMIT_JIT_DEBUG_INFO") != nullptr;
}

} // end of anonymous namespace

namespace polli {
/// @brief Simple compile functor: Takes a single IR module and returns an
///        ObjectFile.
class SimpleErrorReportingCompiler {
public:
  /// @brief Construct a simple compile functor with the given target.
  SimpleErrorReportingCompiler(TargetMachine &TM) : TM(TM) {}

  /// @brief Compile a Module to an ObjectFile.
  object::OwningBinary<object::ObjectFile> operator()(Module &M) const {
    SmallVector<char, 0> ObjBufferSV;
    raw_svector_ostream ObjStream(ObjBufferSV);

    legacy::PassManager PM;
    MCContext *Ctx;

    TM.setOptLevel(CodeGenOpt::Aggressive);
    if (TM.addPassesToEmitMC(PM, Ctx, ObjStream))
      llvm_unreachable("Target does not support MC emission.");
    PM.run(M);

    std::unique_ptr<MemoryBuffer> ObjBuffer(
        new ObjectMemoryBuffer(std::move(ObjBufferSV)));
    Expected<std::unique_ptr<object::ObjectFile>> Obj =
        object::ObjectFile::createObjectFile(ObjBuffer->getMemBufferRef());
    typedef object::OwningBinary<object::ObjectFile> OwningObj;
    if (Obj)
      return OwningObj(std::move(*Obj), std::move(ObjBuffer));

    consumeError(Obj.takeError());
    return OwningObj(nullptr, nullptr);
  }

private:
  TargetMachine &TM;
};

class PolySectionMemoryManager : public SectionMemoryManager {
  uint8_t *allocateCodeSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID,
                               StringRef SectionName) override {
    uint8_t *ptr = SectionMemoryManager::allocateCodeSection(
        Size, Alignment, SectionID, SectionName);
    SPDLOG_DEBUG(
        "libpjit", "cs @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str());
    return ptr;
  }

  uint8_t *allocateDataSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID, StringRef SectionName,
                               bool isReadOnly) override {
    uint8_t *ptr = SectionMemoryManager::allocateDataSection(
        Size, Alignment, SectionID, SectionName, isReadOnly);
    SPDLOG_DEBUG(
        "ds @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s} ro: {:d}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str(),
        isReadOnly);
    return ptr;
  }
};

class PolyJITEngine {
public:
  using ObjLayerT = orc::ObjectLinkingLayer<>;
  using CompileLayerT = orc::IRCompileLayer<ObjLayerT>;
  using ModuleHandleT = CompileLayerT::ModuleSetHandleT;
  using UniqueModule = std::unique_ptr<Module>;

  PolyJITEngine()
      : TM(EngineBuilder()
               .setMArch(polli::opt::MArch)
               .setMCPU(polli::opt::MCPU)
               .setMAttrs(polli::opt::MAttrs)
               .selectTarget()),
        DL(TM->createDataLayout()),
        CompileLayer(ObjectLayer, SimpleErrorReportingCompiler(*TM)),
        LibHandle(nullptr) {
    SPDLOG_DEBUG("libpjit", "Starting PolyJIT Engine.");
    LibHandle = dlopen(nullptr, RTLD_NOW | RTLD_GLOBAL);
    llvm::sys::DynamicLibrary::LoadLibraryPermanently(nullptr);
  }

  /**
   * @brief Read the LLVM-IR module from the given prototype string.
   *
   * @param prototype The prototype string we want to read in.
   * @return llvm::Module& The LLVM-IR module we just read.
   */
  Module &getModule(const char *prototype, bool &cache_hit) {
    cache_hit = true;
    if (!LoadedModules.count(prototype)) {
      MemoryBufferRef Buf(prototype, "polli.prototype.module");
      SMDiagnostic Err;
      auto Ctx = std::make_shared<LLVMContext>();

      CtxList.push_back(Ctx);
      if (UniqueMod Mod = parseIR(Buf, Err, *Ctx)) {
        LoadedModules.insert(std::make_pair(prototype, std::move(Mod)));
      } else {
        std::string FileName = Err.getFilename().str();
        console->critical("{:s}:{:d}:{:d} {:s}", FileName, Err.getLineNo(),
                          Err.getColumnNo(), Err.getMessage().str());
        console->critical("{0}", prototype);
      }

      auto PrototypeM = LoadedModules[prototype];
      if (!PrototypeM)
        console->critical("Parsing the prototype module failed!");
      assert(PrototypeM && "Parsing the prototype module failed!");
      cache_hit = false;
    }

    return *LoadedModules[prototype];
  }

  ModuleHandleT addModule(std::unique_ptr<Module> M) {
    if (CompiledModules.count(M.get()))
      return CompiledModules[M.get()];

    DEBUG({
      std::string buf;
      raw_string_ostream os(buf);
      M->print(os, nullptr);
      console->error(os.str());
    });
    for (GlobalValue &GV : M->globals()) {
      std::lock_guard<std::mutex> Lock(DLMutex);
      dlerror();
      void *Addr = dlsym(LibHandle, GV.getName().str().c_str());
      if (char *Error = dlerror())
        console->error("(dlsym) Could not locate the symbol: {:s}", Error);
      if (Addr)
        llvm::sys::DynamicLibrary::AddSymbol(GV.getName(), Addr);
    }

    auto Resolver = orc::createLambdaResolver(
        [&](const std::string &Name) {
          if (auto Sym = findSymbol(Name))
            return RuntimeDyld::SymbolInfo(Sym.getAddress(), Sym.getFlags());
          return RuntimeDyld::SymbolInfo(nullptr);
        },
        [](const std::string &S) {
          if (auto SymAddr = RTDyldMemoryManager::getSymbolAddressInProcess(S))
            return RuntimeDyld::SymbolInfo(SymAddr, JITSymbolFlags::Exported);
          return RuntimeDyld::SymbolInfo(nullptr);
        });

    std::vector<std::unique_ptr<Module>> MS;
    MS.push_back(std::move(M));
    ModuleHandleT MH = CompileLayer.addModuleSet(
        std::move(MS), std::unique_ptr<PolySectionMemoryManager>(
                           new PolySectionMemoryManager()),
        std::move(Resolver));
    CompiledModules.insert(std::make_pair(M.get(), MH));
    return MH;
  }

  void removeModule(ModuleHandleT H) { CompileLayer.removeModuleSet(H); }

  orc::JITSymbol findSymbol(const std::string &Name) {
    std::string MangledName;
    raw_string_ostream MangledNameStream(MangledName);
    Mangler::getNameWithPrefix(MangledNameStream, Name, DL);
    return CompileLayer.findSymbol(MangledNameStream.str(), false);
  }

  ~PolyJITEngine() {
    CompiledModules.clear();
    LoadedModules.clear();
    CtxList.clear();
    SPDLOG_DEBUG("libpjit", "Stopping PolyJIT Engine.");
  }

private:
  std::mutex DLMutex;
  std::vector<std::shared_ptr<LLVMContext>> CtxList;
  std::unique_ptr<TargetMachine> TM;
  const DataLayout DL;
  ObjLayerT ObjectLayer;
  CompileLayerT CompileLayer;
  llvm::DenseMap<const char *, UniqueMod> LoadedModules;
  llvm::DenseMap<Module *, ModuleHandleT> CompiledModules;
  void *LibHandle;
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

// static inline void do_shutdown() {
//  // This forces the linker to keep the symbols around, if tracing is
//  // enabled.
//  if (std::getenv("POLLI_BOGUS_VAR") != nullptr) {
//    POLLI_TRACING_SCOP_START(-1, "polli.invalid.scop");
//    POLLI_TRACING_SCOP_STOP(-1, "polli.invalid.scop");
//  }
//  getOrCreateJIT()->shutdown();
//
//  POLLI_TRACING_REGION_STOP(PJIT_REGION_MAIN, "polyjit.main");
//  POLLI_TRACING_FINALIZE;
//}

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

  SPDLOG_DEBUG("libpjit", "{:s}: Create new Variant.",
               Request->F->getName().str());
  SPDLOG_DEBUG("libpjit", "Hash: {:x} IR: {:x}", K.ValueHash, (uint64_t)K.IR);
  POLLI_TRACING_REGION_START(PJIT_REGION_CODEGEN, "polyjit.codegen");

  VariantFunctionTy VarFun = Context->getOrCreateVariantFunction(Request->F);
  RunValueList Values = runValues(*Request);
  std::string FnName;

  auto Variant = VarFun->createVariant(Values, FnName);
  assert(Variant && "Failed to get a new variant.");

  PolyJITEngine &EE = getOrCreateEngine();
  EE.addModule(std::move(Variant));
  DEBUG(printRunValues(Values));

  orc::JITSymbol FPtr = EE.findSymbol(FnName);
  SPDLOG_DEBUG("libpjit", "fn ptr: 0x{:x}", FPtr.getAddress());
  assert(FPtr && "Specializer returned nullptr.");
  if (!Context
           ->insert(std::make_pair(
               K, MainFnT((void (*)(int, char **))FPtr.getAddress())))
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
    initializeRewriteSymbolsPass(Registry);

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
  pjit_library_init();
  JitT Context = getOrCreateJIT();
  Context->enter(1, papi::PAPI_get_real_usec());

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
  FutureFn.wait();
  Context->exit(1, papi::PAPI_get_real_usec());

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
  pjit_library_init();
  JitT Context = getOrCreateJIT();
  Context->enter(1, papi::PAPI_get_real_usec());
  std::pair<CacheKey, bool> K = GetCacheKey(*Request);
  if (!K.second) {
    llvm::Function *F = Request->F;
    Context->UpdatePrefixMap((uint64_t)prefix, F);
    Context->addRegion(Request->F->getName().str(),
                       GetCandidateId(*Request->F));
  }
  Context->exit(1, papi::PAPI_get_real_usec());
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
