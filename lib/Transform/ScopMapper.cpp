//===-- ScopMapper.cpp - LLVM Just in Time Compiler -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The SCoPMapper extracts SCoPs into a separate function in a new module.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "pjit-mapper"
#include <set>                        // for _Rb_tree_const_iterator, etc
#include <string>                     // for string
#include "llvm/Analysis/RegionInfo.h" // for Region, RegionInfo
#include "llvm/IR/Dominators.h"       // for DominatorTreeWrapperPass, etc
#include "llvm/PassAnalysisSupport.h" // for AnalysisUsage, etc
#include "llvm/Support/Debug.h"       // for dbgs, DEBUG
#include "llvm/Support/raw_ostream.h" // for raw_ostream
#include "llvm/Transforms/Utils/CodeExtractor.h" // for CodeExtractor
#include "polli/JitScopDetection.h"              // for JitScopDetection, etc
#include "polli/ScopMapper.h"                    // for ScopMapper, etc
#include "polly/ScopDetectionDiagnostic.h"       // for getDebugLocation

#include "polli/Utils.h"

#define FMT_HEADER_ONLY
#include "cppformat/format.h"

namespace llvm {
class Function;
} // namespace llvm

using namespace llvm;
using namespace polli;
using namespace polly;

void ScopMapper::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<JitScopDetection>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.setPreservesAll();
}

bool ScopMapper::runOnFunction(Function &F) {
  JSD = &getAnalysis<JitScopDetection>();
  DTP = &getAnalysis<DominatorTreeWrapperPass>();

  DominatorTree &DT = DTP->getDomTree();

  // We already processed these.
  if (F.hasFnAttribute(Attribute::OptimizeNone) ||
      F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  /* Extract each SCoP in this function into a new one. */
  for (const Region *R : JSD->allScops()) {
    CodeExtractor Extractor(DT, *(R->getNode()), /*AggregateArgs*/ false);

    if (Extractor.isEligible()) {
      MappableRegions.insert(R);
    } else {
      errs() << fmt::format("{} not eligible", R->getNameStr());
    }
  }

  return false;
}

char ScopMapper::ID = 0;
static RegisterPass<ScopMapper>
    X("polli-map-scops", "PolyJIT - Mark SCoPs for runtime extraction");
