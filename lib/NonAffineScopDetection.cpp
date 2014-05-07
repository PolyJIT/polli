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
#include "polly/Support/SCEVValidator.h"

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
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
}

bool NonAffineScopDetection::runOnFunction(Function &F) {
  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  RI = &getAnalysis<RegionInfo>();
  M = F.getParent();

  DEBUG(dbgs() << "[polli] Running on: " << F.getName() << "\n");
  for (ScopDetection::const_iterator i = SD->begin(), ie = SD->end(); i != ie;
       ++i)
    AccumulatedScops.insert(*i);

  if (!Enabled)
    return false;

  for (ScopDetection::const_reject_iterator i = SD->reject_begin(),
                                            ie = SD->reject_end();
       i != ie; ++i) {
    const Region *R = (*i).first;
    RejectLog Log = (*i).second;

    bool isValid = true;
    ParamList params;
    for (auto Reason : Log) {
      if (!isValid)
        break;

      assert(R && "We logged a non existing region, what the hell.");

      if (!RequiredParams.count(R))
        RequiredParams[R] = ParamList();

      RejectReason *ReasonPtr = Reason.get();

      if (ReportNonAffineAccess *NonAffAccess =
              dyn_cast<ReportNonAffineAccess>(ReasonPtr)) {
        isValid &= polly::isNonAffineExpr(R, NonAffAccess->get(), *SE);
        if (isValid) {
          DEBUG(NonAffAccess->get()->dump());
          params = getParamsInNonAffineExpr(R, NonAffAccess->get(), *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
          ++JitNonAffineAccess;
        }
      }

      if (ReportNonAffBranch *NonAffBranch =
              dyn_cast<ReportNonAffBranch>(ReasonPtr)) {
        isValid &= polly::isNonAffineExpr(R, NonAffBranch->lhs(), *SE);
        if (isValid) {
          DEBUG(NonAffBranch->lhs()->dump());
          params = getParamsInNonAffineExpr(R, NonAffBranch->lhs(), *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
          ++JitNonAffineCondition;
        }
        isValid &= polly::isNonAffineExpr(R, NonAffBranch->rhs(), *SE);
        if (isValid) {
          DEBUG(NonAffBranch->rhs()->dump());
          params = getParamsInNonAffineExpr(R, NonAffBranch->rhs(), *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
        }
      }

      if (ReportLoopBound *NonAffLoopBound =
              dyn_cast<ReportLoopBound>(ReasonPtr)) {
        isValid &= polly::isNonAffineExpr(R, NonAffLoopBound->loopCount(), *SE);
        if (isValid) {
          DEBUG(NonAffLoopBound->loopCount()->dump());
          params =
              getParamsInNonAffineExpr(R, NonAffLoopBound->loopCount(), *SE);
          RequiredParams[R]
              .insert(RequiredParams[R].end(), params.begin(), params.end());
          ++JitNonAffineLoopBound;
        }
      }

      if (ReportAlias *Alias = dyn_cast<ReportAlias>(ReasonPtr)) {
        DEBUG(dbgs() << Alias->getMessage() << "\n");
        ++AliasingIgnored;
      }

      // Extract parameters and insert in the map.
      if (isValid) {
        AccumulatedScops.insert(R);
        JitableScops.insert(R);
        ++JitScopsFound;
      }
    }

    // We know that the current detection errors can be fixed, so we need to
    // enter the expand phase.

    DEBUG(if (isValid) dbgs() << " JITABLE SCoP! " << R->getNameStr() << "\n";
          else dbgs() << " NON-JITABLE SCoP! " << R->getNameStr() << "\n");
  }

  return false;
};

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
};

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
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass);
INITIALIZE_PASS_DEPENDENCY(RegionInfo);
INITIALIZE_PASS_END(NonAffineScopDetection, "polli-detect",
                    "Polli JIT ScopDetection", false, false);
