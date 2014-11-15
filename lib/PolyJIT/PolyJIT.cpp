//===-- PolyJIT.cpp - LLVM Just in Time Compiler --------------------------===//
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
#define DEBUG_TYPE "polyjit"
#include "polli/PolyJIT.h"

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/Twine.h"

#include "llvm/Analysis/Passes.h"

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/JITEventListener.h"
#include "llvm/ExecutionEngine/JITMemoryManager.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/ExecutionEngine/ObjectCache.h"
#include "llvm/ExecutionEngine/MCJIT.h"

#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constant.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"

#include "llvm/Linker/Linker.h"

#include "llvm/Pass.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassManager.h"
#include "llvm/PassRegistry.h"

#include "llvm/Support/Casting.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Target/TargetOptions.h"

#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"
#include "polly/ScopDetection.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/ScopInfo.h"
#include "polly/ScopPass.h"
#include "polly/TempScopInfo.h"

#include "polli/FunctionCloner.h"
#include "polli/FunctionDispatcher.h"
#include "polli/InstrumentRegions.h"
#include "polli/JitScopDetection.h"
#include "polli/PapiProfiling.h"
#include "polli/ScopMapper.h"
#include "polli/Utils.h"
#include "polli/AliasCheckCodeGen.h"

#include "pprof/Tracing.h"

#include <numeric>
#include <assert.h>
#include <ext/alloc_traits.h>
#include <stddef.h>
#include <stdlib.h>
#include <map>
#include <memory>
#include <utility>

namespace llvm {
class LLVMContext;
} // lines 65-65
namespace llvm {
class Region;
} // lines 66-66
namespace llvm {
class Value;
} // lines 67-67

cl::OptionCategory PolliCategory("Polli Options",
                                 "Configure the runtime options of polli");

using namespace polli;
using namespace polly;
using namespace llvm;

namespace polli {
Pass *createPapiCScopProfilingPass() { return new PapiCScopProfiling(); }
}

namespace {
cl::opt<bool>
    EnableCaddy("caddy",
                cl::desc("Enable Caddy. Requires the 'caddy' branch of polly."),
                cl::init(false), cl::cat(PolliCategory));

cl::opt<bool> InstrumentRegions("instrument",
                                cl::desc("Enable instrumenting of SCoPs"),
                                cl::init(false), cl::cat(PolliCategory));

cl::opt<bool> EnableJitable("jitable", cl::desc("Enable JIT extensions."),
                            cl::init(false), cl::cat(PolliCategory));

cl::opt<bool> DisableRecompile("no-recompilation",
                               cl::desc("Disable recompilation of SCoPs"),
                               cl::init(false), cl::cat(PolliCategory));

cl::opt<bool> DisableExecution(
    "no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::init(false), cl::cat(PolliCategory));

cl::opt<bool> AnalyzeIR(
    "polli-analyze",
    cl::desc("Only analyze the IR. This disables recompilation & execution."),
    cl::init(false), cl::cat(PolliCategory));

cl::opt<char> OptLevel("O",
                       cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
                                "(default = '-O2')"),
                       cl::Prefix, cl::ZeroOrMore, cl::init(' '));

cl::opt<std::string> OutputFilename("o", cl::desc("Override output filename"),
                                    cl::value_desc("filename"));

cl::opt<std::string>
    TargetTriple("mtriple", cl::desc("Override target triple for module"));

cl::opt<std::string>
    MArch("march",
          cl::desc("Architecture to generate assembly for (see --version)"));

cl::opt<std::string>
    MCPU("mcpu",
         cl::desc("Target a specific cpu type (-mcpu=help for details)"),
         cl::value_desc("cpu-name"), cl::init(""));

cl::list<std::string>
    MAttrs("mattr", cl::CommaSeparated,
           cl::desc("Target specific attributes (-mattr=help for details)"),
           cl::value_desc("a1,+a2,-a3,..."));

cl::opt<Reloc::Model> RelocModel(
    "relocation-model", cl::desc("Choose relocation model"),
    cl::init(Reloc::Default),
    cl::values(
        clEnumValN(Reloc::Default, "default",
                   "Target default relocation model"),
        clEnumValN(Reloc::Static, "static", "Non-relocatable code"),
        clEnumValN(Reloc::PIC_, "pic",
                   "Fully relocatable, position independent code"),
        clEnumValN(Reloc::DynamicNoPIC, "dynamic-no-pic",
                   "Relocatable external references, non-relocatable code"),
        clEnumValEnd));

cl::opt<llvm::CodeModel::Model> CMModel(
    "code-model", cl::desc("Choose code model"),
    cl::init(CodeModel::JITDefault),
    cl::values(clEnumValN(CodeModel::JITDefault, "default",
                          "Target default JIT code model"),
               clEnumValN(CodeModel::Small, "small", "Small code model"),
               clEnumValN(CodeModel::Kernel, "kernel", "Kernel code model"),
               clEnumValN(CodeModel::Medium, "medium", "Medium code model"),
               clEnumValN(CodeModel::Large, "large", "Large code model"),
               clEnumValEnd));

cl::opt<bool>
    EnableJITExceptionHandling("jit-enable-eh",
                               cl::desc("Emit exception handling information"),
                               cl::init(false));

cl::opt<bool> GenerateSoftFloatCalls(
    "soft-float", cl::desc("Generate software floating point library calls"),
    cl::init(false));

cl::opt<llvm::FloatABI::ABIType> FloatABIForCalls(
    "float-abi", cl::desc("Choose float ABI type"), cl::init(FloatABI::Default),
    cl::values(clEnumValN(FloatABI::Default, "default",
                          "Target default float ABI type"),
               clEnumValN(FloatABI::Soft, "soft",
                          "Soft float ABI (implied by -soft-float)"),
               clEnumValN(FloatABI::Hard, "hard",
                          "Hard float ABI (uses FP registers)"),
               clEnumValEnd));

cl::opt<bool>
// In debug builds, make this default to true.
#ifdef NDEBUG
#define EMIT_DEBUG false
#else
#define EMIT_DEBUG true
#endif
    EmitJitDebugInfo("jit-emit-debug",
                     cl::desc("Emit debug information to debugger"),
                     cl::init(EMIT_DEBUG));
#undef EMIT_DEBUG

cl::opt<bool>
    EmitJitDebugInfoToDisk("jit-emit-debug-to-disk", cl::Hidden,
                           cl::desc("Emit debug info objfiles to disk"),
                           cl::init(false));

class StaticInitializer {
public:
  StaticInitializer() {
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    initializePollyPasses(Registry);
    initializePapiRegionPreparePass(Registry);
    initializePapiCScopProfilingPass(Registry);
    initializePapiCScopProfilingInitPass(Registry);
  }
};
}

static StaticInitializer InitializeEverything;
static FunctionDispatcher *Disp = new FunctionDispatcher();

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
static void pjit_callback(const char *fName, unsigned paramc, char **params) {
  /* Let's hope that we have called it before ;-)
   * Otherwise it will blow up. FIXME: Don't blow up. */
  PolyJIT *JIT = PolyJIT::Get();

  LIKWID_MARKER_START("ParamSel");
  /* Be very careful here, we want to exit this callback asap to cut down on
   * overhead. Think about triggering any modifications to the underlying IR
   * in a concurrent thread instead of b tlocking everything here. */
  Module &M = JIT->getExecutedModule();
  Function *F = M.getFunction(fName);
  if (!F)
    llvm_unreachable("Function not in this module. It has to be there!");

  std::vector<Param> ParamV;
  getRuntimeParameters(F, paramc, params, ParamV);

  ParamVector<Param> Params(std::move(ParamV));

  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  VariantFunctionTy VarFun = Disp->getOrCreateVariantFunction(F);

  std::vector<GenericValue> ArgValues(2);
  GenericValue ArgC;
  ArgC.IntVal = APInt(sizeof(size_t) * 8, F->arg_size(), false);
  ArgValues[0] = ArgC;
  ArgValues[1] = PTOGV(params);
  LIKWID_MARKER_STOP("ParamSel");

  Stats &S = VarFun->stats();
  LIKWID_MARKER_START("GenVarFun");
  Function *NewF = VarFun->getOrCreateVariant(Params);
  LIKWID_MARKER_STOP("GenVarFun");

  LIKWID_MARKER_START(NewF->getName().str().c_str());
  JIT->runSpecializedFunction(NewF, ArgValues);
  LIKWID_MARKER_STOP(NewF->getName().str().c_str());

  S.ExecCount++;
}
}

namespace polli {
static uint64_t __polli_dso_handle = 1;

/**
 * @brief Print statistics about the memory consumption for this manager.
 *
 * @param OS the outstream we print to.
 */
void PolyJITMemoryManager::print(llvm::raw_ostream &OS) {
  log(Info) << "Memory consumption:\n";
  log(Info, 2) << "Allocated CodeSections: " << NumAllocatedCodeSections
               << "\n";
  log(Info, 2) << "Allocated DataSections: " << NumAllocatedDataSections
               << "\n";
  log(Info, 2) << "Allocated kBytes: " << AllocatedBytes / 1024 << "\n";
}

PolyJITMemoryManager::~PolyJITMemoryManager() {
}

uint64_t
PolyJITMemoryManager::getSymbolAddress(const std::string &Name) {
  if (Name.find("__dso_handle") != std::string::npos)
    return __polli_dso_handle;
  return SectionMemoryManager::getSymbolAddress(Name);
}

/**
 * @brief Allocate a new code section.
 *
 * We just override it to track the amount of memory allocated.
 *
 * @param Size
 * @param Alignment
 * @param SectionID
 * @param SectionName
 *
 * @return pointer to the allocated code section.
 */
uint8_t *
PolyJITMemoryManager::allocateCodeSection(uintptr_t Size, unsigned Alignment,
                                          unsigned SectionID,
                                          StringRef SectionName) {
  AllocatedBytes += Size;
  NumAllocatedCodeSections++;
  return SectionMemoryManager::allocateCodeSection(Size, Alignment, SectionID,
                                                   SectionName);
}

/**
 * @brief Allocate a new data section.
 *
 * We just override it to track the amount of memory allocated.
 *
 * @param Size
 * @param Alignment
 * @param SectionID
 * @param SectionName
 * @param IsReadOnly
 *
 * @return pointer to the allocated data section
 */
uint8_t *PolyJITMemoryManager::allocateDataSection(uintptr_t Size,
                                                   unsigned Alignment,
                                                   unsigned SectionID,
                                                   StringRef SectionName,
                                                   bool IsReadOnly) {
  AllocatedBytes += Size;
  NumAllocatedDataSections++;
  return SectionMemoryManager::allocateDataSection(Size, Alignment, SectionID,
                                                   SectionName, IsReadOnly);
}

PolyJIT::PolyJIT(Module &Main) : M(Main) {
  CodeGenOpt::Level OLvl = CodeGenOpt::Default;
  switch (OptLevel) {
  default:
    OLvl = CodeGenOpt::Default;
    break;
  case ' ':
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

  Options.UseSoftFloat = GenerateSoftFloatCalls;
  if (FloatABIForCalls != FloatABI::Default)
    Options.FloatABIType = FloatABIForCalls;
  if (GenerateSoftFloatCalls)
    FloatABIForCalls = FloatABI::Soft;

  // Remote target execution doesn't handle EH or debug registration.
  Options.JITEmitDebugInfo = EmitJitDebugInfo;
  Options.JITEmitDebugInfoToDisk = EmitJitDebugInfoToDisk;

  EE = GetEngine(&M);

  // The following functions have no effect if their respective profiling
  // support wasn't enabled in the build configuration.
  EE->RegisterJITEventListener(
      JITEventListener::createOProfileJITEventListener());
  EE->RegisterJITEventListener(
      JITEventListener::createIntelJITEventListener());
}

/**
 * @brief Get a new Execution engine for the given module.
 *
 * @param M The module that needs a new execution engine.
 *
 * @return A new execution engine for M.
 */
ExecutionEngine *PolyJIT::GetEngine(Module *M) {
  std::string ErrorMsg;

  // If we are supposed to override the target triple, do so now.
  if (!TargetTriple.empty())
    M->setTargetTriple(Triple::normalize(TargetTriple));

  std::unique_ptr<Module> Owner(M);

  EngineBuilder builder(std::move(Owner));

  builder.setMArch(MArch);
  builder.setMCPU(MCPU);
  builder.setMAttrs(MAttrs);
  builder.setRelocationModel(RelocModel);
  builder.setCodeModel(CMModel);
  builder.setErrorStr(&ErrorMsg);
  builder.setEngineKind(EngineKind::JIT);
  builder.setMCJITMemoryManager(&MemMan);
  builder.setOptLevel(OLvl);
  builder.setTargetOptions(Options);

  return builder.create();
}

/**
 * @brief Run a specialized version of a function.
 *
 * The specialized version needs to be in 'main' form, i.e., its signature
 * has to be:
 *  void fn_name(int argc, char **argv);
 *
 * The FunctionCloner's MainCreator policy takes care of that. All the real
 * parameters are passed via argv.
 *
 * @param NewF the specialized function in main form.
 * @param ArgValues the parameter _values_ for the formal parameters.
 */
void
PolyJIT::runSpecializedFunction(llvm::Function *NewF,
                                const std::vector<GenericValue> &ArgValues) {
  assert(NewF && "Cannot execute a NULL function!");

  Module *NewM = NewF->getParent();
  ExecutionEngine *NewEE;

  assert(NewM && "Passed function parameter has no parent module!");

  // Fetch or Create a new ExecutionEngine for this Module.
  if (!SpecializedModules.count(NewM)) {
    SpecializedModules[NewM] = PolyJIT::GetEngine(NewM);
    LIKWID_MARKER_START("CodeGenJIT");
    SpecializedModules[NewM]->finalizeObject();
    LIKWID_MARKER_STOP("CodeGenJIT");
  }

  NewEE = SpecializedModules[NewM];

  assert(NewEE && "Failed to create a new ExecutionEngine for this module!");
  NewEE->runFunction(NewF, ArgValues);
}

/**
 * @brief Place the call to the polli runtime inside all extracted SCoPs.
 *
 * @param M
 * @param Mods the set of managed modules.
 */
void PolyJIT::instrumentScops(Module &M, ManagedModules &Mods) {
  DEBUG(log(LogType::Info) << "inject :: insert call to JIT runtime\n");
  LLVMContext &Ctx = M.getContext();
  IRBuilder<> Builder(Ctx);

  PointerType *PtoArr = PointerType::get(Type::getInt8PtrTy(Ctx), 0);
  StringRef cbName = StringRef("polli.enter.runtime");

  /* Insert callback declaration & call into each extracted module */
  for (ManagedModules::iterator i = Mods.begin(), ie = Mods.end(); i != ie;
       ++i) {
    Module *ScopM = (*i).first;
    Function *PJITCB = cast<Function>(ScopM->getOrInsertFunction(
        cbName, Type::getVoidTy(Ctx), Type::getInt8PtrTy(Ctx),
        Type::getInt32Ty(Ctx), PtoArr, NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);
    EE->addGlobalMapping(PJITCB, (void *)&pjit_callback);

    std::vector<Value *> Args(3);

    /* Inject call to callback declaration into every function */
    for (Module::iterator F = ScopM->begin(), FE = ScopM->end(); F != FE; ++F) {
      if (F->isDeclaration())
        continue;
      BasicBlock *BB = F->begin();
      Builder.SetInsertPoint(BB->getFirstInsertionPt());

      /* Create a generic IR sequence of this example C-code:
       *
       * void foo(int n, int A[42]) {
       *  void *params[2];
       *  params[0] = &n;
       *  params[1] = &A;
       *
       *  pjit_callback("foo", 2, params);
       * }
       */

      /* Prepare a stack array for the parameters. We will pass a pointer to
       * this array into our callback function. */
      int argc = F->arg_size();
      Value *ParamC = ConstantInt::get(Type::getInt32Ty(Ctx), argc, true);
      Value *Params =
          Builder.CreateAlloca(Type::getInt8PtrTy(Ctx), ParamC, "params");

      /* Store each parameter as pointer in the params array */
      int i = 0;
      Value *One = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
      for (Function::arg_iterator Arg = F->arg_begin(), ArgE = F->arg_end();
           Arg != ArgE; ++Arg) {

        /* Allocate a slot on the stack for the i'th argument and store it */
        Value *Slot =
            Builder.CreateAlloca(Arg->getType(), One, "params." + Twine(i));
        Builder.CreateStore(Arg, Slot);

        /* Bitcast the allocated stack slot to i8* */
        Value *Slot8 = Builder.CreateBitCast(Slot, Type::getInt8PtrTy(Ctx),
                                             "ps.i8ptr." + Twine(i));

        /* Get the appropriate slot in the parameters array and store
         * the stack slot in form of a i8*. */
        Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i);
        Value *Dest = Builder.CreateGEP(Params, ArrIdx, "p." + Twine(i));
        Builder.CreateStore(Slot8, Dest);

        i++;
      }

      Args[0] = Builder.CreateGlobalStringPtr(F->getName());
      Args[1] = ParamC;
      Args[2] = Params;

      Builder.CreateCall(PJITCB, Args);
    }
  }
}

/**
 * @brief Link extracted Scops into a module for execution.
 *
 * @param The set of managed modules to link into a single one.
 * @param The module to link into.
 */
void PolyJIT::linkJitableScops(ManagedModules &Mods, Module &M) {
  /* We need to link the functions back in for execution */
  for (ManagedModules::iterator src = Mods.begin(), se = Mods.end(); src != se;
       ++src) {
    Module *SrcM = (*src).first;
    DEBUG(log(Info, 2) << "link :: " << SrcM->getModuleIdentifier() << "\n");
    Linker::LinkModules(&M, SrcM, [](const DiagnosticInfo &Info) {
      DiagnosticPrinterRawOStream OS(errs());
      Info.print(OS);
    });
  }

  StringRef cbName = StringRef("polli.enter.runtime");
  /* Register our callback with the system linker, so the MCJIT can find it
   * during object compilation */
  sys::DynamicLibrary::AddSymbol(cbName, (void *)&pjit_callback);
}

static ModulePtrT copyModule(Module &M) {
  ModulePtrT NewM = new Module(M.getModuleIdentifier(), M.getContext());
  NewM->setTargetTriple(M.getTargetTriple());
  NewM->setDataLayout(M.getDataLayout());
  NewM->setMaterializer(M.getMaterializer());

  return NewM;
}

/**
 * @brief Extract all jitable Scops into a separate module
 *
 * @param The module to extract all jitable Scops from
 */
void PolyJIT::extractJitableScops(Module &M) {
  LIKWID_MARKER_START("ExtractScops");
  PassManager PM;
  PM.add(new DataLayoutPass());

  if (InstrumentRegions)
    PM.add(new PapiCScopProfilingInit());

  PM.add(llvm::createTypeBasedAliasAnalysisPass());
  PM.add(llvm::createBasicAliasAnalysisPass());
  PM.add(polly::createScopDetectionPass());
  PM.add(new JitScopDetection(EnableJitable));
  PM.add(new AliasCheckGenerator());

  ScopMapper *SM = new ScopMapper();
  if (!DisableRecompile)
    PM.add(SM);

  if (InstrumentRegions)
    PM.add(polli::createPapiCScopProfilingPass());

  PM.run(M);

  DEBUG(log(Info, 2) << "link :: create final module\n");
  ValueToValueMapTy VMap;
  ModulePtrT MoveTargetMod;
  ModulePtrT InstrumentTargetMod;
  StringRef ModuleName = M.getModuleIdentifier();

  /* Move the extracted SCoP functions into separate modules. */
  for (ScopMapper::iterator f = SM->begin(), fe = SM->end(); f != fe; ++f) {
    Function *F = (*f);
    StringRef FunctionName = F->getName();

    /* Prepare a fresh module for this function. */
    MoveTargetMod = copyModule(M);
    InstrumentTargetMod = copyModule(M);
    MoveTargetMod->setModuleIdentifier((ModuleName + "." + FunctionName).str() +
                                       ".prototype");
    InstrumentTargetMod->setModuleIdentifier(
        (ModuleName + "." + FunctionName + ".instrumented").str());

    RawModules[MoveTargetMod] = EE;
    InstrumentedModules[InstrumentTargetMod] = EE;

    MovingFunctionCloner MoveCloner(VMap, MoveTargetMod);
    InstrumentingFunctionCloner InstCloner(VMap, InstrumentTargetMod);

    MoveCloner.setSource(F);
    Function *OrigF = MoveCloner.start();

    InstCloner.setSource(OrigF);
    InstCloner.setSinkHostPass(SM);
    Function *InstF = InstCloner.start();

    // This maps the function name in the source module to the instrumented
    // version in the extracted version.
    F->setName(InstF->getName());

    // Remove the mess we made during instrumentation.
    FunctionPassManager NewFPM(InstrumentTargetMod);
    NewFPM.add(llvm::createPromoteMemoryToRegisterPass());
    NewFPM.add(llvm::createTypeBasedAliasAnalysisPass());
    NewFPM.add(llvm::createBasicAliasAnalysisPass());
    polly::registerCanonicalicationPasses(NewFPM);

    NewFPM.run(*InstF);

    // Set up the mapping for this prototype.
    Disp->setPrototypeMapping(InstF, OrigF);
  }

  if (OutputFilename.size() == 0)
    StoreModule(M, M.getModuleIdentifier() + ".extr");
  LIKWID_MARKER_STOP("ExtractScops");
}

/**
 * @brief Optimize the module before executing it for the first time.
 *
 * @param M The 'main' module we prepare for execution.
 */
void PolyJIT::prepareOptimizedIR(Module &M) {
  PassManager PM;

  polly::ScopDetection *SD =
      (polly::ScopDetection *)polly::createScopDetectionPass();

  PM.add(new DataLayoutPass());
  PM.add(llvm::createTypeBasedAliasAnalysisPass());
  PM.add(llvm::createBasicAliasAnalysisPass());
  PM.add(SD);
  PM.add(polly::createScopInfoPass());
  PM.add(polly::createIslScheduleOptimizerPass());
  PM.add(polly::createCodeGenerationPass());

  // Add O3.
  PassManagerBuilder Builder;
  Builder.Inliner = createFunctionInliningPass(OptLevel);
  Builder.OptLevel = OptLevel;
  Builder.populateModulePassManager(PM);

  FunctionPassManager FPM(&M);
  Builder.populateFunctionPassManager(FPM);

  // Optimize the functions.
  for (Function &F : M) {
    FPM.doInitialization();
    FPM.run(F);
    FPM.doFinalization();
  }

  // Optimize the whole module.
  PM.run(M);
}

/**
 * @brief Run the EntryFn. Starts this PolyJIT session.
 *
 * @param inputArgs
 * @param envp
 *
 * @return
 */
int PolyJIT::runMain(const std::vector<std::string> &inputArgs,
                     const char *const *envp) {
  /*
   * Initialize papi and prepare the event set.
   */
  Function *Main = M.getFunction(EntryFn);

  if (AnalyzeIR) {
    DisableExecution = true;
    DisableRecompile = true;
    log(Debug) << "opt :: AnalyzeIR disabled Execution & Recompilation.\n";
  }

  if (!Main && !AnalyzeIR) {
    log(Error) << '\'' << EntryFn << "\' function not found in module.\n";
    return -1;
  }

  /* Preoptimize our module for polly */
  runPollyPreoptimizationPasses(M);

  /* Extract suitable Scops */
  extractJitableScops(M);

  // FIXME: Why do we fail, if we do not strip them all off?!
  PassManager PM;
  PM.add(llvm::createStripSymbolsPass(true));
  PM.run(M);

  /* Store temporary files */
  StoreModules(RawModules);
  StoreModules(InstrumentedModules);

  /* Get the Scops back */
  linkJitableScops(InstrumentedModules, M);

  /* Optimize with O3&Polly */
  prepareOptimizedIR(M);

  /* Store module before execution */
  if (OutputFilename.size() > 0)
    StoreModule(M, OutputFilename);

  int ret = 0;
  // Make the object executable.
  EE->finalizeObject();

  if (!DisableExecution) {
    DEBUG(log(Info) << "run :: starting execution\n");

    // Run static constructors.
    EE->runStaticConstructorsDestructors(false);

    ret = EE->runFunctionAsMain(Main, inputArgs, envp);

    DEBUG(log(Info) << "run :: execution finished (" << ret << ")\n");
  }

  return ret;
}

/**
 * @brief Run Polly's default set of preoptimization on a module.
 *
 * @param The module to run the preoptimization on.
 */
void PolyJIT::runPollyPreoptimizationPasses(Module &M) {
  FunctionPassManager FPM(&M);

  registerCanonicalicationPasses(FPM);
  FPM.doInitialization();

  DEBUG(log(Info) << "preopt :: applying preoptimization:\n");
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe; ++f) {
    if (f->isDeclaration())
      continue;
    FPM.run(*f);
  }
  FPM.doFinalization();
}

/**
 * @brief Shutdown the JIT and clean up the mess we made.
 *
 * Before we actually do the cleanup, we print some nice stats about the
 * current session.
 *
 * @param result Our exit-code
 *
 * @return
 */
int PolyJIT::shutdown(int result) {
  LLVMContext &Context = M.getContext();

  VariantFunction::printHeader(log(Info));
  for (const auto &Elem : Disp->functions()) {
    VariantFunctionTy VarFun = Elem.second;
    VarFun->print(log(LogType::Info));
  }
  log(Info) << "\n";
  MemMan.print(log(Info));

  // Run static destructors.
  EE->runStaticConstructorsDestructors(true);

  // If the program doesn't explicitly call exit, we will need the Exit
  // function later on to make an explicit call, so get the function now.
  Constant *Exit = M.getOrInsertFunction("exit", Type::getVoidTy(Context),
                                         Type::getInt32Ty(Context), NULL);

  // If the program didn't call exit explicitly, we should call it now.
  // This ensures that any atexit handlers get called correctly.
  if (Function *ExitF = dyn_cast<Function>(Exit)) {
    std::vector<GenericValue> Args;
    GenericValue ResultGV;
    ResultGV.IntVal = APInt(32, result);
    Args.push_back(ResultGV);
    EE->runFunction(ExitF, Args);
    log(Error) << "ERROR: exit(" << result << ") returned!\n";
    abort();
  } else {
    log(Error) << "ERROR: exit defined with wrong prototype!\n";
    abort();
  }

  for (auto &JitModule : RawModules) {
    ExecutionEngine *EE = JitModule.second;
    if (EE)
      delete EE;
  }

  for (auto &JitModule : InstrumentedModules) {
    ExecutionEngine *EE = JitModule.second;
    if (EE)
      delete EE;
  }
};

PolyJIT *PolyJIT::Instance = NULL;
PolyJIT *PolyJIT::Get(Module *M) {
  if (!Instance) {
    Instance = new PolyJIT(*M);
  }
  return Instance;
};
} // end of llvm namespace
