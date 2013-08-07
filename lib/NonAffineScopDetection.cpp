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

#include "llvm/Support/CommandLine.h"

static cl::opt<bool>
AnalyzeOnly("analyze", cl::desc("Only perform analysis, no optimization"));

using namespace llvm;
using namespace polly;

void NonAffineScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScalarEvolution>();
  AU.addRequired<DominatorTree>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
};
  
bool NonAffineScopDetection::runOnFunction(Function &F) {
  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  DT = &getAnalysis<DominatorTree>();
  RI = &getAnalysis<RegionInfo>();
  M = F.getParent();

  DEBUG(dbgs() << "[polli] Running on: " << F.getName() << "\n");

  polly::RejectedLog rl = SD->getRejectedLog();
  for (polly::RejectedLog::iterator
       i = rl.begin(), ie = rl.end(); i != ie; ++i) {
    const Region *R              = (*i).first;
    std::vector<RejectInfo> rlog = (*i).second;
    RequiredParams[R] = ParamList();

    bool isValid = true;
    for (unsigned j=0; j < rlog.size(); ++j) {
      const SCEV *lhs = rlog[j].Failed_LHS;
      const SCEV *rhs = rlog[j].Failed_RHS;
      RejectKind kind = rlog[j].Reason;

      // We do not handle these reject reasons here.
      isValid &= (kind == NonAffineLoopBound ||
                  kind == NonAffineCondition ||
                  kind == NonAffineAccess);
      if (!isValid) {
        DEBUG(dbgs() << "[polli] reject reason was not related to affinity;"
                     << " continuing.\n");
        break;
      }

      ParamList params;
      if (kind == NonAffineLoopBound) {
        isValid &= polly::isNonAffineExpr(R, rhs, *SE);
        params = getParamsInNonAffineExpr(R, rhs, *SE);
        RequiredParams[R].insert(RequiredParams[R].end(),
                                 params.begin(), params.end());
      }

      if (kind == NonAffineAccess || kind == NonAffineCondition) {
        std::vector<const SCEV*> params;

        isValid &= polly::isNonAffineExpr(R, lhs, *SE);
        params = getParamsInNonAffineExpr(R, lhs, *SE);
        RequiredParams[R].insert(RequiredParams[R].end(),
                                 params.begin(), params.end());
      }
    }

    if (isValid)
      DEBUG(dbgs() << "[polli] valid non affine SCoP! "
                   << R->getNameStr() << "\n");
    else
      DEBUG(dbgs() << "[polli] invalid non affine SCoP! "
                   << R->getNameStr() << "\n");
  }

  if (AnalyzeOnly)
    print(dbgs(), F.getParent());

  return true;
};

void NonAffineScopDetection::print(raw_ostream &OS, const Module *) const {
  for (ParamMap::const_iterator r = RequiredParams.begin(),
                               RE = RequiredParams.end(); r != RE; ++r) {
    const Region *R = r->first;
    ParamList Params = r->second;

    OS.indent(4) << R->getNameStr() << "(";
    for (ParamList::iterator i = Params.begin(), e = Params.end();
         i != e; ++i) {
      (*i)->print(OS.indent(1));
    }
    OS << " )\n";
  }
};

char NonAffineScopDetection::ID = 0;
