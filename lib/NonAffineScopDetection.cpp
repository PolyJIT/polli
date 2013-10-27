//===-- NonAffineScopDetection.cpp ---------------------------- -----------===//
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
#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

#include "polli/NonAffineScopDetection.h"

#include "llvm/ADT/Statistic.h"
#include "llvm/Support/CommandLine.h"

static cl::opt<bool>
AnalyzeOnly("analyze", cl::desc("Only perform analysis, no optimization"));

using namespace llvm;
using namespace polly;

STATISTIC(JitScopsFound, "Number of jitable SCoPs");
STATISTIC(JitNonAffineLoopBound, "Number of fixable non affine loop bounds");
STATISTIC(JitNonAffineCondition, "Number of fixable non affine conditions");
STATISTIC(JitNonAffineAccess, "Number of fixable non affine accesses");
STATISTIC(AliasingIgnored, "Number of ignored aliasings");

void NonAffineScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScalarEvolution>();
  AU.addRequired<DominatorTree>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
}
;

bool NonAffineScopDetection::runOnFunction(Function &F) {
  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  DT = &getAnalysis<DominatorTree>();
  RI = &getAnalysis<RegionInfo>();
  M = F.getParent();

  DEBUG(dbgs() << "[polli] Running on: " << F.getName() << "\n");
  for (ScopDetection::const_iterator i = SD->begin(), ie = SD->end(); i != ie;
       ++i)
    AccumulatedScops.insert(*i);

  polly::RejectedLog rl = SD->getRejectedLog();

  for (polly::RejectedLog::iterator i = rl.begin(), ie = rl.end(); i != ie;
       ++i) {
    const Region *R = (*i).first;
    std::vector<RejectInfo> rlog = (*i).second;

    bool isValid = true;
    ParamList params;
    for (unsigned j = 0; j < rlog.size(); ++j) {
      const SCEV *lhs = rlog[j].Failed_LHS;
      const SCEV *rhs = rlog[j].Failed_RHS;
      RejectKind kind = rlog[j].Reason;
    
      if (!isValid)
        break;

      // Can we handle the reject reason?
      isValid &= (kind == NonAffineLoopBound || kind == NonAffineCondition ||
                  kind == NonAffineAccess || kind == Alias);

      // Extract parameters and insert in the map.
      if (!RequiredParams.count(R))
        RequiredParams[R] = ParamList();

      switch (kind) {
      case NonAffineCondition:
        isValid &= polly::isNonAffineExpr(R, rhs, *SE);
        if (isValid) {
          DEBUG(rhs->dump());
          params = getParamsInNonAffineExpr(R, rhs, *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
        }
      case NonAffineAccess:
      case NonAffineLoopBound:
        isValid &= polly::isNonAffineExpr(R, lhs, *SE);
        if (isValid) {
          DEBUG(lhs->dump());
          params = getParamsInNonAffineExpr(R, lhs, *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
        }
        break;
      default: /* Nothing to check. */
        break;
      }
    }

    if (isValid) {
      for (auto &RI : rlog) {
        switch (RI.Reason) {
        case NonAffineCondition:
          ++JitNonAffineCondition;
          break;
        case NonAffineAccess:
          ++JitNonAffineAccess;
          break;
        case NonAffineLoopBound:
          ++JitNonAffineLoopBound;
          break;
        case Alias:
          ++AliasingIgnored;
          break;
        default: /* Nothing */;
        }
      }
      AccumulatedScops.insert(R);
      JitableScops.insert(R);
      ++JitScopsFound;
    }

    // We know that the current detection errors can be fixed, so we need to
    // enter the expand phase.

    DEBUG(
      if (isValid)
        dbgs() << " JITABLE SCoP! "
               << R->getNameStr() << "\n";
      else
        dbgs() << " NON-JITABLE SCoP! "
               << R->getNameStr() << "\n"
    );
  }

  return false;
}
;

void NonAffineScopDetection::print(raw_ostream &OS, const Module *) const {
  for (ParamMap::const_iterator r = RequiredParams.begin(),
                                RE = RequiredParams.end();
       r != RE; ++r) {
    const Region *R = r->first;
    ParamList Params = r->second;

    OS.indent(4) << R->getNameStr() << "(";
    for (ParamList::iterator i = Params.begin(), e = Params.end(); i != e;
         ++i) {
      (*i)->print(OS.indent(1));
    }
    OS << " )\n";
  }
}
;

void NonAffineScopDetection::releaseMemory() {
  JitableScops.clear();
  AccumulatedScops.clear();
  RequiredParams.clear();
}

char NonAffineScopDetection::ID = 0;

INITIALIZE_PASS_BEGIN(NonAffineScopDetection, "polli-detect",
                      "Polli JIT ScopDetection", false, false);
INITIALIZE_PASS_DEPENDENCY(ScopDetection);
INITIALIZE_PASS_DEPENDENCY(ScalarEvolution);
INITIALIZE_PASS_DEPENDENCY(DominatorTree);
INITIALIZE_PASS_DEPENDENCY(RegionInfo);
INITIALIZE_PASS_END(NonAffineScopDetection, "polli-detect",
                      "Polli JIT ScopDetection", false, false);
