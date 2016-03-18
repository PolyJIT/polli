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
#include "polli/ScopDetection.h"
#include "polli/ScopMapper.h"
#include "polli/Utils.h"
#include "polly/ScopDetectionDiagnostic.h"

#include "llvm/Analysis/RegionInfo.h" // for Region, RegionInfo
#include "llvm/IR/Dominators.h"       // for DominatorTreeWrapperPass, etc
#include "llvm/PassAnalysisSupport.h" // for AnalysisUsage, etc
#include "llvm/Support/Debug.h"       // for dbgs, DEBUG
#include "llvm/Support/raw_ostream.h" // for raw_ostream
#include "llvm/Transforms/Utils/CodeExtractor.h" // for CodeExtractor

#include "cppformat/format.h"
#include <set>
#include <string>

using namespace llvm;
using namespace polli;

void ScopMapper::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<polli::JITScopDetection>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.setPreservesAll();
}

bool ScopMapper::runOnFunction(Function &F) {
  JSD = &getAnalysis<polli::JITScopDetection>();
  DTP = &getAnalysis<DominatorTreeWrapperPass>();

  DominatorTree &DT = DTP->getDomTree();

  // We already processed these.
  if (F.hasFnAttribute(Attribute::OptimizeNone) ||
      F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  /* Extract each SCoP in this function into a new one. */
  for (auto &R : *JSD) {
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
