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
#include "llvm/IR/Function.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <set>

using namespace llvm;

namespace polli {
class ScopMapper : public FunctionPass {
public:
  typedef std::set<Function *> FunctionSet;
  typedef FunctionSet::iterator iterator;

  iterator begin() { return CreatedFunctions.begin(); }
  iterator end() { return CreatedFunctions.end(); }

  typedef std::set<Module *> ModuleSet;
  typedef ModuleSet::iterator module_iterator;

  module_iterator modules_begin() { return CreatedModules.begin(); }
  module_iterator modules_end() { return CreatedModules.end(); }

  static char ID;
  explicit ScopMapper() : FunctionPass(ID) {}
  
  void moveFunctionIntoModule(Function *F, Module *Dest);

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  virtual void releaseMemory() {};
  virtual bool runOnFunction(Function &F);
  virtual void print(raw_ostream &OS, const Module *) const {};
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopMapper(const ScopMapper&);
  // DO NOT IMPLEMENT
  const ScopMapper &operator=(const ScopMapper &);

  ValueToValueMapTy VMap;
  
  Module *M;
  FunctionSet CreatedFunctions;
  ModuleSet CreatedModules;
};
}
#endif //POLLI_SCOP_MAPPER_H
