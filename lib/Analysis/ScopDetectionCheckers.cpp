//===-- ScopDetectionCheckers.cpp ----------------------------- -----------===//
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

#include "polli/ScopDetectionCheckers.h"

#include "polly/ScopDetectionDiagnostic.h"
#include "polly/Support/SCEVValidator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/ScalarEvolution.h"

STATISTIC(JitNonAffineLoopBound, "Number of fixable non affine loop bounds");
STATISTIC(JitNonAffineCondition, "Number of fixable non affine conditions");
STATISTIC(JitNonAffineAccess, "Number of fixable non affine accesses");
STATISTIC(AliasingIgnored, "Number of ignored aliasings");
STATISTIC(UnprofitableIgnored, "Number of ignored uprofitable reports");

using namespace llvm;
using namespace polly;

namespace polli {
void NonAffineChecker::append(ParamList &&L) {
  Params.insert(Params.end(), L.begin(), L.end());
}

bool isValid(NonAffineAccessChecker &Chk, RejectReason &Reason) {
  if (ReportNonAffineAccess *NonAff =
          dyn_cast<ReportNonAffineAccess>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();

    if (!isNonAffineExpr(R, NonAff->get(), *SE))
      return false;

    Chk.append(getParamsInNonAffineExpr(R, NonAff->get(), *SE));
    ++JitNonAffineAccess;
    return true;
  }

  return false;
}

bool isValid(NonAffineBranchChecker &Chk, RejectReason &Reason) {
  if (ReportNonAffBranch *NonAff = dyn_cast<ReportNonAffBranch>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();
    // Check LHS & Add parameters
    if (!isNonAffineExpr(R, NonAff->lhs(), *SE))
      return false;

    Chk.append(getParamsInNonAffineExpr(R, NonAff->lhs(), *SE));

    // Check RHS & Add parameters
    if (!isNonAffineExpr(R, NonAff->rhs(), *SE))
      return false;
    ParamList RHSParams;

    Chk.append(getParamsInNonAffineExpr(R, NonAff->rhs(), *SE));

    ++JitNonAffineCondition;
    return true;
  }
  return false;
}

bool isValid(NonAffineLoopBoundChecker &Chk, RejectReason &Reason) {
  if (ReportLoopBound *NonAff = dyn_cast<ReportLoopBound>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();

    ParamList Params;
    bool isValid = polly::isNonAffineExpr(R, NonAff->loopCount(), *SE);
    if (isValid) {
      Chk.append(getParamsInNonAffineExpr(R, NonAff->loopCount(), *SE));
      ++JitNonAffineLoopBound;
    }
    return isValid;
  }
  return false;
}

bool isValid(AliasingChecker &Chk, RejectReason &Reason) {
  if (isa<ReportAlias>(&Reason)) {
    ++AliasingIgnored;
    return true;
  }

  return false;
}

bool isValid(ProfitableChecker &Chk, RejectReason &Reason) {
  if (isa<ReportUnprofitable>(&Reason)) {
    ++UnprofitableIgnored;
    return true;
  }
  return false;
}
} // namespace polli
