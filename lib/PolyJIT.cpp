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

#include "polly/Support/SCEVValidator.h"
#include "polly/PapiProfiling.h"

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/Verifier.h"
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

#include "llvm/Support/Path.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FileUtilities.h"

#include "llvm/Linker.h"

#include <set>
#include <map>

using namespace llvm;
using namespace llvm::sys::fs;

namespace fs = llvm::sys::fs;
namespace p  = llvm::sys::path;

static cl::opt<bool>
AnalyzeOnly("analyze", cl::desc("Only perform analysis, no optimization"));

namespace {
// Statically register all Polly passes such that they are available after
// loading Polly.
static SmallVector<char, 255> DefaultDir;
static void initializeOutputDir() {
  SmallVector<char, 255> cwd;
  fs::current_path(cwd);

  p::append(cwd, "polli");
  fs::createUniqueDirectory(StringRef(cwd.data(), cwd.size()), DefaultDir);
  outs() << "DefaultDir = "
         << StringRef(DefaultDir.data(), DefaultDir.size())
         << "\n";
};

class StaticInitializer {

public:
    StaticInitializer() {
      PassRegistry &Registry = *PassRegistry::getPassRegistry();
      initializePollyPasses(Registry);
      initializeOutputDir();
    }
};
} // end of anonymous namespace.

static StaticInitializer InitializeEverything;

static void StoreModule(Module &M, const Twine &DirName, const Twine &Name) {
  llvm::error_code err;
  SmallVector<char, 255> destPath = DefaultDir;

  std::string ErrorInfo;
  PassManager PM;
  OwningPtr<tool_output_file> Out;

  M.setModuleIdentifier(Name.str());

  p::append(destPath, Name);

  std::string path = StringRef(destPath.data(), destPath.size()).str();
  DEBUG(dbgs().indent(2) << "Storing: " << path << "\n");
  Out.reset(new tool_output_file(path.c_str(), ErrorInfo,
                                 raw_fd_ostream::F_Binary));
  PM.add(new DataLayout(M.getDataLayout()));
  PM.add(createPrintModulePass(&Out->os()));
  PM.run(M);
  Out->keep();
}

static void StoreModules(const StringRef DirName, std::set<Module *> Modules) {
  for (std::set<Module *>::iterator
       MI = Modules.begin(), ME = Modules.end(); MI != ME; ++MI) {
    Module *M = *MI;
    StoreModule(*M, DirName, M->getModuleIdentifier());
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
        DEBUG(dbgs() << "[polli] invalid non affine SCoP! "
               << R->getNameStr() << "\n");
      }
    }

    if (AnalyzeOnly)
      print(dbgs(), F.getParent());

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
    Function::arg_iterator NewArg = NewF->arg_begin();
    for (Function::const_arg_iterator
         Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[Arg] = NewArg++;
    }

    SmallVector<ReturnInst*, 8> Returns;
    CloneFunctionInto(NewF, F, VMap,/* ModuleLevelChanges=*/false, Returns);

    // No need for the mapping anymore.
    for (Function::const_arg_iterator
         Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
      VMap.erase(Arg);
    }

    VMap[F] = NewF;
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
    for (NonAffineScopDetection::iterator RP = NSD->begin(), RE = NSD->end();
         RP != RE; ++RP) {
      const Region *R = RP->first;

      Extractor = new CodeExtractor(*DT, *R);
      Function *ExtractedF = Extractor->extractCodeRegion();

      if (ExtractedF) {
        ExtractedF->setLinkage(GlobalValue::ExternalLinkage);
        moveFunctionIntoModule(ExtractedF, NewM);

        /* FIXME: Do not depend on this set. */
        CreatedFunctions.insert(ExtractedF);
        DEBUG(
        if (verifyFunction(*ExtractedF))
          report_fatal_error("Oops: verifyFunction failed")
        );
      }

      delete Extractor;
    }

    DEBUG(StoreModule(*NewM,
                      StringRef(DefaultDir.data(), DefaultDir.size()),
                      M->getModuleIdentifier() + "." + F.getName()));

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

  ValueToValueMapTy VMap;
  
  NonAffineScopDetection *NSD;
  DominatorTree *DT;
  RegionInfo *RI;

  Module *M;
  FunctionSet CreatedFunctions;
  ModuleSet CreatedModules;
};

char ScopMapper::ID = 0;

template <class StorageT, class TypeT>
struct RTParam {
  explicit RTParam(StorageT val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  bool operator<(RTParam const& rhs)       { return Value < rhs.Value; }
  bool operator<(RTParam const& rhs) const { return Value < rhs.Value; }

  bool operator>(RTParam const& rhs)       { return Value > rhs.Value; }
  bool operator>(RTParam const& rhs) const { return Value > rhs.Value; }

  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }

private:
  StorageT Value;
  TypeT *Type;
  StringRef Name;
};

template <class StorageT, class TypeT> 
raw_ostream& operator<< (raw_ostream &out,
                         const RTParam<StorageT, TypeT> &p) {
  p.print(out);
  return out;
};

/* Specialize to APInt. We do not have a proper lt operator there. */
template <class TypeT>
struct RTParam<APInt, TypeT> {
  explicit RTParam(APInt val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  bool operator<(RTParam<APInt, TypeT> const& rhs) {
    return Value.ult(rhs.Value);
  }

  bool operator<(RTParam<APInt, TypeT> const& rhs) const {
    return Value.ult(rhs.Value);
  }

  bool operator>(RTParam<APInt, TypeT> const& rhs) {
    return Value.ugt(rhs.Value);
  }

  bool operator>(RTParam<APInt, TypeT> const& rhs) const {
    return Value.ugt(rhs.Value);
  }
  
  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }
private:
  APInt Value;
  TypeT *Type;
  StringRef Name;
};

template <class RTParam>
struct ParamVector {
  /* Convert a std::vector of RTParams to a ParamArray. */
  ParamVector(std::vector<RTParam> const& ParamVector) {
    Params = ParamVector;
  };

  typedef typename std::vector<RTParam>::iterator iterator;
  typedef typename std::vector<RTParam>::const_iterator const_iterator;

  iterator begin() { return Params.begin(); };
  iterator end() { return Params.end(); };

  const_iterator begin() const { return Params.cbegin(); };
  const_iterator end() const { return Params.cend(); };
  
  inline size_t size() const { return Params.size(); };

  RTParam &operator[](unsigned const& index) {
    return Params[index];
  };
 
  const RTParam &operator[](unsigned const& index) const {
    return Params[index];
  };

  bool operator< (ParamVector<RTParam> const& rhs) {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();
    
    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }
  
  bool operator< (ParamVector<RTParam> const& rhs) const {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();
    
    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }
 
private:
  std::vector<RTParam> Params;
};

template <class RTParam> 
raw_ostream& operator<< (raw_ostream &out,
                         const ParamVector<RTParam> &Params) {
  out << "[";
  for (size_t i=0; i < Params.size(); ++i) {
    out << Params[i];
  }

  out << "]";
  return out;
};

/* For now we only deal with APInt storage of IntegerType parameter values. */
typedef RTParam<APInt, IntegerType> RuntimeParam;
typedef std::vector<RuntimeParam> RTParams;

/* The ParamVector is our key for indexing specialized functions at runtime. */
typedef ParamVector<RuntimeParam> RTParValuesKey;

/* ValToFun Relation: { [Parameter values] -> [Specialized Function] } */
typedef std::map<RTParValuesKey, Function *> ValKeyToFunction;

/* Specialize Relation: { [SrcFun] -> [ValToFun] } */ 
typedef std::map<Function *, ValKeyToFunction> SpecializedFuncs;

static inline
void printParameters(const Function *F, RTParams &Params) {
  dbgs() << "[" << F->getName() << "] Argument-Value Table:\n";

  dbgs() << "{\n";
  for (RTParams::iterator P = Params.begin(), PE = Params.end(); P != PE; ++P) {
    dbgs() << *P << "\n";
  
  }
  dbgs() << "}\n";
};

RTParams getRuntimeParameters(Function *F, unsigned paramc,
                              void** params) {
  RTParams RuntimeParams;
  int i = 0;
  for (Function::arg_iterator Arg = F->arg_begin(), ArgE= F->arg_end();
       Arg != ArgE; ++Arg, ++i) {
    Type *ArgTy = Arg->getType();

    /* TODO: Add more types to be suitable for spawning new functions. */
    if (IntegerType *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      APInt val = APInt(IntTy->getBitWidth(),
                        (uint64_t)(*(uint64_t *)params[i]),
                        IntTy->getSignBit());
      RuntimeParams.push_back(RuntimeParam(val, IntTy, Arg->getName()));
    }
  }

  return RuntimeParams;
}

//===----------------------------------------------------------------------===//
/// @brief Implement a function dispatch to reroute calls to parametrized
/// functions to their possible specializations.
class FunctionDispatcher {
  FunctionDispatcher (const FunctionDispatcher &)
    LLVM_DELETED_FUNCTION;
  const FunctionDispatcher &operator=(const FunctionDispatcher &)
    LLVM_DELETED_FUNCTION;

  /// @brief Maps source Functions to specialized functions,
  //         based on the input parameters.
  SpecializedFuncs SpecFuns;

  /// @brief Store all specialized modules.
  //         We want to store each specialized functions in a separate module.
  //         TODO: Maybe we will need a mapping from Source Function
  //               to all modules of it's specializations.
  std::vector<Module *> SpecializedModules;
public:
  explicit FunctionDispatcher() {};
 
  /// @brief Use LLVM's Cloning utilities to create a copy of a source function
  //         in a new module. 
  Function *cloneFunctionIntoModule(Function *F, Module *Dest) {
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
    CloneFunctionInto(NewF, F, VMap,/* ModuleLevelChanges=*/false, Returns);

    // No need for the mapping anymore. TODO: Think about that more.
    for (Function::const_arg_iterator
         Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
      VMap.erase(Arg);
    }

    return NewF;
  };

  template<class ParamT>
  Function *specialize(Function *F,
                       ParamVector<ParamT> &Values) {
    Module *M     = F->getParent();
    Module *NewM;

    // 0. Prepare a new module to host the specialized function
    
    NewM = new Module(M->getModuleIdentifier(), M->getContext());
    NewM->setTargetTriple(M->getTargetTriple());
    NewM->setDataLayout(M->getDataLayout());
    NewM->setMaterializer(M->getMaterializer());

    // TODO: Set this to the specialized functions name:
    //       F->getName() + "_param1_param2_..._paramn
    NewM->setModuleIdentifier(("spec-" + M->getModuleIdentifier() +
                               "." + F->getName()).str());
    
    // 1. Create a clone of F in the new Module.
    //    FIXME: One copy of SpecF remains in NewM
    Function *SpecF = cloneFunctionIntoModule(F, NewM);

    // TODO: 2. Substitute parameter values in the new function.
    DEBUG(StoreModule(*NewM, StringRef(DefaultDir.data(), DefaultDir.size()),
                                       NewM->getModuleIdentifier()));

    return SpecF;
  };

  template<class ParamT>
  Function *getFunctionForValues(Function *F,
                                 ParamVector<ParamT> &Values) {
    if (!SpecFuns.count(F))
      SpecFuns[F] = ValKeyToFunction();
    
    ValKeyToFunction ValToFun = SpecFuns[F];
    
    /* TODO: We need to be a bit more smart than: Specialize everything. */
    if (!ValToFun.count(Values)) {
      ValToFun[Values] = specialize(F, Values);
    }
      
    outs() << "\nSrcF:   " << F->getName()
           << "\nParams: " << Values
           << "\nDestF:  " << ValToFun[Values]->getName()
           << "\n";;

    return ValToFun[Values];
  };
};

static FunctionDispatcher *Disp = new FunctionDispatcher();

void pjit_callback(const char *fName, unsigned paramc,
                   void** params) {
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

  RTParams RuntimeParams = getRuntimeParameters(F, paramc, params);  
  ParamVector<RuntimeParam> PArr = RuntimeParams;

  // FIXME: Do it properly
  std::vector<GenericValue> ArgValues(paramc);
  for (unsigned i  = 0; i < paramc; ++i)
    ArgValues[i] = PTOGV(params[i]);

  Function *NewF = Disp->getFunctionForValues(F, PArr);
  ExecutionEngine *EE = JIT->GetEngine();

  GenericValue Ret = EE->runFunction(NewF, ArgValues);
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

  StringRef cbName = StringRef("polli.enter.runtime");

  /* Insert callback declaration & call into each extracted module */
  for (ManagedModules::iterator
       i = Mods.begin(), ie = Mods.end(); i != ie; ++i) {
    Module *ScopM = (*i);
    Function *PJITCB = cast<Function>(
      ScopM->getOrInsertFunction(cbName, Type::getVoidTy(Ctx),
                                         Type::getInt8PtrTy(Ctx),
                                         Type::getInt32Ty(Ctx),
                                         PtoArr,
                                         NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);
    EE.addGlobalMapping(PJITCB, (void *)&pjit_callback);

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

      Builder.CreateCall(PJITCB, Args);
    }
  }
};

void PolyJIT::linkJitableScops(ManagedModules &Mods, Module &M) {
  Linker L(&M);

  /* We need to link the functions back in for execution */
  std::string ErrorMsg;
  for (ManagedModules::iterator
       src = Mods.begin(), se = Mods.end(); src != se; ++src)
    if(L.linkInModule(*src, &ErrorMsg))
      errs().indent(2) << "ERROR: " << ErrorMsg << "\n";

  StringRef cbName = StringRef("polli.enter.runtime");
  /* Register our callback with the system linker, so the MCJIT can find it
   * during object compilation */
  sys::DynamicLibrary::AddSymbol(cbName, (void *)&pjit_callback);
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

  /* Remove bodies of cloned functions, we will link in an instrumented
   * version of it. */
  for (ScopMapper::iterator
       F = SM->begin(), FE = SM->end(); F != FE; ++F) {
   (*F)->deleteBody();
  }

  FPM->doFinalization();
  delete FPM;

  StringRef OutDir = StringRef(DefaultDir.data(), DefaultDir.size());
  StoreModule(M, OutDir, M.getModuleIdentifier() + ".extr");
};

int PolyJIT::runMain(const std::vector<std::string> &inputArgs,
                     const char * const *envp) {
  Function *Main = M.getFunction(EntryFn);
  StringRef OutDir = StringRef(DefaultDir.data(), DefaultDir.size());

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
  StoreModules(OutDir, Mods);

  /* Get the Scops back */
  linkJitableScops(Mods, M);

  /* Store module before execution */
  StoreModule(M, OutDir, M.getModuleIdentifier() + ".final");

  /* Add a mapping to our JIT callback function. */
  return EE.runFunctionAsMain(Main, inputArgs, envp);
}

void PolyJIT::runPollyPreoptimizationPasses(Module &M) {
  registerCanonicalicationPasses(*FPM);

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
