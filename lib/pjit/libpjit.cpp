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
#include <vector>
#include <future>
#include <thread>
#include <condition_variable>
#include <memory>
#include <string>
#include <deque>
#include <mutex>
#include <unordered_map>

#include "llvm/IR/Module.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/APInt.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/Function.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"

#include "pprof/Tracing.h"
#include "polli/Options.h"
#include "polli/VariantFunction.h"
#include "polli/FunctionDispatcher.h"
#include "polli/RuntimeValues.h"
#include "polly/RegisterPasses.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/PrettyStackTrace.h"

#include "cppformat/format.h"

#define DEBUG_TYPE "polyjit"

using namespace llvm;
using namespace polli;

namespace {
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;
static StackTracePtr StackTrace;
static FunctionDispatcher Disp;

/**
 * @brief Read the LLVM-IR module from the given prototype string.
 *
 * @param prototype The prototype string we want to read in.
 * @return llvm::Module& The LLVM-IR module we just read.
 */
static Module &getModule(const char *prototype) {
  using UniqueMod = std::unique_ptr<Module>;
  static DenseMap<const char *, UniqueMod> ModuleIndex;

  if (!ModuleIndex.count(prototype)) {
    LLVMContext &Ctx = llvm::getGlobalContext();
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;

    if (UniqueMod Mod = parseIR(Buf, Err, Ctx)) {
      DEBUG(Mod->dump());
      ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
    } else {
      errs() << format("{:s}:{:d}:{:d} {:s}\n", Err.getFilename().str(),
                       Err.getLineNo(), Err.getColumnNo(),
                       Err.getMessage().str());
      errs() << format("{:s}\n", prototype);
    }
    assert(ModuleIndex[prototype] && "Parsing the prototype module failed!");
  }

  return *ModuleIndex[prototype];
}

/**
 * @brief Get the protoype function stored in this module.
 *
 * This assumes that it operates on a prototype module of PolyJIT. Such
 * a module only contains one function.
 *
 * @param M The prototype module.
 * @return llvm::Function* The first function in the given module.
 */
static Function *getFunction(Module &M) {
  Disp.setPrototypeMapping(&*M.begin(), &*M.begin());
  return &*M.begin();
}

static inline void do_shutdown() {
  // This forces the linker to keep the symbols around, if tracing is
  // enabled.
  if (std::getenv("POLLI_BOGUS_VAR") != nullptr) {
    POLLI_TRACING_SCOP_START(-1, "polli.invalid.scop");
    POLLI_TRACING_SCOP_STOP(-1, "polli.invalid.scop");
  }
  POLLI_TRACING_REGION_STOP(0, "polyjit.main");
  POLLI_TRACING_FINALIZE;
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;
  opt::EmitJitDebugInfo = std::getenv("POLLI_EMIT_JIT_DEBUG_INFO") != nullptr;
}

class StaticInitializer {
public:
  StaticInitializer() {
    using polly::initializePollyPasses;

    set_options_from_environment();

    StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

    POLLI_TRACING_INIT;
    POLLI_TRACING_REGION_START(0, "polyjit.main");

    atexit(do_shutdown);

    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    polly::initializePollyPasses(Registry);
    initializeCore(Registry);
    initializeScalarOpts(Registry);
    initializeObjCARCOpts(Registry);
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
    initializeWinEHPreparePass(Registry);
    initializeDwarfEHPreparePass(Registry);

    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();
    InitializeNativeTargetAsmParser();
  }
};

static StaticInitializer InitializeEverything;
} // end of anonymous namespace

/**
* @brief Get a new Execution engine for the given module.
*
* @param M The module that needs a new execution engine.
*
* @return A new execution engine for M.
*/
static ExecutionEngine *getEngine(Module *M) {
  std::string ErrorMsg;

  // If we are supposed to override the target triple, do so now.
  if (!opt::TargetTriple.empty())
    M->setTargetTriple(Triple::normalize(opt::TargetTriple));

  std::unique_ptr<Module> Owner(M);
  EngineBuilder builder(std::move(Owner));
  auto MemManager = std::unique_ptr<llvm::SectionMemoryManager>();

  CodeGenOpt::Level OLvl;
  switch (opt::OptLevel) {
  default:
    OLvl = CodeGenOpt::Default;
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
  builder.setOptLevel(CodeGenOpt::None);

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

static inline Function *getPrototype(const char *function) {
  POLLI_TRACING_REGION_START(2, "polyjit.prototype.get");
  Module &M = getModule(function);
  Function *F = getFunction(M);
  if (!F) {
    errs() << fmt::format("Could not find a function in: {}\n",
                          M.getModuleIdentifier());
    llvm_unreachable("Could not find a function in the prototype module");
    return nullptr;
  }
  POLLI_TRACING_REGION_STOP(2, "polyjit.prototype.get");
  return F;
}

#ifdef DEBUG
static void printArgs(const Function &F, size_t argc, char **params) {
  std::string buf;
  llvm::raw_string_ostream s(buf);
  F.getType()->print(s);
  dbgs() << s.str() << "\n";
  for (size_t i = 0; i < argc; i++) {
    dbgs() << fmt::format("[{}] -> {:d} - {}\n", i,
                          *reinterpret_cast<uint64_t *>(params[i]),
                          reinterpret_cast<void *>(params[i]));
  }
}
#endif

static void printRunValues(const RunValueList & Values) {
  for (auto &RV : Values) {
    dbgs() << fmt::format("{} matched against {}\n", RV.value, (void *)RV.Arg);
  }
}

static RunValueList runValues(Function *F, unsigned paramc, void *params) {
  POLLI_TRACING_REGION_START(3, "polyjit.params.select");
  int i = 0;
  RunValueList RunValues;

  for (const Argument &Arg : F->args()) {
    RunValues.add({ (*((uint64_t **)params)[i]), &Arg });
    i++;
  }
  POLLI_TRACING_REGION_STOP(3, "polyjit.params.select");
  return RunValues;
}

struct SpecializerRequest {
  const char *IR;
  unsigned ParamC;
  char **Params;

  SpecializerRequest(const char *IR, unsigned ParamC, char **Params)
      : IR(IR), ParamC(ParamC), Params(Params) {}
};

struct CacheKey {
  const char *IR;
  size_t ValueHash;

  CacheKey(const char *IR, size_t ValueHash)
      : IR(IR), ValueHash(ValueHash) {}
  CacheKey(const SpecializerRequest &Req, size_t ValueHash)
      : IR(Req.IR), ValueHash(ValueHash) {}

  bool operator==(const CacheKey &O) const {
    return IR == O.IR && ValueHash == O.ValueHash;
  }

  bool operator<(const CacheKey &O) const {
    return IR < O.IR || (IR == O.IR && ValueHash < O.ValueHash);
  }
};

template<>
struct std::hash<CacheKey> {
  std::size_t operator()(const CacheKey &K) const {
    return (size_t)K.IR ^ K.ValueHash;
  }
};

template <typename T> class CodeGenQueue {
private:
  std::deque<T> Work;
  mutable std::mutex M;

public:
  using value_type = T;
  using reference = const T &;

  reference front() const { return Work.front(); }
  reference back() const { return Work.front(); }

  void pop_front() {
    std::unique_lock<std::mutex> L(M);
    Work.pop_front();
  }

  void pop_back() {
    std::unique_lock<std::mutex> L(M);
    Work.pop_back();
  }

  bool empty() const {
    std::unique_lock<std::mutex> L(M);
    return Work.empty();
  }

  void push_back(const value_type &x) {
    std::unique_lock<std::mutex> L(M);
    Work.push_back(x);
  }

  void push_back(value_type &&x) {
    std::unique_lock<std::mutex> L(M);
    Work.push_back(x);
  }
};

static std::unordered_map<CacheKey, uint64_t> FunctionCache;
static std::unordered_map<const char *, llvm::Function *> IRFunctionCache;

static CodeGenQueue<SpecializerRequest> Work;

class PolyJIT {
private:
  std::thread Generator;

  std::mutex GeneratorRequestMutex;
  std::mutex CacheRequestMutex;
  std::condition_variable GeneratorShouldStart;
  std::condition_variable GeneratorShutDown;
  bool ShuttingDown = false;
  std::condition_variable CacheReady;

public:
  PolyJIT()
      : Generator([&]() {
          pthread_setname_np(pthread_self(), "PolyJIT_CodeGen");
          while (!ShuttingDown) {
            std::unique_lock<std::mutex> Lock(GeneratorRequestMutex);
            GeneratorShouldStart.wait(Lock);

            POLLI_TRACING_REGION_START(1, "polyjit.codegen");
            while (!Work.empty()) {
              const SpecializerRequest &Request = Work.front();
              Function *F = getPrototype(Request.IR);
              RunValueList Values =
                  runValues(F, Request.ParamC, Request.Params);
              VariantFunctionTy VarFun = Disp.getOrCreateVariantFunction(F);
              Function *NewF = VarFun->getOrCreateVariant(Values);
              Module *NewM = NewF->getParent();
              ExecutionEngine *EE = getEngine(NewM);

              DEBUG(printArgs(*F, Request.ParamC, Request.Params));
              DEBUG(printRunValues(Values));

              assert(EE && "No execution engine could be constructed.");
              EE->finalizeObject();

              FunctionCache.insert(std::make_pair(
                  CacheKey(Request, Values.hash()),
                  EE->getFunctionAddress(NewF->getName().str())));
              IRFunctionCache.insert(std::make_pair(Request.IR, F));
              Work.pop_front();
              CacheReady.notify_all();
            }
            Lock.unlock();
            POLLI_TRACING_REGION_STOP(1, "polyjit.codegen");
          }

          GeneratorShutDown.notify_all();
        }) {}

  ~PolyJIT() {
    std::unique_lock<std::mutex> Lock(GeneratorRequestMutex);
    ShuttingDown = true;

    // Wake up the generator to allow it to shut down.
    GeneratorShouldStart.notify_all();
    GeneratorShutDown.wait(Lock);
    Generator.join();
  }

  void startGenerator() {
    GeneratorShouldStart.notify_all();
  }

  Function *waitForIRCache(std::function<bool()> && Pred,
                           std::function<Function *()> && Getter) {
      std::unique_lock<std::mutex> L(CacheRequestMutex);
      CacheReady.wait(L, Pred);
      Function *F = Getter();
      L.unlock();
      return F;
  }
};

static PolyJIT JIT;

extern "C" {
/**
 * @brief Runtime callback for PolyJIT.
 *
 * All calls to the PolyJIT runtime will land here.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
void pjit_main(const char *fName, unsigned paramc, char **params) {
  using fmt::format;

  // Check Cache, Register SpecializerRequest in the WorkQueue and notify
  // the generator that there is something to do.
  SpecializerRequest Request(fName, paramc, params);
  Work.push_back(Request);

  JIT.startGenerator();
  std::future<uint64_t> CacheRequest =
      std::async([](const SpecializerRequest &Request) -> uint64_t {
          using fmt::format;
          Function *F = JIT.waitForIRCache(
              [&]() { return IRFunctionCache.count(Request.IR); },
              [&]() { return IRFunctionCache[Request.IR]; });
          RunValueList Values = runValues(F, Request.ParamC, Request.Params);
          CacheKey K(Request, Values.hash());
          return FunctionCache[K];
      }, Request);

  void (*PF)(int, char **) = (void (*)(int, char **))CacheRequest.get();
  PF(paramc, params);
}
}
