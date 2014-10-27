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
#include <assert.h> // for assert
#include <ext/alloc_traits.h>
#include <stddef.h>             // for size_t
#include <stdlib.h>             // for NULL, abort
#include <map>                  // for _Rb_tree_iterator, etc
#include <memory>               // for __shared_ptr, shared_ptr
#include <utility>              // for pair
#include "llvm/ADT/APInt.h"     // for APInt, operator<<
#include "llvm/ADT/StringRef.h" // for StringRef, operator==
#include "llvm/ADT/Triple.h"    // for Triple
#include "llvm/ADT/Twine.h"     // for Twine, operator+
#include "llvm/ADT/ilist.h"     // for ilist_iterator
#include "llvm/Analysis/Passes.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h" // for EngineBuilder, etc
#include "llvm/ExecutionEngine/GenericValue.h"    // for GenericValue, PTOGV
#include "llvm/ExecutionEngine/JITEventListener.h"
#include "llvm/ExecutionEngine/JITMemoryManager.h" // for JITMemoryManager
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/ExecutionEngine/ObjectCache.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/IR/Argument.h"            // for Argument
#include "llvm/IR/BasicBlock.h"          // for BasicBlock::iterator, etc
#include "llvm/IR/Constant.h"            // for Constant
#include "llvm/IR/Constants.h"           // for ConstantInt
#include "llvm/IR/DataLayout.h"          // for DataLayoutPass
#include "llvm/IR/DerivedTypes.h"        // for PointerType
#include "llvm/IR/Function.h"            // for Function, etc
#include "llvm/IR/GlobalValue.h"         // for GlobalValue, etc
#include "llvm/IR/IRBuilder.h"           // for IRBuilder
#include "llvm/IR/Instructions.h"        // for AllocaInst
#include "llvm/IR/LegacyPassManager.h"   // for PassManager, etc
#include "llvm/IR/Module.h"              // for Module, Module::iterator
#include "llvm/IR/Type.h"                // for Type
#include "llvm/Linker/Linker.h"          // for Linker, etc
#include "llvm/Pass.h"                   // for ImmutablePass, FunctionPass, etc
#include "llvm/PassAnalysisSupport.h"    // for AnalysisUsage, etc
#include "llvm/PassManager.h"            // for PassManager, etc
#include "llvm/PassRegistry.h"           // for PassRegistry
#include "llvm/Support/Casting.h"        // for cast, dyn_cast
#include "llvm/Support/CodeGen.h"        // for Model, Level::Default, etc
#include "llvm/Support/CommandLine.h"    // for desc, initializer, opt, cat, etc
#include "llvm/Support/Debug.h"          // for dbgs, DEBUG
#include "llvm/Support/DynamicLibrary.h" // for DynamicLibrary
#include "llvm/Support/ErrorHandling.h"  // for llvm_unreachable
#include "llvm/Support/raw_ostream.h"    // for raw_ostream, errs
#include "llvm/Target/TargetOptions.h"   // for ABIType, TargetOptions, etc
#include "llvm/Transforms/IPO.h"         // for createStripSymbolsPass
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/ValueMapper.h" // for ValueToValueMapTy
#include "papi.h"                              // for PAPI_flops
#include "polli/FunctionCloner.h"     // for InstrumentingFunctionCloner, etc
#include "polli/FunctionDispatcher.h" // for RuntimeParam, etc
#include "polli/InstrumentRegions.h"  // for PapiCScopProfiling, etc
#include "polli/JitScopDetection.h"   // for JitScopDetection, etc
#include "polli/PapiProfiling.h"
#include "polli/ScopMapper.h" // for ScopMapper, etc
#include "polli/Utils.h"      // for ManagedModules, StoreModule, etc
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"           // for createScopDetectionPass
#include "polly/RegisterPasses.h"          // for initializePollyPasses
#include "polly/ScopDetection.h"           // for ScopDetection, etc
#include "polly/ScopDetectionDiagnostic.h" // for getDebugLocation, etc

#include "polly/ScopPass.h"
#include "polly/TempScopInfo.h"
#include "polly/ScopInfo.h"

#include "polli/AliasCheckCodeGen.h"

#include "pprof/pprof.h"
#include "pprof/Tracing.h"

#include <numeric>

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

  /* Be very careful here, we want to exit this callback asap to cut down on
   * overhead. Think about triggering any modifications to the underlying IR
   * in a concurrent thread instead of b tlocking everything here. */
  Module &M = JIT->getExecutedModule();
  Function *F = M.getFunction(fName);

  if (!F)
    llvm_unreachable("Function not in this module. It has to be there!");

  TRACE(pprof_trace_entry("Variants"));
  std::vector<Param> ParamV;
  getRuntimeParameters(F, paramc, params, ParamV);

  ParamVector<Param> Params(std::move(ParamV));

  // Assume that we have used a specializer that converts all functions into
  // 'main' compatible format.
  VariantFunctionTy VarFun = Disp->getOrCreateVariantFunction(F);
  TRACE(pprof_trace_exit("Variants"));

  std::vector<GenericValue> ArgValues(2);
  GenericValue ArgC;
  ArgC.IntVal = APInt(sizeof(size_t) * 8, F->arg_size(), false);
  ArgValues[0] = ArgC;
  ArgValues[1] = PTOGV(params);

  Stats &S = VarFun->stats();
  Function *NewF = VarFun->getOrCreateVariant(Params);

  TRACE(pprof_trace_entry(NewF->getName()));
  JIT->runSpecializedFunction(NewF, ArgValues);
  TRACE(pprof_trace_exit(NewF->getName()));

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
PolyJIT::runSpecializedFunction(Function *NewF,
                                const std::vector<GenericValue> &ArgValues) {
  assert(NewF && "Cannot execute a NULL function!");

  Module *NewM = NewF->getParent();
  ExecutionEngine *NewEE;

  assert(NewM && "Passed function parameter has no parent module!");

  // Fetch or Create a new ExecutionEngine for this Module.
  if (!Mods.count(NewM)) {
    Mods[NewM] = PolyJIT::GetEngine(NewM);
    TRACE(pprof_trace_entry("JIT-codegen"));
    Mods[NewM]->finalizeObject();
    TRACE(pprof_trace_exit("JIT-codegen"));
  }
  NewEE = Mods[NewM];

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
  Linker L(&M);

  /* We need to link the functions back in for execution */
  std::string ErrorMsg;
  for (ManagedModules::iterator src = Mods.begin(), se = Mods.end(); src != se;
       ++src) {
    Module *M = (*src).first;
    DEBUG(log(Info, 2) << "link :: " << M->getModuleIdentifier() << "\n");
    if (L.linkInModule(M, Linker::PreserveSource, &ErrorMsg))
      log(Error, 2) << "ERROR while linking. MESSAGE: " << ErrorMsg << "\n";
  }

  StringRef cbName = StringRef("polli.enter.runtime");
  /* Register our callback with the system linker, so the MCJIT can find it
   * during object compilation */
  sys::DynamicLibrary::AddSymbol(cbName, (void *)&pjit_callback);
}

/**
 * @brief Extract all jitable Scops into a separate module
 *
 * @param The module to extract all jitable Scops from
 */
void PolyJIT::extractJitableScops(Module &M) {
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

    Mods[NewM] = EE;

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
    FunctionPassManager NewFPM(NewM);
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
  TRACE(pprof_setup_papi());
  TRACE(pprof_trace_add_event(std::string("PAPI_TOT_CYC")));
  TRACE(pprof_trace_add_event(std::string("PAPI_TOT_INS")));
  TRACE(pprof_trace_add_event(std::string("PAPI_BR_MSP")));
  TRACE(pprof_trace_add_event(std::string("PAPI_L1_DCM")));
  TRACE(pprof_trace_add_event(std::string("PAPI_L2_DCM")));
  TRACE(pprof_trace_start());

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
  StoreModules(Mods);

  /* Get the Scops back */
  linkJitableScops(Mods, M);

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

  // Stop monitoring.
  TRACE(pprof_trace_stop());

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

  for (ManagedModules::iterator I = Mods.begin(), ME = Mods.end(); I != ME;
       ++I) {
    ExecutionEngine *EE = (*I).second;
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