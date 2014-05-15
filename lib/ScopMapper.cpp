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
#include "llvm/Support/Debug.h"

#include "polly/ScopDetectionDiagnostic.h"

#include "polli/ScopMapper.h"
#include "polli/Utils.h"

#include "polli/NonAffineScopDetection.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/Module.h"

#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <set>

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

  if (CreatedFunctions.count(&F)) {
    DEBUG(dbgs() << "SM - Ignoring: " << F.getName() << "\n");
    return false;
  }

  /* Extract each SCoP in this function into a new one. */
  int i = 0;
  for (NonAffineScopDetection::iterator RP = NSD->begin(), RE = NSD->end();
       RP != RE; ++RP) {
    const Region *R = RP->first;

    CodeExtractor Extractor(*DT, (*R));

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);
 
    DEBUG(dbgs().indent(2) << "[ScopMapper] Extracting: ");
    DEBUG(dbgs().indent(2) << FileName << ":"
                           << LineBegin << ":" << LineEnd
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
;

char ScopMapper::ID = 0;
