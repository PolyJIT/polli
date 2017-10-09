//===- ModuleExtractor.h - Class definition for the ScopMapper --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Copyright 2015 Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_MODULEEXTRACTOR_H
#define POLLI_MODULEEXTRACTOR_H

#include "llvm/ADT/SetVector.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"

namespace polli {
class ModuleExtractor : public llvm::FunctionPass {
private:
  llvm::SetVector<llvm::Function *> ExtractedFunctions;
public:
  static char ID;
  explicit ModuleExtractor() : llvm::FunctionPass(ID) {}

  using iterator = llvm::SetVector<llvm::Function *>::iterator;
  using const_iterator = llvm::SetVector<llvm::Function *>::const_iterator;
  iterator begin() { return ExtractedFunctions.begin(); }
  iterator end() { return ExtractedFunctions.end(); }
  const_iterator begin() const { return ExtractedFunctions.begin(); }
  const_iterator end() const { return ExtractedFunctions.end(); }

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
  virtual void releaseMemory() override;
  virtual bool runOnFunction(llvm::Function &M) override;
  virtual void print(llvm::raw_ostream &, const llvm::Module *) const override;
  //@}
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ModuleExtractor(const ModuleExtractor &);
  // DO NOT IMPLEMENT
  const ModuleExtractor &operator=(const ModuleExtractor &);
};

class ModuleInstrumentation : public llvm::FunctionPass {
public:
  static char ID;
  explicit ModuleInstrumentation() : llvm::FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
  virtual void releaseMemory() override;
  virtual bool runOnFunction(llvm::Function &M) override;
  virtual void print(llvm::raw_ostream &, const llvm::Module *) const override;
  //@}
private:
  llvm::SetVector<llvm::Function *> InstrumentedFunctions;
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ModuleInstrumentation(const ModuleInstrumentation &);
  // DO NOT IMPLEMENT
  const ModuleInstrumentation &operator=(const ModuleInstrumentation &);
};
}  // end of namespace polli
#endif // POLLI_MODULEEXTRACTOR_H
