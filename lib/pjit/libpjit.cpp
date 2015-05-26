#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Triple.h"
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
#include <likwid.h>

#include <vector>
#include <cstdlib>

using namespace llvm;
using namespace polli;

namespace {
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;

static StackTracePtr StackTrace;
static FunctionDispatcher Disp;
/**
 * @brief Likwid requires initialization per thread.
 *
 */
static __thread bool likwid_thread_initialized = false;

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
  LIKWID_MARKER_STOP("main-thread");
  LIKWID_MARKER_CLOSE;
  static auto Console = spdlog::stderr_logger_st("polli");
  DEBUG(Console->debug("PolyJIT shut down."));
}

static inline void set_options_from_environment() {
  opt::DisableRecompile = std::getenv("POLLI_DISABLE_RECOMPILATION") != nullptr;

  if (char *OLvl = std::getenv("POLLI_OPT_LEVEL"))
    opt::OptLevel = *OLvl;

  opt::EmitJitDebugInfo = std::getenv("POLLI_EMIT_JIT_DEBUG_INFO") != nullptr;
}

class StaticInitializer {
public:
  StaticInitializer() {

    static auto Console = spdlog::stderr_logger_st("polli");
    Console->debug("loading polyjit");
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
  auto MemMan =
      std::unique_ptr<PolyJITMemoryManager>(new PolyJITMemoryManager());

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
  builder.setMCJITMemoryManager(std::move(MemMan));
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
  if (!likwid_thread_initialized) {
    LIKWID_MARKER_THREADINIT;
    likwid_thread_initialized = true;
  }

  static ManagedModules Mods;

  Module *NewM = NewF.getParent();

  // Fetch or Create a new ExecutionEngine for this Module.
  LIKWID_MARKER_START("CodeGenJIT");
  ExecutionEngine *EE = nullptr;
  if (!Mods.count(NewM)) {
    EE = getEngine(NewM);
    EE->finalizeObject();
    Mods[NewM] = EE;
  } else
    EE = Mods[NewM];
  LIKWID_MARKER_STOP("CodeGenJIT");

  if (EE) {
    LIKWID_MARKER_START(NewF.getName().str().c_str());
    DEBUG(Console->debug("execution of {:>s} begins (#{:d} params)",
                  NewF.getName().str(), paramc));
    void *FPtr = EE->getPointerToFunction(&NewF);
    void (*PF)(int, char **) = (void (*)(int, char **))FPtr;
    PF(paramc, params);
    DEBUG(Console->debug("execution of {:>s} completed", NewF.getName().str()));
    LIKWID_MARKER_STOP(NewF.getName().str().c_str());
  } else {
    Console->error("no execution engine found.");
  }
}

extern "C" {
StaticInitializer InitializeEverything;
/**
 * @brief Runtime callback for PolyJIT.
 *
 * All calls to the PolyJIT runtime will land here.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
int pjit_main(const char *fName, unsigned paramc, char **params) {
  static auto Console = spdlog::stderr_logger_st("polli");

  LIKWID_MARKER_START("GetOrParsePrototype");
  Module &M = getModule(fName);
  Function *F = getFunction(M);
  if (!F) {
    Console->error("Could not find a function in: {}", M.getModuleIdentifier());
    return 0;
  }
  LIKWID_MARKER_STOP("GetOrParsePrototype");

  auto DebugFn = [](Function &F, int argc, void *params) -> std::string {
    std::stringstream res;

    int i = 0;
    for (Argument &Arg : F.args()) {
      if (i > 0)
        res << ", ";
      if (Arg.getType()->isPointerTy()) {
        res << ((uint64_t **)params)[i++];
      } else {
        res << ((uint32_t **)params)[i++][0];
      }
    }

    return res.str();
  };

  LIKWID_MARKER_START("JitSelectParams");

  std::vector<Param> ParamV;
  getRuntimeParameters(F, paramc, params, ParamV);

  ParamVector<Param> Params(std::move(ParamV));
  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  VariantFunctionTy VarFun = Disp.getOrCreateVariantFunction(F);

  LIKWID_MARKER_STOP("JitSelectParams");

  // Stats &S = VarFun->stats();
  if (Function *NewF = VarFun->getOrCreateVariant(Params)) {
    std::string paramlist = DebugFn(*F, paramc, params);
    DEBUG(
        Console->debug("running with params: #{:d} ({:s})", paramc, paramlist));
    runSpecializedFunction(*NewF, paramc, params);
  } else
    llvm_unreachable("FIXME: call the old prototype.");

  // S.ExecCount++;
  return 0;
}
}