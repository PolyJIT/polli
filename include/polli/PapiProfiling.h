#ifndef POLLI_PAPIPROFILING_H
#define POLLI_PAPIPROFILING_H

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Pass.h"

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
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<DominatorTreeWrapperPass>();
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

} // namespace llvm

namespace llvm {
  class PassRegistry;
  void initializePapiProfilingPass(llvm::PassRegistry&);
  void initializePapiRegionPreparePass(llvm::PassRegistry&);
} // namespace llvm
#endif // POLLI_PAPIPROFILING_H
