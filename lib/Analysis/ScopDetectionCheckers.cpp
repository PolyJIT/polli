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
#include "polli/NonAffineSCEVs.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/ScalarEvolution.h"

#ifndef FORMAT_HEADER_ONLY
#define FORMAT_HEADER_ONLY
#endif /* ifndef FORMAT_HEADER_ONLY */
#define FORMAT_HEADER_ONLY
#include "cppformat/format.h"

#include <iostream>

STATISTIC(JitNonAffineLoopBound, "Number of fixable non affine loop bounds");
STATISTIC(JitNonAffineCondition, "Number of fixable non affine conditions");
STATISTIC(JitNonAffineAccess, "Number of fixable non affine accesses");

STATISTIC(NonAffineAccess, "Rejected JIT SCoP - Non-Affine access.");
STATISTIC(NonAffineLoopBound, "Rejected JIT SCoP - Non-Affine loop bound.");
STATISTIC(NonAffineBranch, "Rejected JIT SCoP - Non-Affine branch.");

STATISTIC(AliasingIgnored, "Number of ignored aliasings");
STATISTIC(UnprofitableIgnored, "Number of ignored uprofitable reports");

using namespace llvm;
using namespace polly;

namespace polli {
void NonAffineChecker::append(ParamList &&L) {
  Params.insert(Params.end(), L.begin(), L.end());
}

bool isValid(NonAffineAccessChecker &Chk, llvm::Loop *Scope,
             RejectReason &Reason, InvariantLoadsSetTy *ILS) {
  if (ReportNonAffineAccess *NonAff =
          dyn_cast<ReportNonAffineAccess>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();

    if (!isNonAffineExpr(R, Scope, NonAff->get(), *SE, nullptr /*FIXME*/,
                         ILS)) {
      ++NonAffineAccess;
      return false;
    }

    Chk.append(getParamsInNonAffineExpr(R, Scope, NonAff->get(), *SE,
                                        nullptr /*FIXME*/));
    ++JitNonAffineAccess;
    return true;
  }

  return false;
}

bool isValid(NonAffineBranchChecker &Chk, llvm::Loop *Scope,
             RejectReason &Reason, InvariantLoadsSetTy *ILS) {
  if (ReportNonAffBranch *NonAff = dyn_cast<ReportNonAffBranch>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();
    // Check LHS & Add parameters
    if (!isNonAffineExpr(R, Scope, NonAff->lhs(), *SE, nullptr /*FIXME*/,
                         ILS)) {
      ++NonAffineBranch;
      return false;
    }

    Chk.append(getParamsInNonAffineExpr(R, Scope, NonAff->lhs(), *SE,
                                        nullptr /*FIXME*/));

    // Check RHS & Add parameters
    if (!isNonAffineExpr(R, Scope, NonAff->rhs(), *SE, nullptr /*FIXME*/,
                         ILS)) {
      ++NonAffineBranch;
      return false;
    }
    ParamList RHSParams;

    Chk.append(getParamsInNonAffineExpr(R, Scope, NonAff->rhs(), *SE,
                                        nullptr /*FIXME*/));

    ++JitNonAffineCondition;
    return true;
  }
  return false;
}

bool isValid(NonAffineLoopBoundChecker &Chk, llvm::Loop *Scope,
             RejectReason &Reason, InvariantLoadsSetTy *ILS) {
  if (ReportLoopBound *NonAff = dyn_cast<ReportLoopBound>(&Reason)) {
    const Region *R = Chk.region();
    ScalarEvolution *SE = Chk.se();

    ParamList Params;
    Loop *L = const_cast<Loop *>(NonAff->loop());
    bool isValid = polli::isNonAffineExpr(R, L, NonAff->loopCount(), *SE,
                                          nullptr /*FIXME*/, ILS);
    if (isValid) {
      Chk.append(getParamsInNonAffineExpr(R, L, NonAff->loopCount(), *SE,
                                          nullptr /*FIXME*/));
      ++JitNonAffineLoopBound;
    } else {
      ++NonAffineLoopBound;
    }
    return isValid;
  }
  return false;
}

bool isValid(AliasingChecker &Chk, llvm::Loop *Scope, RejectReason &Reason,
             InvariantLoadsSetTy *ILS) {
  if (isa<ReportAlias>(&Reason)) {
    ++AliasingIgnored;
    return true;
  }

  return false;
}

bool isValid(ProfitableChecker &Chk, llvm::Loop *Scope, RejectReason &Reason,
             InvariantLoadsSetTy *ILS) {
  if (isa<ReportUnprofitable>(&Reason)) {
    ++UnprofitableIgnored;
    return true;
  }
  return false;
}

bool isValid(HoistableInvariantLoad &Chk, llvm::Loop *Scope,
             RejectReason &Reason, InvariantLoadsSetTy *ILS) {
  // Nothing to check, that's good, do not change the outcome (false).
  if (!ILS)
    return true;

  for (auto &I : *ILS) {
    if (!polly::isHoistableLoad(I, Chk.region(), Chk.loopInfo(), Chk.se()))
      return false;
  }
  return true;
}
} // namespace polli
