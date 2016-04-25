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
#include "polli/BasePointers.h"

#include "llvm/IR/Dominators.h"
#include "llvm/Pass.h"
#include "polly/ScopInfo.h"

using namespace isl;
using namespace llvm;
using namespace polli;

using llvm::DominatorTree;
using llvm::DominatorTreeWrapperPass;
using polly::Scop;

namespace polli {
char BasePointers::ID = 0;

void BasePointers::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<polly::ScopInfo>();
  AU.addRequired<llvm::DominatorTreeWrapperPass>();
}

void BasePointers::releaseMemory() {}

bool BasePointers::runOnScop(polly::Scop &S) {
  DT = &getAnalysis<llvm::DominatorTreeWrapperPass>().getDomTree();

  S.dump();

  return false;
}

void BasePointers::printScop(raw_ostream &OS, Scop &S) const {}

Pass *createBasePointersPass() {
  return reinterpret_cast<llvm::Pass *>(new polli::BasePointers());
}
}
INITIALIZE_PASS_BEGIN(BasePointers, "polli-analyze-base-pointers",
                      "Polli - Analyze Base Pointer usage in JitScops", false,
                      false);
INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass);
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass);
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass);
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass);
INITIALIZE_PASS_END(BasePointers, "polli-analyze-base-pointers",
                    "Polli - Analyze Base Pointer usage in JitScops", false,
                    false);
