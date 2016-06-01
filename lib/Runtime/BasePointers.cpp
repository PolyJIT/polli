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

#include "polly/ScopInfo.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include "isl/Ctx.hpp"
#include "isl/Set.hpp"
#include "isl/Space.hpp"

using namespace polli;
using namespace polly;
using namespace llvm;

using isl::Ctx;
using isl::Set;
using isl::Space;
using isl::DimType;

namespace polli {
char BasePointers::ID = 0;

void BasePointers::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<polly::ScopInfoRegionPass>();
  AU.addRequired<llvm::DominatorTreeWrapperPass>();
}

void BasePointers::releaseMemory() {}

struct InstructionStmt {
  Set Domain;
  Instruction *Inst;
};

bool BasePointers::runOnScop(Scop &S) {
  DT = &getAnalysis<llvm::DominatorTreeWrapperPass>().getDomTree();

  Ctx C = Ctx(S.getIslCtx());

  for (ScopStmt &Stmt : S) {
    Set Domain(C, Stmt.getDomain());
    Space Space(C, Stmt.getDomainSpace());
    BasicBlock *BB = Stmt.getBasicBlock();

    int n = Domain.dim(DimType::Set);

    SmallVector<InstructionStmt, 4> Stmts;
    for (Instruction &I : *BB) {
      Set InstDomain = Domain.addDims(DimType::Set, n - 1);
      Stmts.push_back({InstDomain, &I});
    }

    for (auto &IStmt : Stmts) {
      std::string IDomStr;
      IDomStr = IStmt.Domain.toStr();
      outs() << IDomStr << "\n";
    }
  }

  C.Give();

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
                    false)
