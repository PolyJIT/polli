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
#define DEBUG_TYPE "polyjit"
#include <set>                          // for _Rb_tree_const_iterator, etc
#include <string>                       // for string
#include "llvm/Analysis/RegionInfo.h"   // for Region, RegionInfo
#include "llvm/IR/Dominators.h"         // for DominatorTreeWrapperPass, etc
#include "llvm/PassAnalysisSupport.h"   // for AnalysisUsage, etc
#include "llvm/Support/Debug.h"         // for dbgs, DEBUG
#include "llvm/Support/raw_ostream.h"   // for raw_ostream
#include "llvm/Transforms/Utils/CodeExtractor.h"  // for CodeExtractor
#include "polli/NonAffineScopDetection.h"  // for NonAffineScopDetection, etc
#include "polli/ScopMapper.h"           // for ScopMapper, etc
#include "polly/ScopDetectionDiagnostic.h"  // for getDebugLocation
namespace llvm { class Function; }

using namespace llvm;
using namespace polli;
using namespace polly;

void ScopMapper::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<NonAffineScopDetection>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
}

bool ScopMapper::runOnFunction(Function &F) {
  NonAffineScopDetection *NSD = &getAnalysis<NonAffineScopDetection>();
  DominatorTree *DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();

  // Ignore functions created by us.
  if (CreatedFunctions.count(&F))
    return false;

  /* Extract each SCoP in this function into a new one. */
  int i = 0;
  for (ScopSet::iterator RP = NSD->jit_begin(), RE = NSD->jit_end(); RP != RE;
       ++RP) {
    const Region *R = *RP;

    CodeExtractor Extractor(*DT, (*R));

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);

    DEBUG(dbgs().indent(2) << "[ScopMapper] Extracting: ");
    DEBUG(dbgs().indent(2) << FileName << ":" << LineBegin << ":" << LineEnd
                           << " - " << R->getNameStr() << "\n");

    if (Extractor.isEligible()) {
      Function *ExtractedF = Extractor.extractCodeRegion();
      DEBUG(dbgs().indent(4) << " into: " << ExtractedF->getName() << "\n");

      if (ExtractedF) {
        ExtractedF->setLinkage(GlobalValue::ExternalLinkage);
        ExtractedF->setName(ExtractedF->getName() + ".scop" + Twine(i++));
        /* FIXME: Do not depend on this set. */
        CreatedFunctions.insert(ExtractedF);
        NSD->ignoreFunction(ExtractedF);
      }
    } else
      DEBUG(dbgs().indent(4) << " FAILED\n");
  }

  return true;
}

char ScopMapper::ID = 0;
