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
#include "spdlog/spdlog.h"

namespace llvm {
class Function;
}

namespace {
auto Console = spdlog::stderr_logger_st("polli");
}

using namespace llvm;
using namespace polli;
using namespace polly;

void ScopMapper::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<JitScopDetection>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<RegionInfoPass>();
  AU.setPreservesAll();
}

bool ScopMapper::runOnFunction(Function &F) {
  JitScopDetection &NSD = getAnalysis<JitScopDetection>();
  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();

  if(F.hasFnAttribute(Attribute::OptimizeNone))
    return false;

  // That would recurse forever.
  if(F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  /* Extract each SCoP in this function into a new one. */
  int i = 0;
  for (ScopSet::iterator RP = NSD.jit_begin(), RE = NSD.jit_end(); RP != RE;
       ++RP) {
    const Region *R = *RP;

    CodeExtractor Extractor(DT, *(R->getNode()));

    unsigned LineBegin, LineEnd;
    std::string FileName;
    getDebugLocation(R, LineBegin, LineEnd, FileName);

    DEBUG(Console->debug("mapper :: extract :: {0}:{1}:{2} - {3}", FileName,
                         LineBegin, LineEnd, R->getNameStr()););

    if (Extractor.isEligible()) {
      Function *ExtractedF = Extractor.extractCodeRegion();
      DEBUG(log(Debug, 2) << " into: " << ExtractedF->getName() << "\n");

      if (ExtractedF) {
        ExtractedF->setLinkage(GlobalValue::ExternalLinkage);
        ExtractedF->setName(ExtractedF->getName() + ".scop" + Twine(i++));
        ExtractedF->addFnAttr("polyjit-jit-candidate");
        CreatedFunctions.insert(ExtractedF);
      }
    } else {
      log(Error, 2) << " failed :: Scop " << R->getNameStr()
                    << " not eligible for extraction\n";
    }
  }

  return true;
}

char ScopMapper::ID = 0;
static RegisterPass<ScopMapper>
    X("polli-map-scops", "PolyJIT - Extract SCoPs into their own function");
