//===-- BasePointers.cpp - BasePointer analysis for PolyJIT -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file implements the base pointer analysis performed within PolyJIT.
/// In a first step all necessary basepointers that are required for Polly's
/// Runtime Alias Checks are required and optimized as a single entity that
/// can be queried by the JIT for a single code variant.
///
//===----------------------------------------------------------------------===//

#ifndef POLLI_BASEPOINTERS_H
#define POLLI_BASEPOINTERS_H

#include "llvm/Pass.h"
#include "polly/ScopPass.h"

using namespace llvm;

using polly::ScopPass;
using polly::Scop;

namespace polly {
class Scop;
}

namespace llvm {
class DominatorTree;
}

namespace polli {
class BasePointers : public ScopPass {
private:
  llvm::DominatorTree *DT;

public:
  static char ID;
  explicit BasePointers() : ScopPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  virtual void releaseMemory();
  virtual bool runOnScop(Scop &S);
  virtual void printScop(raw_ostream &OS, Scop &S) const;
  //@}
private:
  //===--------------------------------------------------------------------===//
  BasePointers(const BasePointers &) = delete;
  const BasePointers &operator=(const BasePointers &) = delete;
};

Pass *createBasePointersPass();
}

namespace llvm {
class PassRegistry;
void initializeBasePointersPass(llvm::PassRegistry &);
}
#endif /* end of include guard: POLLI_BASEPOINTERS_H */
