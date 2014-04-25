//===-- NonAffineScopDetection.h --------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_NON_AFFINE_SCOP_DETECTION_H
#define POLLI_NON_AFFINE_SCOP_DETECTION_H

#include "polly/Support/SCEVValidator.h"

#include "polly/ScopDetection.h"

#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <vector>
#include <map>
#include <set>

using namespace llvm;
using namespace polly;

typedef std::set<const Region *> ScopSet;

class NonAffineScopDetection : public FunctionPass {
public:
  static char ID;
  explicit NonAffineScopDetection() : FunctionPass(ID) {}

  typedef std::vector<const SCEV *> ParamList;
  typedef std::map<const Region *, ParamList> ParamMap;
  typedef ParamMap::iterator iterator;
  typedef ParamMap::const_iterator const_iterator;
  
  iterator begin() { return RequiredParams.begin(); }
  iterator end() { return RequiredParams.end(); }

  const_iterator begin() const { return RequiredParams.begin(); }
  const_iterator end() const { return RequiredParams.end(); }

  int count(const Region *R) { return AccumulatedScops.count(R); }
  unsigned size() { return AccumulatedScops.size(); }

  /* JIT Scops */
  int countJS(const Region *R) { return JitableScops.count(R); }
  unsigned sizeJS() { return JitableScops.size(); }
  ScopSet::iterator jit_begin() { return JitableScops.begin(); }
  ScopSet::iterator jit_end() { return JitableScops.end(); }
  void enable(bool doEnable) { Enabled = doEnable; }

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  virtual void releaseMemory();

  virtual bool runOnFunction(Function &F);

  virtual void print(raw_ostream &OS, const Module *) const;
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
  
  bool Enabled;

  ScopSet AccumulatedScops;
  ScopSet JitableScops;

  ParamMap RequiredParams;
};

namespace llvm {
  class PassRegistry;
  void initializeNonAffineScopDetectionPass(llvm::PassRegistry&);
}
#endif
