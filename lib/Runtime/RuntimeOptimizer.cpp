//===-- RuntimeOptimizer.h - JIT function optimizer -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines a small interface to determine the benefits of optimizing
// a given function at run time. If the benefit exceeds a threshold the
// optimization should be executed, e.g. with Polly.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include "polli/RuntimeOptimizer.h"
#include "polli/Utils.h"
#include "polli/LikwidMarker.h"
#include "polli/Options.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Debug.h"

#include "llvm/Pass.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassRegistry.h"
#include "llvm/PassSupport.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polly/RegisterPasses.h"
#include "polly/Options.h"

#include <unistd.h>

namespace llvm {
class Function;
} // namespace llvm

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;

namespace polli {
static void registerPolly(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  polly::registerPollyPasses(PM);
}

#ifdef DEBUG
static PassManagerBuilder getDebugBuilder() {
  PassManagerBuilder Builder;

  Builder.VerifyInput = true;
  Builder.VerifyOutput = true;
  Builder.OptLevel = 0;
  Builder.DisableUnrollLoops = true;
  Builder.DisableTailCalls = true;
  Builder.addGlobalExtension(PassManagerBuilder::EP_EarlyAsPossible,
                             registerPolly);

  return Builder;
}
#else
static PassManagerBuilder getBuilder() {
  PassManagerBuilder Builder;

  Builder.VerifyInput = false;
  Builder.VerifyOutput = false;
  Builder.OptLevel = 3;
  Builder.addGlobalExtension(PassManagerBuilder::EP_EarlyAsPossible,
                             registerPolly);

  return Builder;
}
#endif

Function &OptimizeForRuntime(Function &F) {
#ifdef DEBUG
  static PassManagerBuilder Builder = getDebugBuilder();
#else
  static PassManagerBuilder Builder = getBuilder();
#endif
  Module *M = F.getParent();
  opt::GenerateOutput = true;
  polly::opt::PollyParallel = true;

  FunctionPassManager PM = FunctionPassManager(M);

  Builder.populateFunctionPassManager(PM);
  PM.doInitialization();
  PM.run(F);
  PM.doFinalization();

  if (opt::havePapi()) {
    PassManager MPM;
    Builder.populateModulePassManager(MPM);
    MPM.add(polli::createTraceMarkerPass());
    MPM.run(*M);
  }

  if (opt::haveLikwid()) {
    PassManager MPM;
    Builder.populateModulePassManager(MPM);
    MPM.add(polli::createLikwidMarkerPass());
    MPM.run(*M);
  }

  DEBUG(
  StoreModule(*M, M->getModuleIdentifier() + ".after.polly.ll")
  );
  opt::GenerateOutput = false;

  return F;
}
} // namespace polli
