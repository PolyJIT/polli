//===- InstrumentRegions.cpp - Instrument Regions PAPI ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// 
// This takes a region and instruments the Entry and Exit blocks with calls
// to the PAPI library.
//
// The initial implementation only instruments the region with timing calls
// to measure the runtime that was spent inside the region.
//
// We need to make sure that the instrumentation is placed one a single entry
// edge and a single exit edge. Therefore, it is necessary to transform the
// regions before we perform any instrumentation.
//===----------------------------------------------------------------------===//
#ifndef POLLI_INSTRUMENT_REGIONS_H
#define POLLI_INSTRUMENT_REGIONS_H

#include "llvm/Pass.h"
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
}


typedef SmallVector<std::pair<Instruction *, Instruction *>, 8> TimerPairs;

namespace polli {

class PapiCScopProfilingInit : public ModulePass {
public:
  static char ID;
  explicit PapiCScopProfilingInit() : ModulePass(ID) {};

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    //AU.setPreservesAll();
  }

  virtual bool runOnModule(Module &M);
};

class PapiCScopProfiling : public FunctionPass {
public:
  static char ID;

  explicit PapiCScopProfiling() : FunctionPass(ID) {}

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetection>();
    AU.addRequired<NonAffineScopDetection>();
    AU.addRequired<RegionInfo>();
  }
  
  virtual bool runOnFunction(Function &F);

private:
  LoopInfo *LI;
  ScopDetection *SD;
  NonAffineScopDetection *NSD;
  DominatorTree *DT;
  RegionInfo *RI;

  bool processRegion(const Region *R);
  void instrumentRegion(Module *M, std::vector<BasicBlock *> &EntryBBs,
                        std::vector<BasicBlock *> &ExitBBs, const Region *R, std::string entryName, std::string exitName);

  void print(raw_ostream &OS, const Module *) const {}
};
}


namespace llvm {
  class PassRegistry;
  void initializePapiCScopProfilingPass(llvm::PassRegistry&);
  void initializePapiCScopProfilingInitPass(llvm::PassRegistry&);
}
#endif // POLLI_INSTRUMENT_REGIONS_H

