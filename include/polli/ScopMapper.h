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

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

#include "llvm/Pass.h"

#include <set>

using namespace llvm;

namespace polli {

class ScopMapper : public FunctionPass {
public:
  typedef std::set<Function *> FunctionSet;
  typedef FunctionSet::iterator iterator;

  iterator begin() { return CreatedFunctions.begin(); }
  iterator end() { return CreatedFunctions.end(); }
  FunctionSet &getCreatedFunctions() { return CreatedFunctions; }

  static char ID;
  explicit ScopMapper() : FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  virtual void releaseMemory() { CreatedFunctions.clear(); }
  virtual bool runOnFunction(Function &F);
  virtual void print(raw_ostream &, const Module *) const {}
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopMapper(const ScopMapper &);
  // DO NOT IMPLEMENT
  const ScopMapper &operator=(const ScopMapper &);

  FunctionSet CreatedFunctions;
};
}
#endif // POLLI_SCOP_MAPPER_H
