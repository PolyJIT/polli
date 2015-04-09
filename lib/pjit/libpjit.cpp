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

#include "spdlog/spdlog.h"

#include <vector>

using namespace llvm;
using namespace polli;

namespace {
static FunctionDispatcher Disp;
auto Console = spdlog::stderr_logger_st("polli");

using UniqueMod = std::unique_ptr<Module>;

static Module &getModule(const char *prototype) {
  static DenseMap<const char *, UniqueMod> ModuleIndex;
  
  if(!ModuleIndex.count(prototype)) {
    LLVMContext &Ctx = llvm::getGlobalContext();
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;
    
    std::unique_ptr<Module> Mod = parseIR(Buf, Err, Ctx);
    Console->warn("Prototype module {} registered.", Mod->getModuleIdentifier());
    ModuleIndex.insert(std::make_pair(prototype, std::move(Mod)));
  } 
  
  return *ModuleIndex[prototype];
}

static Function *getFunction(Module &M) {
  Disp.setPrototypeMapping(M.begin(), M.begin());
  return M.begin();
}

class StaticInitializer {
public:
  StaticInitializer() {
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

  /* Let's hope that we have called it before ;-)
   * Otherwise it will blow up. FIXME: Don't blow up. */
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
