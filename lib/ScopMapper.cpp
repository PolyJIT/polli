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

#include "polli/ScopMapper.h"
#include "polli/Utils.h"

#include "polli/NonAffineScopDetection.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/Dominators.h"
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
  AU.addRequired<DominatorTree>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
};

bool ScopMapper::runOnFunction(Function &F) {
  DominatorTree *DT  = &getAnalysis<DominatorTree>();
  NonAffineScopDetection *NSD = &getAnalysis<NonAffineScopDetection>();

  if (CreatedFunctions.count(&F))
    return false;

  /* Extract each SCoP in this function into a new one. */
  CodeExtractor *Extractor;
  int i=0;
  for (NonAffineScopDetection::iterator RP = NSD->begin(), RE = NSD->end();
       RP != RE; ++RP) {
    const Region *R = RP->first;

    Extractor = new CodeExtractor(*DT, *R);
    Function *ExtractedF = Extractor->extractCodeRegion();

    if (ExtractedF) {
      ExtractedF->setLinkage(GlobalValue::ExternalLinkage);
      ExtractedF->setName(ExtractedF->getName() + ".scop" + Twine(i++));
      /* FIXME: Do not depend on this set. */
      CreatedFunctions.insert(ExtractedF);
    }
    delete Extractor;
  }

  return true;
};

char ScopMapper::ID = 0;
