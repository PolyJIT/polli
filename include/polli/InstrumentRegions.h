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
#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/LoopInfo.h"
#include "polli/NonAffineScopDetection.h"

#include "polly/ScopDetection.h"
#include "polly/Support/ScopHelper.h"

#include "polly/LinkAllPasses.h"

#include "polly/CScopInfo.h"
#include "polly/CScopPass.h"

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

class PapiCScopProfiling : public CScopPass {
public:
  static char ID;

  explicit PapiCScopProfiling() : CScopPass(ID) {}

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<DominatorTree>();
    AU.addRequired<LoopInfo>();
    AU.addRequired<CScopInfo>();
    AU.setPreservesAll();
  }
  
  virtual bool runOnScop(CScop &S);

private:
  LoopInfo *LI;
  CScopInfo *CS;
  DominatorTree *DT;
  
  typedef std::pair<BasicBlock*,BasicBlock*> Edge;
  typedef std::pair<Edge, bool> AnnotatedEdge;
  typedef std::vector<AnnotatedEdge> SubRegions;
  typedef std::vector<SubRegions> BlockList;
  
  BlockList BlocksToInstrument;
  void instrumentRegion(Module *M, BasicBlock &Entry, BasicBlock &Exit);

  void print(raw_ostream &OS, const Module *) const;
  virtual void printScop(raw_ostream &OS) const {}
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
};
}


namespace llvm {
  class PassRegistry;
  void initializePapiRegionProfilingPass(llvm::PassRegistry&);
  void initializePapiCScopProfilingPass(llvm::PassRegistry&);
}
#endif // POLLI_INSTRUMENT_REGIONS_H

