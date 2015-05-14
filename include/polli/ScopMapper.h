//===-- ScopMapper.h - Class definition for the ScopMapper ------*- C++ -*-===//
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
#ifndef POLLI_SCOP_MAPPER_H
#define POLLI_SCOP_MAPPER_H

#include "llvm/Pass.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

namespace polli {
class JitScopDetection;

/// @brief Extract SCoPs from the host function into a separate function.
///
/// This extracts all SCoPs of a function into separate functions and
/// replaces the SCoP with a call to the extracted function.
class ScopMapper : public llvm::FunctionPass {
public:
  using RegionSet = llvm::SetVector<const llvm::Region *>;

  llvm::iterator_range<RegionSet::iterator> regions() {
    return llvm::iterator_range<RegionSet::iterator>(MappableRegions.begin(),
                                                     MappableRegions.end());
  }

  static char ID;
  explicit ScopMapper() : FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  virtual void releaseMemory() { MappableRegions.clear(); }
  virtual bool runOnFunction(llvm::Function &F);
  virtual void print(llvm::raw_ostream &, const llvm::Module *) const {}
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopMapper(const ScopMapper &);
  // DO NOT IMPLEMENT
  const ScopMapper &operator=(const ScopMapper &);

  RegionSet MappableRegions;
  JitScopDetection *JSD;
  DominatorTreeWrapperPass *DTP;
};
}
#endif // POLLI_SCOP_MAPPER_H
