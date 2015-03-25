//===---------- PolyJIT.cpp - Initialize the PolyJIT Module ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

#include "polli/RegisterCompilationPasses.h"
#include "polli/PapiProfiling.h"
#include "polli/InstrumentRegions.h"
#include "polly/RegisterPasses.h"

#include "llvm/Transforms/IPO/PassManagerBuilder.h"

namespace {
class StaticInitializer {
public:
  StaticInitializer() {
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    initializePollyPasses(Registry);
    initializePapiRegionPreparePass(Registry);
    initializePapiCScopProfilingPass(Registry);
    initializePapiCScopProfilingInitPass(Registry);
  }
};
static StaticInitializer InitializeEverything;
} // end of anonymous namespace
