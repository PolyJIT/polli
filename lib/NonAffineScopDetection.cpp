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

template <typename LC, typename RetVal>
class RejectLogChecker {
public:
  RetVal check(const RejectReason *Reason, const RetVal &Invalid = RetVal()) {
    LC * lc = (LC *)this;

    switch(Reason->getKind()) {
    case rrkNonAffineAccess:
      return lc->checkNonAffineAccess((ReportNonAffineAccess *)Reason);
    case rrkNonAffBranch:
      return lc->checkNonAffineBranch((ReportNonAffBranch *)Reason);
    case rrkLoopBound:
      return lc->checkLoopBound((ReportLoopBound *)Reason);
    case rrkAlias:
      return lc->checkAlias((ReportAlias *)Reason);
    default:
      return Invalid;
    }
  }
};

class AliasingLogChecker : public RejectLogChecker<AliasingLogChecker, bool> {
  const Region *R;
  ScalarEvolution *SE;
public:
  AliasingLogChecker(const Region *R) : R(R) {}

  bool checkNonAffineAccess(ReportNonAffineAccess *Reason) { return false; }
  bool checkNonAffineBranch(ReportNonAffBranch *Reason) { return false; }
  bool checkLoopBound(ReportLoopBound *Reason) { return false; }
  bool checkAlias(ReportAlias *Reason) {
    ++AliasingIgnored;
    return true;
  }
};

class NonAffineLogChecker : public RejectLogChecker < NonAffineLogChecker,
    std::pair<bool, ParamList> > {
private:
  const Region *R;
  ScalarEvolution *SE;
public:
  NonAffineLogChecker(const Region *R, ScalarEvolution *SE)
      : R(R), SE(SE) {}

  std::pair<bool, ParamList>
  checkNonAffineAccess(ReportNonAffineAccess *Reason) {
    ParamList Params;
    if (!polly::isNonAffineExpr(R, Reason->get(), *SE))
      return std::make_pair<>(false, Params);

    Params = polly::getParamsInNonAffineExpr(R, Reason->get(), *SE);
    ++JitNonAffineAccess;
    return std::make_pair<>(true, Params);
  }

  std::pair<bool, ParamList>
  checkNonAffineBranch(ReportNonAffBranch *Reason) {
    ParamList Params;

    if (!isNonAffineExpr(R, Reason->lhs(), *SE))
      return std::make_pair<>(false, Params);

    Params = getParamsInNonAffineExpr(R, Reason->lhs(), *SE);
    if (!isNonAffineExpr(R, Reason->rhs(), *SE))
      return std::make_pair<>(false, Params);

    ParamList RHSParams;
    RHSParams = getParamsInNonAffineExpr(R, Reason->rhs(), *SE);
    Params.insert(Params.end(), RHSParams.begin(), RHSParams.end());

    ++JitNonAffineCondition;
    return std::make_pair<>(true, Params);
  }

  std::pair<bool, ParamList>
  checkLoopBound(ReportLoopBound *Reason) {
    ParamList Params;
    bool isValid = polly::isNonAffineExpr(R, Reason->loopCount(), *SE);
    if (isValid) {
      Params = getParamsInNonAffineExpr(R, Reason->loopCount(), *SE);
      ++JitNonAffineLoopBound;
    }
    return std::make_pair<>(isValid, Params);
  }

  std::pair<bool, ParamList>
  checkAlias(ReportAlias *Reason) {
    ParamList Params;
    return std::make_pair<>(false, Params);
  }
};

void NonAffineScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScalarEvolution>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
}

static void printParameters(ParamList &L) {
  dbgs().indent(4) << "Parameters: ";
  for (const SCEV *S : L)
    S->print(dbgs().indent(2));
  dbgs() << "\n";
}

// Remove all direct and indirect children of region R from the region set Regs,
// but do not recurse further if the first child has been found.
//
// Return the number of regions erased from Regs.
static unsigned eraseAllChildren(std::set<const Region *> &Regs,
                                 const Region &R) {
  unsigned Count = 0;
  for (auto &SubRegion : R) {
    if (Regs.find(SubRegion.get()) != Regs.end()) {
      ++Count;
      Regs.erase(SubRegion.get());
    } else {
      Count += eraseAllChildren(Regs, *SubRegion);
    }
  }
  return Count;
}

static void printValidScops(ScopSet &AllScops, ScopDetection const &SD) {
  dbgs().indent(2) << "SCoPs already valid: -\n";
  for (ScopDetection::const_iterator i = SD.begin(), ie = SD.end(); i != ie;
       ++i) {
    const Region *R = (*i);
    AllScops.insert(R);

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);
    DEBUG(dbgs().indent(4) << FileName << ":" << LineBegin << ":" << LineEnd
                           << " - " << R->getNameStr() << "\n");
  }
}

bool NonAffineScopDetection::runOnFunction(Function &F) {
  if (IgnoredFunctions.count(&F)) {
    DEBUG(dbgs() << "SD - Ignoring: " << F.getName() << "\n");
    return false;
  }

  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  RI = &getAnalysis<RegionInfo>();
  M = F.getParent();

  DEBUG(dbgs() << "[polli] Running on: " << F.getName() << "\n");
  DEBUG(printValidScops(AccumulatedScops, *SD));

  if (!Enabled)
    return false;

  for (ScopDetection::const_reject_iterator i = SD->reject_begin(),
                                            ie = SD->reject_end();
       i != ie; ++i) {
    const Region *R = (*i).first;
    RejectLog Log = (*i).second;

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);
    DEBUG(dbgs().indent(2) << "[Checking] " << FileName << ":" << LineBegin
                           << ":" << LineEnd << " - " << R->getNameStr()
                           << "\n");
    DEBUG(R->dump());

    bool isValid = Log.size() > 0;
    for (auto Reason : Log) {
      NonAffineLogChecker NonAffine(R, SE);
      AliasingLogChecker Aliasing(R);

      auto NonAffineResult =
          NonAffine.check(Reason.get(), std::make_pair<>(false, ParamList()));

      auto AliasResult = Aliasing.check(Reason.get(), false);

      // Ask the checkers for their oppinion.
      bool IsFixable = false;
      IsFixable |= NonAffineResult.first;
      IsFixable |= AliasResult;

      DEBUG(dbgs().indent(4) << ((IsFixable) ? "[ OK ]: " : "[FAIL]: ")
                             << Reason->getMessage() << "\n");
      isValid &= IsFixable;

      // Record all necessary parameters for later use.
      if (isValid) {
        ParamList params = NonAffineResult.second;
        RequiredParams[R]
            .insert(RequiredParams[R].end(), params.begin(), params.end());
      }
    }

    if (isValid) {
      /* The SCoP can be fixed at run time. However, we want need to make
       * sure to fetch the largest parent region that is fixable.
       * We need to do two steps:
       *
       * 1) Eliminate all children from the set of jitable Scops. */
      eraseAllChildren(JitableScops, *R);

      /* 2) Search for one of our parents (up to the function entry) in the
       *    list of jitable Scops. If we find one in there, do not enter
       *    the set of jitable Scops. */
      const Region *Parent = R->getParent();
      while (Parent && !JitableScops.count(Parent))
        Parent = Parent->getParent();

      // We found one of our parent regions in the set of jitable Scops.
      if (!Parent) {
        DEBUG(dbgs().indent(2) << "[NSD] " << R->getNameStr()
                               << "is jitable\n");
        DEBUG(printParameters(RequiredParams[R]));
        AccumulatedScops.insert(R);
        JitableScops.insert(R);
        ++JitScopsFound;
      } else
        DEBUG(dbgs().indent(4) << "Already covered: " << R->getNameStr()
                               << "\n");
    }
  }

  DEBUG(dbgs().indent(2) << "[NSD]: Number of jitable Scops "
                        << JitableScops.size() << "\n");
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

  // Do not clear the ignored functions.
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
