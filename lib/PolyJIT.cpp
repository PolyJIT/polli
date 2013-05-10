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

#include "polli/PolyJIT.h"

#include "polly/RegisterPasses.h"
#include "polly/LinkAllPasses.h"

#include "polly/PapiProfiling.h"

#include "llvm/ADT/SmallPtrSet.h"
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
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MutexGuard.h"
#include "llvm/Target/TargetJITInfo.h"
#include "llvm/Target/TargetMachine.h"

#include "llvm/Transforms/Scalar.h"
#include <set>
#include <map>

using namespace llvm;

class ScopDetectionErrorLog : FunctionPass {

public: 
};

static void initializePollyPasses(PassRegistry &Registry) {
#ifdef CLOOG_FOUND
//  initializeCloogInfoPass(Registry);
  initializeCodeGenerationPass(Registry);
#endif
  initializeIslCodeGenerationPass(Registry);
  initializeCodePreparationPass(Registry);
  initializeDeadCodeElimPass(Registry);
//  initializeDependencesPass(Registry);
  initializeIndependentBlocksPass(Registry);
  initializeJITScopDetectionPass(Registry);
  initializeJSONExporterPass(Registry);
  initializeJSONImporterPass(Registry);
  initializeIslAstInfoPass(Registry);
  initializeIslScheduleOptimizerPass(Registry);
  initializePapiProfilingPass(Registry);
  initializePapiRegionProfilingPass(Registry);
  initializePapiRegionPreparePass(Registry);
#ifdef SCOPLIB_FOUND
  initializePoccPass(Registry);
#endif
  initializePollyIndVarSimplifyPass(Registry);
  initializeRegionSimplifyPass(Registry);
  initializeScopDetectionPass(Registry);
//  initializeScopInfoPass(Registry);

#if 0
  initializeScopInlinerPass(Registry);
#endif
//  initializeScopProfileInfoPass(Registry);
//  initializeScopLoaderPass(Registry);
//  initializeTempScopInfoPass(Registry);
}

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

static void registerPollyPreoptPasses(PassManagerBase &PM) {
  // A standard set of optimization passes partially taken/copied from the
  // set of default optimization passes. It is used to bring the code into
  // a canonical form that can than be analyzed by Polly. This set of passes is
  // most probably not yet optimal. TODO: Investigate optimal set of passes.

  PM.add(llvm::createPromoteMemoryToRegisterPass());
  PM.add(polly::createIndVarSimplifyPass());        // Canonicalize indvars
  PM.add(polly::createCodePreparationPass());
  // TODO: Testing vs. PapiRegionPreparePass!
  //  PM.add(polly::createRegionSimplifyPass());
  PM.add(polly::createPapiRegionPreparePass());
  // FIXME: The next two passes should not be necessary here. They are currently
  //        because of two problems:
  //
  //        1. The RegionSimplifyPass destroys the canonical form of induction
  //           variables,as it produces PHI nodes with incorrectly ordered
  //           operands. To fix this we run IndVarSimplify.
  //
  //        2. IndVarSimplify does not preserve the region information and
  //           the regioninfo pass does currently not recover simple regions.
  //           As a result we need to run the RegionSimplify pass again to
  //           recover them
  PM.add(polly::createIndVarSimplifyPass());
  //TODO (Testing): PM.add(polly::createRegionSimplifyPass());
  PM.add(polly::createPapiRegionPreparePass());
}

/// Check if a given SCEV becomes affine if parameters
/// get substituted at run time.
//@{
class NonAffineSCEVValidator : SCEVVisitor<NonAffineSCEVValidator, bool> {
  friend struct SCEVVisitor<NonAffineSCEVValidator, bool>;

  const Region *R;
  ScalarEvolution *SE;
private:
  typedef SCEVNAryExpr::op_iterator scev_op_it;

  // DO NOT IMPLEMENT
  NonAffineSCEVValidator(const NonAffineSCEVValidator &);
  // DO NOT IMPLEMENT
  const NonAffineSCEVValidator &operator=(const NonAffineSCEVValidator &);

  bool visitConstant(const SCEVConstant *S)  {
    // We're always fine with constant expressions.
    return true;
  }

  bool visitUnknown(const SCEVUnknown* S)  {
    Value *V = S->getValue();

    Type *AllocTy;
    Constant *FieldNo;
    // We treat these as constant.
    if (S->isSizeOf  (AllocTy) ||
        S->isAlignOf (AllocTy) ||
        S->isOffsetOf(AllocTy, FieldNo))
      return true;

    if (Argument *Arg = dyn_cast<Argument>(V))
      return true;

    // Invariant only if not contained inside the region.
    if (Instruction *I = dyn_cast<Instruction>(V)) {
      if (!R->contains(I)) {
        return true;
      } else {
        dbgs() << "\n Region-variant: " << *I;
      }
    }

    return false;
  }

  bool visitNAryExpr(const SCEVNAryExpr* S)  {
    for (scev_op_it I = S->op_begin(), E = S->op_end(); I != E; ++I)
      if (!visit(*I))
        return false;

    return true;
  }

  bool visitMulExpr(const SCEVMulExpr* S) {
    return visitNAryExpr(S);
  }

  bool visitCastExpr(const SCEVCastExpr *S)  {
    return visit(S->getOperand());
  }

  bool visitTruncateExpr(const SCEVTruncateExpr *S)  {
    return visit(S->getOperand());
  }

  bool visitZeroExtendExpr(const SCEVZeroExtendExpr *S)  {
    return visit(S->getOperand());
  }

  bool visitSignExtendExpr(const SCEVSignExtendExpr *S)  {
    return visit(S->getOperand());
  }

  bool visitAddExpr(const SCEVAddExpr *S)  {
    return visitNAryExpr(S);
  }

  bool visitAddRecExpr(const SCEVAddRecExpr *S)  {
    bool ret;

    // {a, +, b, +, c}  Is always bad.
    // {a,+, {b ,+, c}} Is always bad.
    // {{a,+,b} ,+,c}   Is always bad.
    if (isa<SCEVAddRecExpr>(S->getStepRecurrence(*SE)))
      return false;

    // Check for invariance.
    ret = visitNAryExpr(S);

    return ret;
  }

  bool visitUDivExpr(const SCEVUDivExpr *S)  {
    return visit(S->getLHS()) && visit(S->getRHS());
  }

  bool visitSMaxExpr(const SCEVSMaxExpr *S)  {
    return visitNAryExpr(S);
  }

  bool visitUMaxExpr(const SCEVUMaxExpr *S)  {
    return visitNAryExpr(S);
  }

  bool visitCouldNotCompute(const SCEVCouldNotCompute *S) {
    return false;
  }

public:
  explicit NonAffineSCEVValidator(const Region *r, ScalarEvolution *se) :
    R(r), SE(se) {}

  static bool isJITable(const SCEV *s, const Region *r, ScalarEvolution *se) {
    bool ret = false;
    DEBUG(dbgs() << *s);
    NonAffineSCEVValidator check(r,se);
    ret = check.visit(s);
    DEBUG(dbgs()  << " [ " << ((ret) ? "TRUE" : "FALSE") << " ]\n");
    return ret;
  }
};
//@}

class NonAffineScopDetection : public FunctionPass {
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  NonAffineScopDetection(const NonAffineScopDetection &);
  // DO NOT IMPLEMENT
  const NonAffineScopDetection &operator=(const NonAffineScopDetection &);

  ScopDetection *SD;
  ScalarEvolution *SE;

  typedef std::set<const Region *> RegionSet;
  RegionSet ValidRegions;

public:
  static char ID;
  explicit NonAffineScopDetection() : FunctionPass(ID) {}

  typedef RegionSet::iterator iterator;
  typedef RegionSet::const_iterator const_iterator;

  iterator begin()  { return ValidRegions.begin(); }
  iterator end()    { return ValidRegions.end();   }

  const_iterator begin() const { return ValidRegions.begin(); }
  const_iterator end()   const { return ValidRegions.end();   }

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetection>();
    AU.addRequired<ScalarEvolution>();
  };

  virtual void releaseMemory() {
    ValidRegions.clear();
  };

  virtual bool runOnFunction(Function &F) {
    SD = &getAnalysis<ScopDetection>();
    SE = &getAnalysis<ScalarEvolution>();

    polly::RejectedLog rl = SD->getRejectedLog();
    for (polly::RejectedLog::iterator
         i = rl.begin(), ie = rl.end(); i != ie; ++i) {
      const Region *R              = (*i).first;
      std::vector<RejectInfo> rlog = (*i).second;
      
      bool isValid = true;
      for (unsigned j=0; j < rlog.size(); ++j) {
        const SCEV *lhs = rlog[j].Failed_LHS;
        const SCEV *rhs = rlog[j].Failed_RHS;

        if (lhs)
          isValid &= NonAffineSCEVValidator::isJITable(lhs, R, SE);
        if (rhs)
          isValid &= NonAffineSCEVValidator::isJITable(rhs, R, SE);

        if (isValid) {
          ValidRegions.insert(R);
          outs() << "[polli] valid non affine SCoP! "
                 << R->getNameStr() << "\n";
        } else {
          outs() << "[polli] invalid non affine SCoP! "
                 << R->getNameStr() << "\n";
        }
      }
    }

    return false;
  };

  virtual void print(raw_ostream &OS, const Module *) const {

  };
  //@}
};

char NonAffineScopDetection::ID = 0;

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

void PolyJIT::runJitableSCoPDetection(Module &M) {
  FunctionPassManager FPM = FunctionPassManager(&M);

  FPM.doInitialization();
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe ; ++f) {
    if (f->isDeclaration())
      continue;

    outs() << "[polli] finding SCoPs in " << (*f).getName() << "\n";

    ScopDetection *SD = (ScopDetection *)polly::createScopDetectionPass();
    FPM.add(SD);
    FPM.add(new ScopDetectionResultsViewer());
    FPM.add(new NonAffineScopDetection());
    FPM.run(*f);
  }
  FPM.doFinalization();
}

void PolyJIT::runPollyPreoptimizationPasses(Module &M) {
  FunctionPassManager FPM = FunctionPassManager(&M);
  
  registerPollyPreoptPasses(FPM);

  FPM.doInitialization();
  for (Module::iterator f = M.begin(), fe = M.end(); f != fe ; ++f) {
    if (f->isDeclaration())
      continue;

    outs() << "[polli] preoptimizing: " << (*f).getName() << "\n";
    FPM.run(*f);
  }
  FPM.doFinalization();
}