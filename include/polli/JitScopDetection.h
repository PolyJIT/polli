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

#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <vector>
#include <map>

using namespace polly;

using ScopSet = llvm::SetVector<const llvm::Region *>;
using ParamList = std::vector<const llvm::SCEV *>;
using ParamMap = std::map<const llvm::Region *, ParamList>;

namespace polli {
class JitScopDetection : public llvm::FunctionPass {
public:
  static char ID;
  explicit JitScopDetection(bool enable = true)
      : llvm::FunctionPass(ID), Enabled(enable) {}

  using iterator = ParamMap::iterator;
  using const_iterator = ParamMap::const_iterator;

  iterator begin() { return RequiredParams.begin(); }
  iterator end() { return RequiredParams.end(); }

  const_iterator begin() const { return RequiredParams.begin(); }
  const_iterator end() const { return RequiredParams.end(); }

  int count(const Region *R) { return AccumulatedScops.count(R); }
  unsigned size() { return AccumulatedScops.size(); }

  /* JIT Scops */
  int countJS(const Region *R) { return JitableScops.count(R); }
  unsigned sizeJS() { return JitableScops.size(); }

  iterator_range<ScopSet::iterator> jitScops() {
    return iterator_range<ScopSet::iterator>(JitableScops.begin(),
                                             JitableScops.end());
  }

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
};
} // end of polli namespace
#endif
