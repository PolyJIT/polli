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
#include "llvm/Support/Debug.h"

#include "polli/PolyJIT.h"

#include "polly/RegisterPasses.h"
#include "polly/LinkAllPasses.h"

#include "llvm/PassManager.h"

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/ValueMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Assembly/PrintModulePass.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/CodeGen/JITCodeEmitter.h"
#include "llvm/CodeGen/MachineCodeInfo.h"
#include "llvm/Config/config.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/JITEventListener.h"
#include "llvm/ExecutionEngine/JITMemoryManager.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MutexGuard.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Target/TargetJITInfo.h"
#include "llvm/Target/TargetMachine.h"

#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include "llvm/Support/Path.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FileUtilities.h"

#include "llvm/Linker.h"

#include "polli/FunctionCloner.h"
#include "polli/FunctionDispatcher.h"
#include "polli/NonAffineScopDetection.h"
#include "polli/PapiProfiling.h"
#include "polli/InstrumentRegions.h"
#include "polli/ScopMapper.h"
#include "polli/Utils.h"

#include <set>
#include <map>

using namespace polli;
using namespace polly;
using namespace llvm;
using namespace llvm::sys::fs;

namespace fs = llvm::sys::fs;
namespace p = llvm::sys::path;

namespace polli {
Pass *createPapiRegionProfilingPass() { return new PapiRegionProfiling(); }
Pass *createPapiCScopProfilingPass() { return new PapiCScopProfiling(); }
}

namespace {
static cl::opt<bool> EnablePapi("papi", cl::desc("Instrument SCoPs with PAPI"
                                                 "counters."),
                                cl::init(false));

static cl::opt<bool>
EnableCaddy("caddy", cl::desc("Enable Caddy"), cl::init(false));

static cl::opt<bool>
InstrumentRegions("instrument", cl::desc("Enable instrumenting of SCoPs"),
                  cl::init(false));

static cl::opt<bool>
DisableRecompile("no-recompilation", cl::desc("Disable recompilation of SCoPs"),
                 cl::init(false));

static cl::opt<bool> DisableExecution(
    "no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::init(false));


// Determine optimization level.
cl::opt<char> OptLevel("O",
                       cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
                                "(default = '-O2')"),
                       cl::Prefix, cl::ZeroOrMore, cl::init(' '));

static cl::opt<std::string>
OutputFilename("o", cl::desc("Override output filename"),
               cl::value_desc("filename"));

cl::opt<std::string>
TargetTriple("mtriple", cl::desc("Override target triple for module"));

cl::opt<std::string>
MArch("march",
      cl::desc("Architecture to generate assembly for (see --version)"));

cl::opt<std::string>
MCPU("mcpu", cl::desc("Target a specific cpu type (-mcpu=help for details)"),
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

cl::opt<llvm::CodeModel::Model>
CMModel("code-model", cl::desc("Choose code model"),
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

static cl::opt<bool>
EmitJitDebugInfoToDisk("jit-emit-debug-to-disk", cl::Hidden,
                       cl::desc("Emit debug info objfiles to disk"),
                       cl::init(false));

cl::opt<bool> ForceInterpreter("force-interpreter",
                               cl::desc("Force interpretation: disable JIT"),
                               cl::init(false));

static cl::opt<bool> UseMCJIT("mcjit", cl::desc("Use MCJIT instead of old JIT"),
                              cl::init(false));

class StaticInitializer {
public:
  StaticInitializer() {
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    initializePollyPasses(Registry);
    initializePapiRegionPreparePass(Registry);
    initializePapiRegionProfilingPass(Registry);
    initializePapiCScopProfilingPass(Registry);
    initializePapiCScopProfilingInitPass(Registry);
  
    initializeOutputDir();
  }
};
}

static StaticInitializer InitializeEverything;
static FunctionDispatcher *Disp = new FunctionDispatcher();

extern "C" {
static void pjit_callback(const char *fName, unsigned paramc, char **params) {
  DEBUG(dbgs() << "[polli] Entering JIT runtime environment...\n");
  /* Let's hope that we have called it before ;-)
   * Otherwise it will blow up. FIXME: Don't blow up. */
  PolyJIT *JIT = PolyJIT::Get();

  /* Be very careful here, we want to exit this callback asap to cut down on
   * overhead. Think about triggering any modifications to the underlying IR
   * in a concurrent thread instead of blocking everything here. */
  Module &M = JIT->getExecutedModule();
  Function *F = M.getFunction(fName);

  if (!F)
    llvm_unreachable("Function not in this module. It has to be there!");

  RTParams RuntimeParams = getRuntimeParameters(F, paramc, params);
  ParamVector<RuntimeParam> PArr = RuntimeParams;

  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  Function *NewF = Disp->getFunctionForValues(F, PArr);

  std::vector<GenericValue> ArgValues(2);
  GenericValue ArgC;
  ArgC.IntVal = APInt(sizeof(size_t) * 8, F->arg_size(), false);
  ArgValues[0] = ArgC;
  ArgValues[1] = PTOGV(params);

  JIT->runSpecializedFunction(NewF, ArgValues);
}
}

class ScopDetectionResultsViewer : public FunctionPass {
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopDetectionResultsViewer(const ScopDetectionResultsViewer &);
  // DO NOT IMPLEMENT
  const ScopDetectionResultsViewer &operator=(
      const ScopDetectionResultsViewer &);

  ScopDetection *SD;

public:
  static char ID;
  explicit ScopDetectionResultsViewer() : FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetection>();
    AU.setPreservesAll();
  }
  ;

  virtual void releaseMemory() {};

  virtual bool runOnFunction(Function &F) {
    SD = &getAnalysis<ScopDetection>();

    polly::RejectedLog rl = SD->getRejectedLog();
    for (polly::RejectedLog::iterator i = rl.begin(), ie = rl.end(); i != ie;
         ++i) {
      const Region *R = (*i).first;
      std::vector<RejectInfo> rlog = (*i).second;

      if (R) {
        outs() << "[polli] rejected region: " << R->getNameStr() << "\n";

        for (unsigned n = 0; n < rlog.size(); ++n) {
          outs() << "        reason:  " << rlog[n].getRejectReason() << "\n";
          if (rlog[n].Failed_LHS) {
            outs() << "        details: ";
            rlog[n].Failed_LHS->print(outs());
            outs() << "\n";
          }

          if (rlog[n].Failed_RHS) {
            outs() << "                 ";
            rlog[n].Failed_RHS->print(outs());
            outs() << "\n";
          }
        }
      }
    }

    return false;
  }
  ;

  virtual void print(raw_ostream &OS, const Module *) const {};
  //@}
};

char ScopDetectionResultsViewer::ID = 0;

namespace llvm {

ExecutionEngine *PolyJIT::GetEngine(Module *M, bool NoLazyCompilation) {
  EngineBuilder builder(M);
  std::string ErrorMsg;

  builder.setMArch(MArch);
  builder.setMCPU(MCPU);
  builder.setMAttrs(MAttrs);
  builder.setRelocationModel(RelocModel);
  builder.setCodeModel(CMModel);
  builder.setErrorStr(&ErrorMsg);
  builder.setEngineKind(ForceInterpreter ? EngineKind::Interpreter
                                         : EngineKind::JIT);
  builder.setUseMCJIT(UseMCJIT);
  builder.setJITMemoryManager(
      ForceInterpreter ? 0 : JITMemoryManager::CreateDefaultMemManager());

  // If we are supposed to override the target triple, do so now.
  if (!TargetTriple.empty())
    M->setTargetTriple(Triple::normalize(TargetTriple));

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
  builder.setOptLevel(OLvl);

  TargetOptions Options;
  Options.UseSoftFloat = GenerateSoftFloatCalls;
  if (FloatABIForCalls != FloatABI::Default)
    Options.FloatABIType = FloatABIForCalls;
  if (GenerateSoftFloatCalls)
    FloatABIForCalls = FloatABI::Soft;

  // Remote target execution doesn't handle EH or debug registration.
  Options.JITEmitDebugInfo = EmitJitDebugInfo;
  Options.JITEmitDebugInfoToDisk = EmitJitDebugInfoToDisk;

  builder.setTargetOptions(Options);
  return builder.create(builder.selectTarget());
}

void
PolyJIT::runSpecializedFunction(Function *NewF,
                                const std::vector<GenericValue> &ArgValues) {
  assert(NewF && "Cannot execute a NULL function!");

  Module *NewM = NewF->getParent();
  ExecutionEngine *NewEE;

  assert(NewM && "Passed function parameter has no parent module!");

  // Fetch or Create a new ExecutionEngine for this Module.
  if (!Mods.count(NewM))
    Mods[NewM] = PolyJIT::GetEngine(NewM);
  NewEE = Mods[NewM];

  assert(NewEE && "Failed to create a new ExecutionEngine for this module!");

  NewEE->runFunction(NewF, ArgValues);
}

void PolyJIT::instrumentScops(Module &M, ManagedModules &Mods) {
  outs() << "[polli] Phase III: Injecting call to JIT\n";
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
    EE.addGlobalMapping(PJITCB, (void *)&pjit_callback);

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

void PolyJIT::linkJitableScops(ManagedModules &Mods, Module &M) {
  Linker L(&M);

  /* We need to link the functions back in for execution */
  std::string ErrorMsg;
  for (ManagedModules::iterator src = Mods.begin(), se = Mods.end(); src != se;
       ++src) {
    Module *M = (*src).first;
    outs().indent(2) << "Linking: " << M->getModuleIdentifier() << "\n";
    if (L.linkInModule(M, Linker::PreserveSource, &ErrorMsg))
      errs().indent(2) << "ERROR while linking. MESSAGE: " << ErrorMsg << "\n";
  }

  StringRef cbName = StringRef("polli.enter.runtime");
  /* Register our callback with the system linker, so the MCJIT can find it
   * during object compilation */
  sys::DynamicLibrary::AddSymbol(cbName, (void *)&pjit_callback);
}

void PolyJIT::extractJitableScops(Module &M) {
  ScopDetection *SD = (ScopDetection *)polly::createScopDetectionPass();
  ScopMapper *SM = new ScopMapper();

  PassManager PM;

  PM.add(new DataLayout(&M));
  if (InstrumentRegions)
    PM.add(new PapiCScopProfilingInit());

  PM.add(new DataLayout(&M));
  PM.add(llvm::createTypeBasedAliasAnalysisPass());
  PM.add(llvm::createBasicAliasAnalysisPass());
  PM.add(SD);

  if (EnableCaddy) {
    PM.add(polly::createCScopInfoPass());
    if (InstrumentRegions)
      PM.add(polli::createPapiCScopProfilingPass());
  }
  else {
    if (EnablePapi)
      PM.add(new PapiRegionPrepare());
   
    PM.add(new NonAffineScopDetection());
    
    if (InstrumentRegions)
      PM.add(polli::createPapiRegionProfilingPass());
  }
 
  if (!DisableRecompile)
    PM.add(SM);

  outs() << "[polli] Phase II: Extracting NonAffine Scops\n";
  PM.run(M);

  // TODO: Maybe we need to take care of the ScopMapper again.
  //for (Module::iterator f = M.begin(), fe = M.end(); f != fe; ++f) {
  //  if (f->isDeclaration())
  //    continue;

  //  if (DisableRecompile || !SM->getCreatedFunctions().count(f))
  //    FPM->run(*f);
  //}

  ValueToValueMapTy VMap;

  /* Move the extracted SCoP functions into separate modules. */
  for (ScopMapper::iterator f = SM->begin(), fe = SM->end(); f != fe; ++f) {
    Function *F = (*f);

    /* Prepare a fresh module for this function. */
    Module *M, *NewM;
    M = F->getParent();

    /* Copy properties of our source module */
    NewM = new Module(M->getModuleIdentifier(), M->getContext());
    NewM->setTargetTriple(M->getTargetTriple());
    NewM->setDataLayout(M->getDataLayout());
    NewM->setMaterializer(M->getMaterializer());
    NewM->setModuleIdentifier(
        (M->getModuleIdentifier() + "." + F->getName()).str());

    // FIXME: Work around the one module per engine model of MCJIT/JIT for now.
    Mods[NewM] = &EE;

    MovingFunctionCloner MoveCloner(VMap, NewM);
    InstrumentingFunctionCloner InstCloner(VMap, NewM);

    MoveCloner.setSource(F);
    Function *OrigF = MoveCloner.start();

    InstCloner.setSource(OrigF);
    InstCloner.setSinkHostPass(SM);
    Function *InstF = InstCloner.start();

    // This maps the function name in the source module to the instrumented
    // version in the extracted version.
    F->setName(InstF->getName());

    // Remove the mess we made during instrumentation.
    FunctionPassManager *NewFPM = new FunctionPassManager(NewM);

    NewFPM->add(llvm::createDeadCodeEliminationPass());
    NewFPM->doInitialization();
    NewFPM->run(*InstF);
    NewFPM->doFinalization();

    delete NewFPM;
    // Set up the mapping for this prototype.
    Disp->setPrototypeMapping(InstF, OrigF);
  }

  FPM->doFinalization();
  delete FPM;

  if (OutputFilename.size() == 0)
    StoreModule(M, M.getModuleIdentifier() + ".extr");
}

int PolyJIT::runMain(const std::vector<std::string> &inputArgs,
                     const char *const *envp) {
  Function *Main = M.getFunction(EntryFn);

  if (!Main) {
    errs() << '\'' << EntryFn << "\' function not found in module.\n";
    return -1;
  }

  /* Preoptimize our module for polly */
  runPollyPreoptimizationPasses(M);

  /* Extract suitable Scops */
  extractJitableScops(M);

  /* Store temporary files */
  StoreModules(Mods);

  /* Get the Scops back */
  linkJitableScops(Mods, M);

  /* Store module before execution */
  if (OutputFilename.size() > 0)
    StoreModule(M, OutputFilename);

  /* Add a mapping to our JIT callback function. */
  int ret = 0;
  if (!DisableExecution) {
    // Run static constructors.
    EE.runStaticConstructorsDestructors(false);

    DEBUG(dbgs() << "[polli] Starting execution...\n");
    ret = EE.runFunctionAsMain(Main, inputArgs, envp);
  }

  return ret;
}

void PolyJIT::runPollyPreoptimizationPasses(Module &M) {
  registerCanonicalicationPasses(*FPM);

  FPM->doInitialization();

  outs() << "[polli] Phase I: Applying Preoptimization:\n";
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe; ++f) {
    if (f->isDeclaration())
      continue;

    DEBUG(dbgs().indent(2) << "PreOpt: " << (*f).getName() << "\n");
    FPM->run(*f);
  }
  FPM->doFinalization();
}

int PolyJIT::shutdown(int result) {
  LLVMContext &Context = M.getContext();

  // Run static destructors.
  EE.runStaticConstructorsDestructors(true);

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
    EE.runFunction(ExitF, Args);
    errs() << "ERROR: exit(" << result << ") returned!\n";
    abort();
  } else {
    errs() << "ERROR: exit defined with wrong prototype!\n";
    abort();
  }

  for (ManagedModules::iterator I = Mods.begin(), ME = Mods.end(); I != ME;
       ++I) {
    ExecutionEngine *EE = (*I).second;
    delete EE;
  }
}
;

PolyJIT *PolyJIT::Instance = NULL;
PolyJIT *PolyJIT::Get(Module *M, bool NoLazyCompilation) {
  if (!Instance) {
    ExecutionEngine *EE = PolyJIT::GetEngine(M);

    if (!EE)
      return NULL;

    // The following functions have no effect if their respective profiling
    // support wasn't enabled in the build configuration.
    EE->RegisterJITEventListener(
        JITEventListener::createOProfileJITEventListener());
    EE->RegisterJITEventListener(
        JITEventListener::createIntelJITEventListener());
    EE->DisableLazyCompilation(NoLazyCompilation);

    Instance = new PolyJIT(EE, M);
  }
  return Instance;
}
;
} // end of llvm namespace
