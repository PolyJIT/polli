//===-- libpjit.cpp - PolyJIT Just in Time Compiler -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This tool implements a just-in-time compiler for LLVM, allowing direct
// execution of LLVM bitcode in an efficient manner.
//
//===----------------------------------------------------------------------===//
#include "llvm/IR/Module.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/APInt.h"
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

#include "spdlog/spdlog.h"
#include <likwid.h>

#include <stdlib.h>
#include <vector>
#include <cstdlib>

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
  static auto Console = spdlog::stderr_logger_st("polli");

  if (!ModuleIndex.count(prototype)) {
    LLVMContext &Ctx = llvm::getGlobalContext();
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;

    if (UniqueMod Mod = parseIR(Buf, Err, Ctx)) {
      DEBUG(Mod->dump());
      ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
    } else {
      Console->error("{:s}:{:d}:{:d} {:s}", Err.getFilename().str(),
                     Err.getLineNo(), Err.getColumnNo(),
                     Err.getMessage().str());
      Console->error("{:s}", prototype);
    }
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
  Disp.setPrototypeMapping(M.begin(), M.begin());
  return M.begin();
}

static inline void do_shutdown() {
  LIKWID_MARKER_STOP("polyjit.main");
  LIKWID_MARKER_CLOSE;
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;

  if (char *LogLevel = std::getenv("POLLI_LOG_LEVEL")) {
    opt::LogLevel = (polli::LogType)std::atoi(LogLevel);
  }

  if (char *OLvl = std::getenv("POLLI_OPT_LEVEL"))
    opt::OptLevel = std::atoi(OLvl);

  opt::EmitJitDebugInfo = std::getenv("POLLI_EMIT_JIT_DEBUG_INFO") != nullptr;
}

class StaticInitializer {
public:
  StaticInitializer() {
    set_options_from_environment();
    setupLogging();

    StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

    LIKWID_MARKER_INIT;
    LIKWID_MARKER_START("polyjit.main");

    atexit(do_shutdown);

    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    polly::initializePollyPasses(Registry);
    initializeCore(Registry);
    initializeScalarOpts(Registry);
    initializeObjCARCOpts(Registry);
    initializeVectorization(Registry);
    initializeIPO(Registry);
    initializeAnalysis(Registry);
    initializeIPA(Registry);
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
  //builder.setOptLevel(OLvl);
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

/**
* @brief Run a specialized version of a function.
*
* The specialized version needs to be in 'main' form, i.e., its signature
* has to be:
*  void fn_name(int argc, char *argv);
*
* The FunctionCloner's MainCreator policy takes care of that. All the real
* parameters are passed via argv.
*
* @param NewF the specialized function in main form.
* @param ArgValues the parameter _values_ for the formal parameters.
*/
static void runSpecializedFunction(llvm::Function &NewF, int paramc,
                                   char **params) {
  static auto Console = spdlog::stderr_logger_st("polli");
  LIKWID_MARKER_THREADINIT;

  static ManagedModules Mods;
  static std::unordered_map<llvm::Function *, uint64_t> FunctionCache;

  Module *NewM = NewF.getParent();

  // Fetch or Create a new ExecutionEngine for this Module.
  LIKWID_MARKER_START("polyjit.codegen");
  ExecutionEngine *EE = nullptr;
  if (!Mods.count(NewM)) {
    EE = getEngine(NewM);
    EE->finalizeObject();
    Mods[NewM] = EE;
  } else {
    EE = Mods[NewM];
  }
  LIKWID_MARKER_STOP("polyjit.codegen");

  if (!EE) {
    Console->error("no execution engine found.");
    return;
  }

  DEBUG(Console->warn("execution of {:>s} begins (#{:d} params)",
                      NewF.getName().str(), paramc));
  if (!FunctionCache.count(&NewF))
    FunctionCache.insert(
        std::make_pair(&NewF, EE->getFunctionAddress(NewF.getName().str())));
  uint64_t FPtr = FunctionCache[&NewF];
  void (*PF)(int, char **) = (void (*)(int, char **))FPtr;

  PF(paramc, params);
  DEBUG(Console->warn("execution of {:>s} completed", NewF.getName().str()));
}

static inline Function *getPrototype(const char *function) {
  static auto Console = spdlog::stderr_logger_mt("polli");
  LIKWID_MARKER_START("poyjit.prototype.get");
  Module &M = getModule(function);
  Function *F = getFunction(M);
  if (!F) {
    Console->error("Could not find a function in: {}", M.getModuleIdentifier());
    llvm_unreachable("Could not find a function in the prototype module");
    return 0;
  }
  LIKWID_MARKER_STOP("poyjit.prototype.get");
  return F;
}

static void printArgs(const Function &F, size_t argc, char **params) {
  static auto Console = spdlog::stderr_logger_st("polli");

  std::string buf;
  llvm::raw_string_ostream s(buf);
  F.getType()->print(s);
  Console->warn(s.str());
  for (size_t i = 0; i < argc; i++) {
    Console->warn("[{}] -> {:d} - {}", i, (*(uint64_t *)params[i]),
                  (void *)(params[i]));
  }
}

static void printRunValues(const RunValueList & Values) {
  static auto Console = spdlog::stderr_logger_st("polli");

  for (auto &RV : Values) {
    Console->warn("{} matched against {}", RV.value, (void *)RV.Arg);
  }
}

static RunValueList runValues(Function *F, unsigned paramc, void *params) {
  LIKWID_MARKER_START("polyjit.params.select");
  int i = 0;
  RunValueList RunValues;

  for (const Argument &Arg : F->args()) {
    RunValues.add({ (*((uint64_t **)params)[i]), &Arg });
    i++;
  }
  LIKWID_MARKER_STOP("polyjit.params.select");
  return RunValues;
}

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
  static auto Console = spdlog::stderr_logger_mt("polli");
  Function *F = getPrototype(fName);
  RunValueList values = runValues(F, paramc, params);

  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  VariantFunctionTy VarFun = Disp.getOrCreateVariantFunction(F);

  Function *NewF = VarFun->getOrCreateVariant(values);
  DEBUG(printArgs(*F, paramc, params));
  DEBUG(printRunValues(values));
  runSpecializedFunction(*NewF, paramc, params);
}
}
