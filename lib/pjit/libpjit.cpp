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
using UniqueMod = std::unique_ptr<Module>;
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;

static StackTracePtr StackTrace;
static FunctionDispatcher Disp;
static auto Console = spdlog::stderr_logger_st("polli");

static Module &getModule(const char *prototype) {
  static DenseMap<const char *, UniqueMod> ModuleIndex;

  if(!ModuleIndex.count(prototype)) {
    LLVMContext &Ctx = llvm::getGlobalContext();
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;

    UniqueMod Mod = parseIR(Buf, Err, Ctx);
    if (UniqueMod Mod = parseIR(Buf, Err, Ctx)) {
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

static Function *getFunction(Module &M) {
  Disp.setPrototypeMapping(M.begin(), M.begin());
  return M.begin();
}

static inline void do_shutdown() {
  LIKWID_MARKER_STOP("main-thread");
  LIKWID_MARKER_CLOSE;
  Console->warn("PolyJIT shut down.");
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;
}

class StaticInitializer {
public:
  StaticInitializer() {
    Console->warn("loading polyjit");
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
};
} // end of anonymous namespace

extern "C" {
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
static void runSpecializedFunction(
    llvm::Function *NewF, const ArrayRef<GenericValue> &ArgValues) {
  assert(NewF && "Cannot execute a NULL function!");
  static ManagedModules SpecializedModules;

  Module *NewM = NewF->getParent();

  // Fetch or Create a new ExecutionEngine for this Module.
  if (!SpecializedModules.count(NewM)) {
    LIKWID_MARKER_START("CodeGenJIT");
    ExecutionEngine *EE = PolyJIT::GetEngine(NewM);
    Console->warn("new engine registered");
    SpecializedModules[NewM] = EE;
    SpecializedModules[NewM]->finalizeObject();
    LIKWID_MARKER_STOP("CodeGenJIT");
    Console->warn("code generation complete");
  }

  LIKWID_MARKER_START(NewF->getName().str().c_str());
  ExecutionEngine *NewEE = SpecializedModules[NewM];

  if (NewEE) {
    LIKWID_MARKER_THREADINIT;

    Console->warn("execution of {:>s} begins", NewF->getName().str());
    void *FPtr = NewEE->getPointerToFunction(NewF);
    int (*PF)(int, char *) = (int(*)(int, char *))(intptr_t)FPtr;

    // Call the function.
    GenericValue rv;
    rv.IntVal = APInt(32, PF(ArgValues[0].IntVal.getZExtValue(),
                             (char *)GVTOP(ArgValues[1])));
    Console->warn("execution of {:>s} completed", NewF->getName().str());
  } else {
    Console->error("no execution engine found.");
  }
  LIKWID_MARKER_STOP(NewF->getName().str().c_str());
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
void pjit_main(const char *fName, unsigned paramc, void *params) {
  static StaticInitializer InitializeEverything;

  Module &M = getModule(fName);
  Function *F = getFunction(M);
  if (!F) {
    Console->error("Could not find a function in: {}", M.getModuleIdentifier());
    return;
  }

  auto DebugFn = [](Function &F, int argc, void *params) -> std::string {
    std::stringstream res;

    int i = 0;
    for (Argument &Arg : F.args()) {
      if (i > 0)
        res << ", ";
      if (Arg.getType()->isPointerTy()) {
        res << ((uint32_t **)params)[i++];
      } else {
        res << *((uint32_t **)params)[i++];
      }
    }

    return res.str();
  };
  std::string paramlist = DebugFn(*F, paramc, params);
  Console->warn("running with params: #{:d} ({:s})", paramc, paramlist);

  LIKWID_MARKER_START("JitSelectParams");

  std::vector<Param> ParamV;
  Console->warn("fetching runtime parameters:");
  getRuntimeParameters(F, paramc, params, ParamV);

  ParamVector<Param> Params(std::move(ParamV));
  Console->warn("fetched: {:>s}", Params.getShortName().str());
  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  Console->warn("create new variant for: {:>s}", F->getName().str());
  VariantFunctionTy VarFun = Disp.getOrCreateVariantFunction(F);
  VarFun->print(outs() << "created: ");

  SmallVector<GenericValue, 2> Args;
  Args[0].IntVal = APInt(32, F->arg_size(), false);
  Args[1] = PTOGV(params);
  LIKWID_MARKER_STOP("JitSelectParams");

  Stats &S = VarFun->stats();
  LIKWID_MARKER_START("JitOptVariant");
  Function *NewF = VarFun->getOrCreateVariant(Params);
  if (!NewF)
    Console->error("variant generation failed.");
  LIKWID_MARKER_STOP("JitOptVariant");

  runSpecializedFunction(NewF, Args);
  S.ExecCount++;
}
}
