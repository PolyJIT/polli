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

#include "polly/Support/SCEVAffinator.h"
#include "polly/ScopInfo.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/raw_ostream.h"

#include "isl/Aff.h"
#include "isl/Ctx.hpp"
#include "isl/Constraint.hpp"
#include "isl/LocalSpace.hpp"
#include "isl/PwAff.hpp"
#include "isl/Set.hpp"
#include "isl/Space.hpp"
#include "isl/UnionMap.hpp"
#include "isl/UnionSet.hpp"
#include "isl/Val.hpp"

#include "format.h"

using namespace isl;
using namespace polli;
using namespace polly;
using namespace llvm;

namespace polli {
char BasePointers::ID = 0;

void BasePointers::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<polly::ScopInfoRegionPass>();
  AU.addRequired<llvm::DominatorTreeWrapperPass>();
  AU.addRequired<llvm::ScalarEvolutionWrapperPass>();
  AU.addRequired<llvm::LoopInfoWrapperPass>();
}

void BasePointers::releaseMemory() {}

struct SubExpr {
public:
  const Value *V;
  UnionMap AccessRelation;
  SmallVector<std::shared_ptr<SubExpr>, 4> Operands;

  SubExpr(const Value *V, UnionMap AccessRelation)
      : V(V), AccessRelation(AccessRelation) {}

  SubExpr(const Value *V, Ctx &C) : V(V) {
    AccessRelation = UnionMap::empty(Space::alloc(C, 0, 0, 0));
  }

  virtual void print(raw_ostream &OS, unsigned indent = 0) const {
    (OS << "\n").indent(indent) << "SubExpr: {";
    (OS << "\n").indent(indent + 2) << "V: "; V->print(OS);
    (OS << "\n").indent(indent + 2) << "A: " << AccessRelation.toStr();
    for (auto &Op : Operands) {
      Op->print(OS, indent + 2);
    }
    (OS << "\n").indent(indent) << "}\n";
  }

  void addOperand(std::shared_ptr<SubExpr> &Op) {
    AccessRelation = AccessRelation.union_(Op->AccessRelation);
    Operands.push_back(Op);
  }
};
using SubExprPtr = std::shared_ptr<SubExpr>;

struct InstructionStmt {
  const ScopStmt &Parent;
  Set Domain;
  Map Schedule;
  SubExprPtr SubEx;

  InstructionStmt(const ScopStmt &Parent, Set &Domain, const Map &Sched,
                  SubExprPtr SubEx)
      : Parent(Parent), Domain(Domain), Schedule(Sched), SubEx(SubEx) {}

  void print(raw_ostream &OS, unsigned indent = 0) {
    (OS << "\n").indent(indent) << "Inst: ";
    (OS << "\n").indent(indent)
        << fmt::format("{:s}\n", Schedule.toStr());
    SubEx->print(OS);
  }
};


struct InstructionScop {
  Ctx C;
  Scop &Parent;
  UnionMap Schedule;
  SmallVector<InstructionStmt, 16> Stmts;
  LoopInfo &LI;
  ScalarEvolution &SE;

  InstructionScop(Scop &Parent, LoopInfo &LI, ScalarEvolution &SE)
      : C(Ctx(Parent.getIslCtx())), Parent(Parent), Schedule(), LI(LI), SE(SE) {
    buildScop();
  }
  ~InstructionScop() {
    C.Give();
  }

  void print(raw_ostream &OS, unsigned indent = 0) {
    OS.indent(indent) << "Schedule {\n";
    OS.indent(indent + 4) << Schedule.toStr() << "\n";
    OS.indent(indent) << "}\n";
    OS.indent(indent) << "Statements {\n";
    for (auto &Stmt : Stmts) {
      Stmt.print(OS);
    }
    OS << "\n}\n";
  }
private:
  using ValueToSubExprMap = std::map<Value *, SubExprPtr>;

  ValueToSubExprMap ValToSubExpr;

  SubExprPtr getOrCreateSubExpr(Value *V, const ScopStmt &S) {
    if (ValToSubExpr.count(V))
      return ValToSubExpr[V];

    ValToSubExpr[V] = std::make_shared<SubExpr>(V, C);
    if (isa<PHINode>(V))
      return getOrCreateSubExpr(V, S);

    if (isa<LoadInst>(V) || isa<StoreInst>(V)) {
      Instruction *I = dyn_cast<Instruction>(V);
      if (MemoryAccess *Acc = S.getArrayAccessOrNULLFor(I)) {
        UnionMap Access =  UnionMap::fromMap(Map(C, Acc->getAccessRelation()));
        ValToSubExpr[V] = std::make_shared<SubExpr>(V, Access);
      }
    }

    SmallVector<SubExprPtr, 2> UsedSubExprs;
    if (Instruction *I = dyn_cast<Instruction>(V)) {
      for (Use &U : I->operands())
        UsedSubExprs.push_back(getOrCreateSubExpr(U.get(), S));

      for (SubExprPtr SubEx : UsedSubExprs)
        ValToSubExpr[V]->addOperand(SubEx);
    }

    return getOrCreateSubExpr(V, S);
  }

  void buildScop() {
    UnionMap ParentSched(C, Parent.getSchedule());
    Space NewSpace = Space::paramsAlloc(C, Parent.getNumParams());

    for (const ScopStmt &Stmt : Parent) {
      Set Domain(C, Stmt.getDomain());
      BasicBlock *BB = Stmt.getBasicBlock();
      Map Schedule = Map(C, Stmt.getSchedule());

      int i = 0;
      for (Instruction &I : *BB) {
        Map InstSchedule = Schedule.addDims(DimType::Out, 1);
        Id InstId = Id::alloc(
            C, fmt::format("Inst_{:s}_{:d}", BB->getName().str(), i), &I);
        Val Idx = Val::intFromSi(C, i++);
        int idx = InstSchedule.dim(DimType::Out);

        SubExprPtr SubExpr = getOrCreateSubExpr(&I, Stmt);
        if (isa<StoreInst>(SubExpr->V)) {
          InstSchedule = InstSchedule.fixVal(DimType::Out, idx - 1, Idx);
          InstSchedule = InstSchedule.setTupleId(DimType::In, InstId);
          Stmts.push_back(InstructionStmt(Stmt, Domain, InstSchedule, SubExpr));
        }
      }
    }

    Schedule = UnionMap::empty(NewSpace);
    for (InstructionStmt &IS : Stmts) {
      Schedule = Schedule.addMap(IS.Schedule);
    }
  }
};

bool BasePointers::runOnScop(Scop &S) {
  DT = &getAnalysis<llvm::DominatorTreeWrapperPass>().getDomTree();
  ScalarEvolution *SE = &getAnalysis<llvm::ScalarEvolutionWrapperPass>().getSE();
  LoopInfo *LI = &getAnalysis<llvm::LoopInfoWrapperPass>().getLoopInfo();

  InstructionScop IS(S, *LI, *SE);
  IS.print(outs());

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
