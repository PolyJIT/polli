//===-- JitScopDetection.h --------------------------------*- C++ -*-===//
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
typedef std::vector<const SCEV *> ParamList;
typedef std::map<const Region *, ParamList> ParamMap;

namespace polli {
class JitScopDetection : public FunctionPass {
public:
  static char ID;
  explicit JitScopDetection(bool enable = true)
      : FunctionPass(ID), Enabled(enable) {}

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

  // Ignore this function during detection.
  void ignoreFunction(const Function *F) {
    IgnoredFunctions.insert(F);
  }

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
  JitScopDetection(const JitScopDetection &);
  // DO NOT IMPLEMENT
  const JitScopDetection &operator=(const JitScopDetection &);

  ScopDetection *SD;
  ScalarEvolution *SE;
  DominatorTree *DT;
  RegionInfoPass *RI;

  Module *M;

  bool Enabled;

  ScopSet AccumulatedScops;
  ScopSet JitableScops;

  ParamMap RequiredParams;

  std::set<const Function *> IgnoredFunctions;
};
} // end of polli namespace
#endif
