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
#include "polly/RegisterPasses.h"

#include "llvm/Transforms/IPO/PassManagerBuilder.h"

namespace {
class StaticInitializer {
public:
  StaticInitializer() {
    llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
    polly::initializePollyPasses(Registry);
    polli::initializePolliPasses(Registry);
  }
};
static StaticInitializer InitializeEverything;
} // end of anonymous namespace
