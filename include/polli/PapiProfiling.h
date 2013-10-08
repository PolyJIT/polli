#ifndef LLVM_PAPI_PROFILING_H
#define LLVM_PAPI_PROFILING_H

#include "llvm/Pass.h"
#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/LoopInfo.h"
#include "polli/NonAffineScopDetection.h"

#include "polly/ScopDetection.h"
#include "polly/Support/ScopHelper.h"

#include "polly/LinkAllPasses.h"

namespace llvm {

class Value;
class Instruction;
class GlobalVariable;
class GlobalValue;
class LoopInfo;
class PointerType;
class RegionInfo;
class Region;

typedef SmallVector<std::pair<Instruction *, Instruction *>, 8> TimerPairs;

class PapiRegionPrepare : public RegionPass {
public:
  static char ID;

  explicit PapiRegionPrepare() : RegionPass (ID) {}
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<LoopInfo>();
    AU.addRequired<DominatorTree>();
    AU.addRequired<ScopDetection>();
    AU.addRequired<NonAffineScopDetection>();
    AU.setPreservesAll();
  }

  virtual bool runOnRegion(Region *R, RGPassManager &RGM);

private:
  LoopInfo *LI;
  DominatorTree *DT;

  bool isParent(Region *R, Region *Child);
  void createPapiEntry(Region *R);
  void createPapiExit(Region *R);
};

class PapiProfiling : public ModulePass {
public:
  static char ID;

  explicit PapiProfiling() : ModulePass (ID) {}
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }

  virtual bool runOnModule(Module &M);
  virtual void print(raw_ostream &OS, const Module *) const;

private:
  void instrumentFunction(int idx, Function *F,
                          GlobalValue *Array);
};

class PapiRegionProfiling : public FunctionPass {
public:
  static char ID;

  explicit PapiRegionProfiling() : FunctionPass(ID) {}
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<DominatorTree>();
    AU.addRequired<LoopInfo>();
    AU.addRequired<RegionInfo>();
    // Only if we're profiling SCoPs. Make this an option!
    AU.addRequired<ScopDetection>();
    AU.addRequired<NonAffineScopDetection>();
    AU.setPreservesAll();
  }

  virtual bool runOnFunction(Function &F);
  virtual bool doFinalization(Module &M);
  virtual void print(raw_ostream &OS, const Module *) const {};
private:
  RegionInfo *RI;
  LoopInfo *LI;
  NonAffineScopDetection *JSD;
  DominatorTree *DT;

  typedef std::pair<BasicBlock*,BasicBlock*> Edge;
  typedef std::pair<Edge, bool> AnnotatedEdge;
  typedef std::vector<AnnotatedEdge> SubRegions;
  typedef std::vector<SubRegions> BlockList;

  BlockList BlocksToInstrument;
  void instrumentRegion(unsigned idx, Module *M, SubRegions Edges,
                          GlobalValue *Array);
  BasicBlock *getSafeEntryFor(BasicBlock *Entry,
                              BasicBlock *Exit);
  BasicBlock *getSafeExitFor(BasicBlock *Entry,
                             BasicBlock *Exit);
//  bool isValidBB(BasicBlock *Dominator, BasicBlock *BB);
};
}

namespace llvm {
  class PassRegistry;
  void initializePapiProfilingPass(llvm::PassRegistry&);
  void initializePapiRegionProfilingPass(llvm::PassRegistry&);
  void initializePapiRegionPreparePass(llvm::PassRegistry&);
}
#endif // LLVM_PAPI_PROFILING_H
