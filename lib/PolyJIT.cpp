//===-- JIT.cpp - LLVM Just in Time Compiler ------------------------------===//
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

#include "polly/Support/SCEVValidator.h"
#include "polly/PapiProfiling.h"

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/ValueMap.h"
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

#include "llvm/Linker.h"

#include <set>
#include <map>

using namespace llvm;

static cl::opt<bool>
AnalyzeOnly("analyze", cl::desc("Only perform analysis, no optimization"));

namespace {
// Statically register all Polly passes such that they are available after
// loading Polly.
class StaticInitializer {

public:
    StaticInitializer() {
      PassRegistry &Registry = *PassRegistry::getPassRegistry();
      initializePollyPasses(Registry);
    }
};
} // end of anonymous namespace.

static StaticInitializer InitializeEverything;

static void StoreModule(Module &M, const Twine &Name) {
  std::string ErrorInfo;
  PassManager PM;
  OwningPtr<tool_output_file> Out;

  M.setModuleIdentifier(Name.str());

  Out.reset(new tool_output_file(Name.str().c_str(),
                                 ErrorInfo, raw_fd_ostream::F_Binary));
  PM.add(new DataLayout(M.getDataLayout()));
  PM.add(createPrintModulePass(&Out->os()));
  PM.run(M);
  Out->keep();
  DEBUG(dbgs() << "Stored module: " << M.getModuleIdentifier() << "\n");
}

static void StoreModules(std::set<Module *> Modules) {
  for (std::set<Module *>::iterator
       MI = Modules.begin(), ME = Modules.end(); MI != ME; ++MI) {
    Module *M = *MI;
    StoreModule(*M, M->getModuleIdentifier());
  }
}

class NonAffineScopDetection : public FunctionPass {
public:
  static char ID;
  explicit NonAffineScopDetection() : FunctionPass(ID) {}

  typedef std::vector<const SCEV *> ParamList;
  typedef std::map<const Region *, ParamList> ParamMap;
  typedef ParamMap::iterator iterator;
  typedef ParamMap::const_iterator const_iterator;

  iterator begin()  { return RequiredParams.begin(); }
  iterator end()    { return RequiredParams.end();   }

  const_iterator begin() const { return RequiredParams.begin(); }
  const_iterator end()   const { return RequiredParams.end();   }

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetection>();
    AU.addRequired<ScalarEvolution>();
    AU.addRequired<DominatorTree>();
    AU.addRequired<RegionInfo>();
    AU.setPreservesAll();
  };

  virtual void releaseMemory() {
    RequiredParams.clear();
  };

  virtual bool runOnFunction(Function &F) {
    SD = &getAnalysis<ScopDetection>();
    SE = &getAnalysis<ScalarEvolution>();
    DT = &getAnalysis<DominatorTree>();
    RI = &getAnalysis<RegionInfo>();
    M = F.getParent();

    polly::RejectedLog rl = SD->getRejectedLog();
    for (polly::RejectedLog::iterator
         i = rl.begin(), ie = rl.end(); i != ie; ++i) {
      const Region *R              = (*i).first;
      std::vector<RejectInfo> rlog = (*i).second;
      RequiredParams[R] = ParamList();

      bool isValid = true;
      for (unsigned j=0; j < rlog.size(); ++j) {
        const SCEV *lhs = rlog[j].Failed_LHS;
        const SCEV *rhs = rlog[j].Failed_RHS;
        RejectKind kind = rlog[j].Reason;

        // We do not handle these reject reasons here.
        isValid &= (kind == NonAffineLoopBound ||
                    kind == NonAffineCondition ||
                    kind == NonAffineAccess);
        if (!isValid) {
          DEBUG(dbgs() << "[polli] reject reason was not related to affinity;"
                       << " continuing.\n");
          break;
        }

        ParamList params;
        if (kind == NonAffineLoopBound) {
          isValid &= polly::isNonAffineExpr(R, rhs, *SE);
          params = getParamsInNonAffineExpr(R, rhs, *SE);
          RequiredParams[R].insert(RequiredParams[R].end(),
                                   params.begin(), params.end());
        }

        if (kind == NonAffineAccess || kind == NonAffineCondition) {
          std::vector<const SCEV*> params;

          isValid &= polly::isNonAffineExpr(R, lhs, *SE);
          params = getParamsInNonAffineExpr(R, lhs, *SE);
          RequiredParams[R].insert(RequiredParams[R].end(),
                                   params.begin(), params.end());
        }
      }

      if (isValid) {
        DEBUG(dbgs() << "[polli] valid non affine SCoP! "
               << R->getNameStr() << "\n");
      } else {
        DEBUG(outs() << "[polli] invalid non affine SCoP! "
               << R->getNameStr() << "\n");
      }
    }

    if (AnalyzeOnly)
      print(outs(), F.getParent());

    return true;
  };

  virtual void print(raw_ostream &OS, const Module *) const {
    for (ParamMap::const_iterator r = RequiredParams.begin(),
                                 RE = RequiredParams.end(); r != RE; ++r) {
      const Region *R = r->first;
      ParamList Params = r->second;

      OS.indent(4) << R->getNameStr() << "(";
      for (ParamList::iterator i = Params.begin(), e = Params.end();
           i != e; ++i) {
        (*i)->print(OS.indent(1));
      }
      OS << " )\n";
    }
  };
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  NonAffineScopDetection(const NonAffineScopDetection &);
  // DO NOT IMPLEMENT
  const NonAffineScopDetection &operator=(const NonAffineScopDetection &);

  ScopDetection *SD;
  ScalarEvolution *SE;
  DominatorTree *DT;
  RegionInfo *RI;

  Module *M;

  ParamMap RequiredParams;
};
char NonAffineScopDetection::ID = 0;

struct ScopMapper : public FunctionPass {
public:
  typedef std::set<Function *> FunctionSet;
  typedef FunctionSet::iterator iterator;

  iterator begin() { return CreatedFunctions.begin(); }
  iterator end() { return CreatedFunctions.end(); }

  typedef std::set<Module *> ModuleSet;
  typedef ModuleSet::iterator module_iterator;

  module_iterator modules_begin() { return CreatedModules.begin(); }
  module_iterator modules_end() { return CreatedModules.end(); }

  static char ID;
  explicit ScopMapper() : FunctionPass(ID) {}
  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<NonAffineScopDetection>();
    AU.addRequired<DominatorTree>();
    AU.addRequired<RegionInfo>();
    AU.setPreservesAll();
  };

  virtual void releaseMemory() {};

  void moveFunctionIntoModule(Function *F, Module *Dest) {
    /* Create a new function for cloning, based on the properties
     * of our source function, but set linkage to external. */
    Function *NewF = Function::Create(F->getFunctionType(),
                                      F->getLinkage(),
                                      F->getName(),
                                      Dest);
    NewF->copyAttributesFrom(F);

    /* Copy function body ExtractedF over to ClonedF */
    ValueToValueMapTy VMap;
    VMap[F] = NewF;
    Function::arg_iterator NewArg = NewF->arg_begin();
    for (Function::const_arg_iterator
         Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[Arg] = NewArg++;
    }

    SmallVector<ReturnInst*, 8> Returns;
    CloneFunctionInto(NewF, F, VMap,/* ModuleLevelChanges=*/true, Returns);

    // No need for the mapping anymore. TODO: Think about that more.
    for (Function::const_arg_iterator
         Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
      VMap.erase(Arg);
    }
    VMap.clear();
  };

  virtual bool runOnFunction(Function &F) {
    NSD = &getAnalysis<NonAffineScopDetection>();
    DT  = &getAnalysis<DominatorTree>();
    RI  = &getAnalysis<RegionInfo>();

    if (CreatedFunctions.count(&F))
      return false;

    /* Prepare a fresh module for this function. */
    //LLVMContext &NewContext = *(new LLVMContext());
    Module *M, *NewM;
    M = F.getParent();

    /* Copy properties of our source module */
    NewM = new Module(M->getModuleIdentifier(), M->getContext());
    //NewM = new Module(M->getModuleIdentifier(), NewContext);
    NewM->setTargetTriple(M->getTargetTriple());
    NewM->setDataLayout(M->getDataLayout());
    NewM->setMaterializer(M->getMaterializer());
    NewM->setModuleIdentifier(
      (M->getModuleIdentifier() + "." + F.getName()).str());

    /* Extract each SCoP in this function into a new one. */
    CodeExtractor *Extractor;
    for (NonAffineScopDetection::iterator
         RP = NSD->begin(), RE = NSD->end(); RP != RE; ++RP) {
      const Region *R = RP->first;

      Extractor = new CodeExtractor(*DT, *R);
      Function *ExtractedF = Extractor->extractCodeRegion();

      if (ExtractedF) {
        ExtractedF->setLinkage(GlobalValue::ExternalLinkage);
        moveFunctionIntoModule(ExtractedF, NewM);

        /* FIXME: Do not depend on this set. */
        CreatedFunctions.insert(ExtractedF);
      }
      delete Extractor;
    }

    DEBUG(StoreModule(*NewM, M->getModuleIdentifier() + "." + F.getName()));

    /* Keep track for the linker after cleaning the cloned functions. */
    CreatedModules.insert(NewM);

    return true;
  };

  virtual void print(raw_ostream &OS, const Module *) const {

  };
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopMapper(const ScopMapper&);
  // DO NOT IMPLEMENT
  const ScopMapper &operator=(const ScopMapper &);

  NonAffineScopDetection *NSD;
  DominatorTree *DT;
  RegionInfo *RI;

  Module *M;
  FunctionSet CreatedFunctions;
  ModuleSet CreatedModules;
};

char ScopMapper::ID = 0;

static inline
void printParameters(Function *F, const int paramc, const void **params) {
  outs() << "[" << F->getName() << "] Argument-Value Table:\n";
  int i = 0;

  outs() << "{\n";
  for (Function::arg_iterator Arg = F->arg_begin(), ArgE = F->arg_end();
       Arg != ArgE; ++Arg) {
    Type *ArgTy = Arg->getType();

    outs().indent(2) << "params[" << i << "]: ";
    ArgTy->print(outs());

    if (IntegerType *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      int raw = (int)(*(int *)params[i]);
      APInt Val = APInt(IntTy->getBitWidth(), (uint64_t)raw,/*isSigned=*/true);
      outs().indent(2) << " " << Arg->getName() << " = " << Val;

      outs() << " ByteBuf: "; 
      int8_t *ptr = (int8_t *)params[i]; 
      for (unsigned j=0; j < (IntTy->getBitWidth() / 8); j++) {
        outs() << format("%d ", *ptr);
        ptr++;
      }
    }
    
    outs() << "\n";
    i++;
  }
  outs() << "}\n";
};

void pjit_callback(const char *fName, const int paramc,
                   const void** params) {
  /* Let's hope that we have called it before ;-)
   * Otherwise it will blow up. FIXME: Don't blow up. */
  PolyJIT *JIT = PolyJIT::Get();

  /* Be very careful here, we want to exit this callback asap to cut down on
   * overhead. Think about triggering any modifications to the underlying IR
   * in a concurrent thread instead of blocking everything here. */
  Module& M = JIT->getExecutedModule();
  Function *F = M.getFunction(fName);

  if (!F)
    llvm_unreachable("Function not in this module. It must be there!");

  DEBUG(printParameters(F, paramc, params));
};

class ScopDetectionResultsViewer : public FunctionPass {
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopDetectionResultsViewer(const ScopDetectionResultsViewer &);
  // DO NOT IMPLEMENT
  const ScopDetectionResultsViewer &operator=(const ScopDetectionResultsViewer &);

  ScopDetection *SD;

public:
  static char ID;
  explicit ScopDetectionResultsViewer() : FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetection>();
    AU.setPreservesAll();
  };

  virtual void releaseMemory() {

  };

  virtual bool runOnFunction(Function &F) {
    SD = &getAnalysis<ScopDetection>();

    polly::RejectedLog rl = SD->getRejectedLog();
    for (polly::RejectedLog::iterator
         i = rl.begin(), ie = rl.end(); i != ie; ++i) {
      const Region *R              = (*i).first;
      std::vector<RejectInfo> rlog = (*i).second;

      if (R) {
        outs() << "[polli] rejected region: " <<  R->getNameStr() << "\n";

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
  };

  virtual void print(raw_ostream &OS, const Module *) const {

  };
  //@}
};

char ScopDetectionResultsViewer::ID = 0;

void PolyJIT::instrumentScops(Module &M, ManagedModules &Mods) {
  outs() << "[polli] Phase III: Injecting call to JIT\n";
  LLVMContext &Ctx = M.getContext();
  IRBuilder<> Builder(Ctx);

  PointerType *PtoArr = PointerType::get(Type::getInt8PtrTy(Ctx), 0);

  /* Insert declaration into source module */
  Function *PJITCallback = cast<Function>(
    M.getOrInsertFunction("pjit_callback",
                          Type::getVoidTy(Ctx),
                          Type::getInt8PtrTy(Ctx),
                          Type::getInt32Ty(Ctx),
                          PtoArr,
                          NULL));

  /* Register our callback with the global mapping table, so the JIT can find
   * it during object compilation */
  EE.addGlobalMapping(PJITCallback, (void *)&pjit_callback);

  /* Register our callback with the system linker, so the MCJIT can find it
   * during object compilation */
  sys::DynamicLibrary::AddSymbol(PJITCallback->getName(), (void *)&pjit_callback);

  /* Insert a declaration & a call into each extracted module */
  for (ManagedModules::iterator
       i = Mods.begin(), ie = Mods.end(); i != ie; ++i) {
    Module *ScopM = (*i);
    Function *CallbackDecl = Function::Create(PJITCallback->getFunctionType(),
                                              PJITCallback->getLinkage(),
                                              PJITCallback->getName(),
                                              ScopM);
    EE.addGlobalMapping(CallbackDecl, (void *)&pjit_callback);

    /* Insert declaration into new module and call it in every function. */
    outs().indent(2) << "Inject decl: " << CallbackDecl->getName() << "\n";

    std::vector<Value *> Args(3);
    /* Inject call to callback declaration into every function */
    for (Module::iterator
         F = ScopM->begin(), FE = ScopM->end(); F != FE; ++F) {
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
      Value *Params = Builder.CreateAlloca(Type::getInt8PtrTy(Ctx),
                                           ParamC, "params");

      /* Store each parameter as pointer in the params array */
      int i = 0;
      Value *One    = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
      for (Function::arg_iterator Arg = F->arg_begin(), ArgE = F->arg_end();
           Arg != ArgE; ++Arg) {

        /* Allocate a slot on the stack for the i'th argument and store it */
        Value *Slot   = Builder.CreateAlloca(Arg->getType(), One,
                                             "params." + Twine(i));
        Builder.CreateAlignedStore(Arg, Slot, 4);
       
        /* Bitcast the allocated stack slot to i8* */
        Value *Slot8 = Builder.CreateBitCast(Slot, Type::getInt8PtrTy(Ctx),
                                             "ps.i8ptr." + Twine(i)); 
          
        /* Get the appropriate slot in the parameters array and store
         * the stack slot in form of a i8*. */
        Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i);
        Value *Dest   = Builder.CreateGEP(Params, ArrIdx, "p." + Twine(i));
        Builder.CreateAlignedStore(Slot8, Dest, 8); 

        i++;
      }

      Args[0] = Builder.CreateGlobalStringPtr(F->getName());
      Args[1] = ParamC;
      Args[2] = Params;

      Builder.CreateCall(CallbackDecl, Args);
    }
  }
};

void PolyJIT::linkJitableScops(ManagedModules &Mods, Module &M) {
  /* We need to link the functions back in for execution */
  std::string ErrorMsg;
  for (ManagedModules::iterator
       src = Mods.begin(), se = Mods.end(); src != se; ++src) {
    outs().indent(2) << "Linking: " << (*src)->getModuleIdentifier() << "\n";

    /* Link the module back in, preserving the source */
    Linker::LinkModules(&M, (*src), Linker::DestroySource, &ErrorMsg);
  }
};

void PolyJIT::extractJitableScops(Module &M) {
  ScopDetection *SD = (ScopDetection *)polly::createScopDetectionPass();
  NonAffineScopDetection *NaSD = new NonAffineScopDetection();
  ScopMapper *SM = new ScopMapper();

  FPM = new FunctionPassManager(&M);

  /* Add ScopDetection, ResultsViewer and NonAffineScopDetection */
  FPM->add(SD);
  DEBUG(FPM->add(new ScopDetectionResultsViewer()));
  FPM->add(NaSD);
  FPM->add(SM);

  FPM->doInitialization();

  outs() << "[polli] Phase II: Extracting NonAffine Scops\n";
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe ; ++f) {
    if (f->isDeclaration())
      continue;
    outs().indent(2) << "Extract: " << (*f).getName() << "\n";
    FPM->run(*f);
  }

  /* Copy the set of modules generated by the ScopMapper */
  for (ScopMapper::module_iterator
       m = SM->modules_begin(), me = SM->modules_end(); m != me; ++m)
    Mods.insert(*m);

  /* Remove cloned functions */
  for (ScopMapper::iterator
       F = SM->begin(), FE = SM->end(); F != FE; ++F)
   (*F)->deleteBody();

  FPM->doFinalization();
  delete FPM;
}

int PolyJIT::runMain(const std::vector<std::string> &inputArgs,
              const char * const *envp) {
  Function *Main = M.getFunction(EntryFn);

  if (!Main) {
    errs() << '\'' << EntryFn << "\' function not found in module.\n";
    return -1;
  }

  // Run static constructors.
  EE.runStaticConstructorsDestructors(false);
  // Trigger compilation separately so code regions that need to be
  // invalidated will be known.
  //(void)EE.getPointerToFunction(Main);

  /* Preoptimize our module for polly */
  runPollyPreoptimizationPasses(M);

  /* Extract suitable Scops */
  extractJitableScops(M);

  /* Instrument extracted Scops with a callback */
  instrumentScops(M, Mods);

  /* Store temporary files */
  StoreModules(Mods);

  /* Get the Scops back */
  linkJitableScops(Mods, M);

  /* Store module before execution */
  StoreModule(M, M.getModuleIdentifier() + ".final");

  /* Add a mapping to our JIT callback function. */
  return EE.runFunctionAsMain(Main, inputArgs, envp);
}

void PolyJIT::runPollyPreoptimizationPasses(Module &M) {
  registerPollyPreoptPasses(*FPM);

  FPM->doInitialization();

  outs() << "[polli] Phase I: Applying Preoptimization:\n";
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe ; ++f) {
    if (f->isDeclaration())
      continue;

    outs().indent(2) << "PreOpt: " << (*f).getName() << "\n";
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
                                                 Type::getInt32Ty(Context),
                                                 NULL);

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
};

PolyJIT* PolyJIT::Instance = NULL;
PolyJIT* PolyJIT::Get(ExecutionEngine *EE, Module *M) {
  if (!Instance) {
    Instance = new PolyJIT(EE, M);
  }
  return Instance; 
};
