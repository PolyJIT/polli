//===-- JitScopDetection.cpp ---------------------------- -----------===//
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
#include <map>                             // for _Rb_tree_const_iterator, etc
#include <memory>                          // for unique_ptr
#include <set>                             // for set
#include <string>                          // for string
#include <utility>                         // for make_pair, pair
#include <vector>                          // for vector<>::iterator, vector
#include "llvm/ADT/Statistic.h"            // for STATISTIC, Statistic
#include "llvm/Analysis/RegionInfo.h"      // for Region, RegionInfo
#include "llvm/Analysis/RegionPass.h"      // for RGPassManager
#include "llvm/Analysis/ScalarEvolution.h" // for SCEV, ScalarEvolution
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Dominators.h" // for DominatorTreeWrapperPass
#include "llvm/InitializePasses.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/IR/LegacyPassManager.h"         // for FunctionPassManager
#include "llvm/PassAnalysisSupport.h" // for AnalysisUsage, etc
#include "llvm/PassSupport.h"         // for INITIALIZE_PASS_DEPENDENCY, etc
#include "llvm/Support/CommandLine.h" // for desc, opt
#include "llvm/Support/Debug.h"       // for dbgs, DEBUG
#include "llvm/Support/raw_ostream.h" // for raw_ostream
#include "polli/JitScopDetection.h"   // for ParamList, etc
#include "polly/ScopDetection.h"      // for ScopDetection, etc
#include "polly/ScopDetectionDiagnostic.h" // for ReportNonAffBranch, etc
#include "polly/Support/SCEVValidator.h"   // for getParamsInNonAffineExpr, etc

#include "polly/LinkAllPasses.h"
#include "polly/Canonicalization.h"

#include "polli/Utils.h"

#include "spdlog/spdlog.h"

namespace llvm {
class Function;
}
namespace llvm {
class Module;
}

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;
using namespace polli;

STATISTIC(JitScopsFound, "Number of jitable SCoPs");
STATISTIC(JitNonAffineLoopBound, "Number of fixable non affine loop bounds");
STATISTIC(JitNonAffineCondition, "Number of fixable non affine conditions");
STATISTIC(JitNonAffineAccess, "Number of fixable non affine accesses");
STATISTIC(AliasingIgnored, "Number of ignored aliasings");

static auto Console = spdlog::stderr_logger_st("polli");

template <typename LC, typename RetVal> class RejectLogChecker {
public:
  RetVal check(const RejectReason *Reason, const RetVal &Invalid = RetVal()) {
    LC *lc = (LC *)this;

    switch (Reason->getKind()) {
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
public:
  AliasingLogChecker(Function &, const Region *) {}

  bool checkNonAffineAccess(ReportNonAffineAccess *Reason) { return false; }
  bool checkNonAffineBranch(ReportNonAffBranch *Reason) { return false; }
  bool checkLoopBound(ReportLoopBound *Reason) { return false; }
  bool checkAlias(ReportAlias *Reason) {
    ++AliasingIgnored;
    return true;
  }
};

class NonAffineLogChecker
    : public RejectLogChecker<NonAffineLogChecker,
                              std::pair<bool, ParamList> > {
private:
  const Region *R;
  ScalarEvolution *SE;

public:
  NonAffineLogChecker(const Region *R, ScalarEvolution *SE) : R(R), SE(SE) {}

  std::pair<bool, ParamList>
  checkNonAffineAccess(ReportNonAffineAccess *Reason) {
    ParamList Params;
    if (!isNonAffineExpr(R, Reason->get(), *SE))
      return std::make_pair<>(false, Params);

    Params = polly::getParamsInNonAffineExpr(R, Reason->get(), *SE);
    ++JitNonAffineAccess;
    return std::make_pair<>(true, Params);
  }

  std::pair<bool, ParamList> checkNonAffineBranch(ReportNonAffBranch *Reason) {
    ParamList Params;

    // Check LHS & Add parameters
    if (!isNonAffineExpr(R, Reason->lhs(), *SE))
      return std::make_pair<>(false, Params);
    Params = getParamsInNonAffineExpr(R, Reason->lhs(), *SE);

    // Check RHS & Add parameters
    if (!isNonAffineExpr(R, Reason->rhs(), *SE))
      return std::make_pair<>(false, Params);
    ParamList RHSParams;
    RHSParams = getParamsInNonAffineExpr(R, Reason->rhs(), *SE);
    Params.insert(Params.end(), RHSParams.begin(), RHSParams.end());

    ++JitNonAffineCondition;
    return std::make_pair<>(true, Params);
  }

  std::pair<bool, ParamList> checkLoopBound(ReportLoopBound *Reason) {
    ParamList Params;
    bool isValid = polly::isNonAffineExpr(R, Reason->loopCount(), *SE);
    if (isValid) {
      Params = getParamsInNonAffineExpr(R, Reason->loopCount(), *SE);
      ++JitNonAffineLoopBound;
    }
    return std::make_pair<>(isValid, Params);
  }

  std::pair<bool, ParamList> checkAlias(ReportAlias *Reason) {
    ParamList Params;
    return std::make_pair<>(false, Params);
  }
};

void JitScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScalarEvolution>();
  AU.setPreservesAll();
}

static void printParameters(ParamList &L) {
  std::string ParamStr = "";
  llvm::raw_string_ostream OS(ParamStr);
  for (const SCEV *S : L) {
    OS << "[";
    S->print(OS);
    OS << "]";
  }
  Console->info("required @ run time: {:>30}", ParamStr);
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

#ifndef NDEBUG
#include <sstream>
static void printValidScops(ScopSet &AllScops, ScopDetection const &SD) {
  std::stringstream Messages;
  int ValidScopCount = 0;
  for (ScopDetection::const_iterator i = SD.begin(), ie = SD.end(); i != ie;
       ++i, ++ValidScopCount) {
    const Region *R = (*i);
    AllScops.insert(R);

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);
    Messages << "    " << FileName << ":" << LineBegin << ":" << LineEnd
             << " - " << R->getNameStr() << "\n";
  }

  if (ValidScopCount > 0) {
    Console->debug() << "  valid scops ::";
    Console->debug() << Messages.str();
  }
}
#endif

bool JitScopDetection::runOnFunction(Function &F) {
  if (F.isDeclaration())
    return false;

  if (IgnoredFunctions.count(&F))
    return false;

  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  M = F.getParent();

  Console->info("jit-scops :: {:>30}", F.getName().str());
  DEBUG(printValidScops(AccumulatedScops, *SD));

  if (!Enabled)
    return false;

  for (ScopDetection::const_reject_iterator i = SD->reject_begin(),
                                            ie = SD->reject_end();
       i != ie; ++i) {
    const Region *R = (*i).first;
    RejectLog Log = (*i).second;

    bool isValid = Log.size() > 0;
    for (auto Reason : Log) {
      NonAffineLogChecker NonAffine(R, SE);
      AliasingLogChecker Aliasing(F, R);

      auto NonAffineResult =
          NonAffine.check(Reason.get(), std::make_pair<>(false, ParamList()));

      auto AliasResult = Aliasing.check(Reason.get(), false);

      // Ask the checkers for their oppinion.
      bool IsFixable = false;
      IsFixable |= NonAffineResult.first;
      IsFixable |= AliasResult;

      Console->info() << ((IsFixable) ? "OK :: " : "FAIL :: ")
                      << Reason->getMessage();
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
        Console->info() << "jit-scops :: " << F.getName().str()
                        << "::" << R->getNameStr();
        printParameters(RequiredParams[R]);

        AccumulatedScops.insert(R);
        JitableScops.insert(R);
        ++JitScopsFound;
      }
    }
  }

  return false;
}

void JitScopDetection::print(raw_ostream &OS, const Module *) const {
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

void JitScopDetection::releaseMemory() {
  JitableScops.clear();
  AccumulatedScops.clear();
  RequiredParams.clear();

  // Do not clear the ignored functions.
}

char JitScopDetection::ID = 0;

static RegisterPass<JitScopDetection>
    X("polli-detect", "PolyJIT - Detect SCoPs that require runtime support.",
      false, false);
