#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ExecutionEngine/GenericValue.h"

#include "llvm/Support/MemoryBuffer.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

#include "pprof/Tracing.h"
#include "polli/PolyJIT.h"
#include "polli/VariantFunction.h"
#include "polli/FunctionDispatcher.h"
#include "polly/RegisterPasses.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/PrettyStackTrace.h"

#include "spdlog/spdlog.h"

#include <vector>
#include <cstdlib>

using namespace llvm;
using namespace polli;

namespace {
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;
StackTracePtr StackTrace;

static FunctionDispatcher Disp;
auto Console = spdlog::stderr_logger_st("polli");

using UniqueMod = std::unique_ptr<Module>;

static Module &getModule(const char *prototype) {
  static DenseMap<const char *, UniqueMod> ModuleIndex;

  if(!ModuleIndex.count(prototype)) {
    LLVMContext &Ctx = llvm::getGlobalContext();
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;

    UniqueMod Mod = parseIR(Buf, Err, Ctx);
    if (Mod)
      Console->warn("Prototype registered.");
    else {
      Console->error("{:s}:{:d}:{:d} {:s}", Err.getFilename().str(),
                     Err.getLineNo(), Err.getColumnNo(),
                     Err.getMessage().str());
      Console->error("{:s}", prototype);
    }
    ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
  }

  return *ModuleIndex[prototype];
}

static Function *getFunction(Module &M) {
  Disp.setPrototypeMapping(M.begin(), M.begin());
  return M.begin();
}

static void do_shutdown() {
  LIKWID_MARKER_STOP("main-thread");
  LIKWID_MARKER_CLOSE;
  Console->warn("PolyJIT shut down.");
}

static void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;
}

class StaticInitializer {
public:
  StaticInitializer() {
    Console->warn("PolyJIT activated.");
    StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

    LIKWID_MARKER_INIT;
    LIKWID_MARKER_START("main-thread");

    atexit(do_shutdown);
    set_options_from_environment();

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

  ~StaticInitializer() {
    do_shutdown();
  }
};
static StaticInitializer InitializeEverything;
} // end of anonymous namespace

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
  Module &M = getModule(fName);
  Function *F = getFunction(M);
  if (!F) {
    Console->error("Could not find a function in: {}", M.getModuleIdentifier());
    return;
  }

  LIKWID_MARKER_START("JitSelectParams");

  std::vector<Param> ParamV;
  getRuntimeParameters(F, paramc, params, ParamV);

  ParamVector<Param> Params(std::move(ParamV));
  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  VariantFunctionTy VarFun = Disp.getOrCreateVariantFunction(F);

  std::vector<GenericValue> ArgValues(2);
  GenericValue ArgC;
  ArgC.IntVal = APInt(sizeof(size_t) * 8, F->arg_size(), false);
  ArgValues[0] = ArgC;
  ArgValues[1] = PTOGV(params);
  LIKWID_MARKER_STOP("JitSelectParams");

  Stats &S = VarFun->stats();
  LIKWID_MARKER_START("JitOptVariant");
  Function *NewF = VarFun->getOrCreateVariant(Params);
  LIKWID_MARKER_STOP("JitOptVariant");

  PolyJIT::runSpecializedFunction(NewF, ArgValues);
  S.ExecCount++;
}
}
