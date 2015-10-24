//===- ModuleExtractor.h - Class definition for the ScopMapper --*- C++ -*-===//
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
#ifndef POLLI_MODULE_EXTRACTOR_H
#define POLLI_MODULE_EXTRACTOR_H

#include "llvm/ADT/SetVector.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"

namespace polli {
Pass *createFunctionCleanupPass();

class ModuleExtractor : public llvm::FunctionPass {
public:
  static char ID;
  explicit ModuleExtractor() : llvm::FunctionPass(ID) {}

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
  ModuleExtractor(const ModuleExtractor &);
  // DO NOT IMPLEMENT
  const ModuleExtractor &operator=(const ModuleExtractor &);
};
} // end of namespace polli
#endif // POLLI_MODULE_EXTRACTOR_H
