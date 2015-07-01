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
#include "llvm/IR/LegacyPassManager.h" // for FunctionPassManager
#include "llvm/PassAnalysisSupport.h"  // for AnalysisUsage, etc
#include "llvm/PassSupport.h"          // for INITIALIZE_PASS_DEPENDENCY, etc
#include "llvm/Support/CommandLine.h"  // for desc, opt
#include "llvm/Support/Debug.h"        // for dbgs, DEBUG
#include "llvm/Support/raw_ostream.h"  // for raw_ostream
#include "polli/JitScopDetection.h"    // for ParamList, etc
#include "polly/ScopDetection.h"       // for ScopDetection, etc
#include "polly/ScopDetectionDiagnostic.h" // for ReportNonAffBranch, etc
#include "polly/Support/SCEVValidator.h"   // for getParamsInNonAffineExpr, etc

#include "polly/LinkAllPasses.h"
#include "polly/Canonicalization.h"
#include "polli/ScopDetectionCheckers.h"
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
using namespace spdlog::details;

STATISTIC(JitScopsFound, "Number of jitable SCoPs");

static auto Console = spdlog::stderr_logger_st("polli/jitsd");

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
  Console->info("required @ run time: {:>30}", OS.str());
}

// Remove all direct and indirect children of region R from the region set Regs,
// but do not recurse further if the first child has been found.
//
// Return the number of regions erased from Regs.
static unsigned eraseAllChildren(ScopSet &Regs, const Region &R) {
  unsigned Count = 0;
  for (auto &SubRegion : R) {
    if (Regs.count(SubRegion.get())) {
      ++Count;
      Regs.remove(SubRegion.get());
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

    std::string FileName;
  }

  if (ValidScopCount > 0) {
    Console->debug() << "  valid scops ::";
    Console->debug() << Messages.str();
  }
}
#endif

bool JitScopDetection::runOnFunction(Function &F) {
  if (!Enabled)
    return false;

  if (F.isDeclaration())
    return false;

  if (F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  SD = &getAnalysis<ScopDetection>();
  SE = &getAnalysis<ScalarEvolution>();
  M = F.getParent();

  DEBUG(printValidScops(AccumulatedScops, *SD));
  Console->info("== Detect JIT SCoPs in function: {:>30}", F.getName().str());
  for (ScopDetection::const_reject_iterator Rej = SD->reject_begin(),
                                            RejE = SD->reject_end();
       Rej != RejE; ++Rej) {
    const Region *R = (*Rej).first;

    if (!R)
      continue;
    Console->info("==== Next Region: {:>60s}", R->getNameStr());
    R->dump();

    RejectLog Log = (*Rej).second;

    NonAffineAccessChecker NonAffAccessChk(R, SE);
    NonAffineBranchChecker NonAffBranchChk(R, SE);
    NonAffineLoopBoundChecker LoopBoundChk(R, SE);
    AliasingChecker AliasChk;

    ParamList Params;
    bool RegionIsValid = Log.size() > 0;

    for (auto &Reason : Log) {
      bool IsFixable = false;
      IsFixable |= isValid(NonAffAccessChk, *Reason);
      IsFixable |= isValid(NonAffBranchChk, *Reason);
      IsFixable |= isValid(LoopBoundChk, *Reason);
      IsFixable |= isValid(AliasChk, *Reason);

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
        printParameters(L);
        Console->info("     Accepting SCoP: {}", R->getNameStr());
        AccumulatedScops.insert(R);
        JitableScops.insert(R);
        ++JitScopsFound;
      }
    }
  }

  return false;
}

void JitScopDetection::print(raw_ostream &OS, const Module *) const {
  using reject_iterator = std::map<const Region *, RejectLog>::const_iterator;
  using reject_range = iterator_range<reject_iterator>;

  unsigned count = JitableScops.size();
  unsigned i = 0;

  OS << fmt::format("{:d} regions require runtime support:\n", count);
  for (const Region *R : JitableScops) {
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

  // Do not clear the ignored functions.
}

char JitScopDetection::ID = 0;

static RegisterPass<JitScopDetection>
    X("polli-detect", "PolyJIT - Detect SCoPs that require runtime support.",
      false, false);
