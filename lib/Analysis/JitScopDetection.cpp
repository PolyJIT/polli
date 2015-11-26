//===-- JitScopDetection.cpp ---------------------------- -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2015 - Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include "polli/JitScopDetection.h"

#include <map>
#include <memory>
#include <set>
#include <string>
#include <utility>
#include <vector>

#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "polly/ScopDetection.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/Support/SCEVValidator.h"
#include "llvm/InitializePasses.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassSupport.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include "polly/LinkAllPasses.h"
#include "polly/Canonicalization.h"
#include "polli/ScopDetectionCheckers.h"
#include "polli/Utils.h"
#include "polli/Options.h"

#include "cppformat/format.h"

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;
using namespace polli;

STATISTIC(JitScopsFound, "Number of jitable SCoPs");

class DiagnosticJitScopFound : public DiagnosticInfo {
private:
  static int PluginDiagnosticKind;

  Function &F;
  std::string FileName;
  unsigned EntryLine, ExitLine;

public:
  DiagnosticJitScopFound(Function &F, std::string FileName, unsigned EntryLine,
                         unsigned ExitLine)
      : DiagnosticInfo(PluginDiagnosticKind, DS_Note), F(F),
        FileName(std::move(FileName)), EntryLine(EntryLine),
        ExitLine(ExitLine) {}

  void print(DiagnosticPrinter &DP) const override;
  static bool classof(const DiagnosticInfo *DI) {
    return DI->getKind() == PluginDiagnosticKind;
  }
};

void JitScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<LoopInfoWrapperPass>();
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScalarEvolutionWrapperPass>();
  AU.addRequired<RegionInfoPass>();
  AU.setPreservesAll();
}

static void emitClassicalSCoPs(const Function &F, const ScopSet &Scops) {
  LLVMContext &Ctx = F.getContext();

  DebugLoc Begin, End;

  for (const Region *R : Scops) {
    getDebugLocations(R, Begin, End);

    emitOptimizationRemark(Ctx, DEBUG_TYPE, F, Begin,
                          "A classic SCoP begins here.");
    emitOptimizationRemark(Ctx, DEBUG_TYPE, F, End, "A classic SCoP ends here.");
  }
}

static void emitJitSCoPs(const Function &F, const ScopSet &Scops) {
  LLVMContext &Ctx = F.getContext();

  DebugLoc Begin, End;

  for (const Region *R : Scops) {
    getDebugLocations(R, Begin, End);

    emitOptimizationRemark(Ctx, DEBUG_TYPE, F, Begin,
                          "A JIT SCoP begins here.");
    emitOptimizationRemark(Ctx, DEBUG_TYPE, F, End, "A JIT SCoP ends here.");
  }
}

static bool sharesBlocks(const Region *CurR, const Region *R) {
  for (auto I = CurR->element_begin(), E = CurR->element_end(); I != E; ++I)
    if (!I->isSubRegion() && CurR->contains(I->getNodeAs<BasicBlock>())) {
      DEBUG(dbgs() << fmt::format("Region: {} shares blocks with {}",
                                  CurR->getNameStr(), R->getNameStr()));
      return true;
    }

  return false;
}

struct less_than_region_ptr {
  inline bool operator()(const Region *LHS, const Region *RHS) {
    return LHS->getNameStr() < RHS->getNameStr();
  }
};

bool operator<(const Region &LHS, const Region &RHS) {
  assert(sharesBlocks(&LHS, &RHS) &&
         "LHS & RHS don't share any blocks, reject.");

  unsigned LeftCnt = 0;
  unsigned RightCnt = 0;

  for (auto I = LHS.element_begin(), E = LHS.element_end(); I != E; ++I) {
    if (!I->isSubRegion())
      LeftCnt++;
  }

  for (auto I = RHS.element_begin(), E = RHS.element_end(); I != E; ++I) {
    if (!I->isSubRegion())
      RightCnt++;
  }

  DEBUG(dbgs() << fmt::format("{} < {}", LeftCnt, RightCnt));
  return LeftCnt < RightCnt;
}

bool JitScopDetection::runOnFunction(Function &F) {
  if (!Enabled)
    return false;

  if (F.isDeclaration())
    return false;

  if (F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolutionWrapperPass>().getSE();
  RI = &getAnalysis<RegionInfoPass>();
  M = F.getParent();

  DEBUG(dbgs() << fmt::format("== Detect JIT SCoPs in function: {:>30}",
                              F.getName().str()));
  for (ScopDetection::const_reject_iterator Rej = SD->reject_begin(),
                                            RejE = SD->reject_end();
       Rej != RejE; ++Rej) {
    const Region *R = (*Rej).first;
    if (!R)
      continue;

    Loop *L = nullptr;
    for (auto BB : R->blocks()) {
      L = LI->getLoopFor(BB);
      if (L)
        break;
    }
    if (!L)
      continue;

    DEBUG(dbgs() << fmt::format("==== Next Region: {:>60s}", R->getNameStr()));
    RejectLog Log = (*Rej).second;

    NonAffineAccessChecker NonAffAccessChk(R, SE);
    NonAffineBranchChecker NonAffBranchChk(R, SE);
    NonAffineLoopBoundChecker LoopBoundChk(R, SE);
    AliasingChecker AliasChk;
    //ProfitableChecker ProfitableChk;

    ParamList Params;
    bool RegionIsValid = Log.size() > 0;

    for (auto &Reason : Log) {
      bool IsFixable = false;
      IsFixable |= isValid(NonAffAccessChk, *Reason);
      IsFixable |= isValid(NonAffBranchChk, *Reason);
      IsFixable |= isValid(LoopBoundChk, *Reason);
      IsFixable |= isValid(AliasChk, *Reason);
      //IsFixable |= isValid(ProfitableChk, *Reason);

      RegionIsValid &= IsFixable;
    }

    if (RegionIsValid) {
      ParamList &L = RequiredParams[R];
      ParamList Tmp = NonAffAccessChk.params();
      L.insert(L.end(), Tmp.begin(), Tmp.end());

      Tmp = NonAffBranchChk.params();
      L.insert(L.end(), Tmp.begin(), Tmp.end());

      Tmp = LoopBoundChk.params();
      L.insert(L.end(), Tmp.begin(), Tmp.end());

      JitableScops.insert(R);
      ++JitScopsFound;
    }
  }

  // Yikes :O%. Make our post-analysis filtering predictable.
  std::vector<Region *> SortedJitScops;
  for (auto &R : JitableScops) {
    SortedJitScops.push_back(const_cast<Region *>(R));
  }

  // Add the classic SCoPs from Polly too (filtering and stuff).
  for (auto &R : *SD) {
    SortedJitScops.push_back(const_cast<Region *>(R));
  }
  std::stable_sort(SortedJitScops.begin(), SortedJitScops.end(),
                   less_than_region_ptr());

  ScopSet Rejected;
  for (Region *LHS : SortedJitScops) {
    if (Rejected.count(LHS))
      continue;

    for (Region *RHS : SortedJitScops) {
      if (LHS == RHS || Rejected.count(RHS))
        continue;

      if (sharesBlocks(LHS, RHS)) {
        if (*LHS < *RHS) {
          Rejected.insert(LHS);
          DEBUG(dbgs() << fmt::format("Rejecting: ", LHS->getNameStr()));
          break;
        }
        else {
          Rejected.insert(RHS);
          DEBUG(dbgs() << fmt::format("Rejecting: ", RHS->getNameStr()));
        }
    }
    }
  }

  ScopSet ClassicScops;
  ClassicScops.insert(SD->begin(), SD->end());
  for (const Region *R : Rejected) {
    JitScopsFound -= 1;
    if (JitableScops.count(R))
      JitableScops.remove(R);
    if (ClassicScops.count(R))
      ClassicScops.remove(R);
  }

  AccumulatedScops.insert(ClassicScops.begin(), ClassicScops.end());
  AccumulatedScops.insert(JitableScops.begin(), JitableScops.end());

  if (opt::AnalyzeIR) {
    emitClassicalSCoPs(F, ClassicScops);
    emitJitSCoPs(F, JitableScops);
  }

  return false;
}

void JitScopDetection::print(raw_ostream &OS, const Module *) const {
  using reject_iterator = std::map<const Region *, RejectLog>::const_iterator;
  using reject_range = iterator_range<reject_iterator>;

  unsigned count = JitableScops.size();
  unsigned i = 0;

  OS << fmt::format("{:d} regions require runtime support:\n", count);
  for (const Region *R : AccumulatedScops) {
    if (!R || (R && !RequiredParams.count(R)))
      continue;
    const ParamList &L = RequiredParams.at(R);
    OS.indent(2) << fmt::format("{:d} region {:s} requires {:d} params\n", i++,
                                R->getNameStr(), L.size());
    unsigned j = 0;
    for (const SCEV *S : L) {
      OS.indent(4) << fmt::format("{:d} - ", j);
      S->print(OS);
      OS << "\n";
    }

    const reject_range Rejects(SD->reject_begin(), SD->reject_end());
    for (auto &Reject : Rejects) {
      if (Reject.first == R) {
        unsigned k = 0;
        polly::RejectLog Log = Reject.second;
        OS.indent(4) << fmt::format("{:d} reasons can be fixed at run time:\n",
                                    Log.size());
        for (auto &Entry : Reject.second) {
          OS.indent(6) << fmt::format("{:d} - {:s}\n", k++,
                                      Entry->getMessage());
        }
      }
    }
  }
}

void JitScopDetection::releaseMemory() {
  JitableScops.clear();
  AccumulatedScops.clear();
  RequiredParams.clear();
}

char JitScopDetection::ID = 0;

static RegisterPass<JitScopDetection>
    X("polli-detect", "PolyJIT - Detect SCoPs that require runtime support.",
      false, false);
