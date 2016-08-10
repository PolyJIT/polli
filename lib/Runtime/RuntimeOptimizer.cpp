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
#include "polli/BasePointers.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/LegacyPassManager.h"

#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"
#include "polly/ScopDetection.h"
#include "polly/Options.h"

namespace llvm {
class Function;
} // namespace llvm

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;

namespace polli {
static void registerPolly(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  PM.add(polly::createScopDetectionPass());
  PM.add(polly::createScopInfoRegionPassPass());
  PM.add(polly::createIslScheduleOptimizerPass());
  PM.add(polly::createCodeGenerationPass());
  // FIXME: This dummy ModulePass keeps some programs from miscompiling,
  // probably some not correctly preserved analyses. It acts as a barrier to
  // force all analysis results to be recomputed.
  PM.add(createBarrierNoopPass());
}

static PassManagerBuilder createPMB() {
  PassManagerBuilder Builder;

  Builder.VerifyInput = false;
  Builder.VerifyOutput = false;
  Builder.OptLevel = 3;
  polly::opt::PollyParallel = true;
  // We accept them blindly.
  polly::ProfitabilityMinPerLoopInstructions = 0;

  Builder.addGlobalExtension(PassManagerBuilder::EP_VectorizerStart,
                             registerPolly);

  return Builder;
}

std::unique_ptr<Module> OptimizeForRuntime(std::unique_ptr<Module> M) {
  return M;
}

Function &OptimizeForRuntime(Function &F) {
  static PassManagerBuilder Builder = createPMB();
  Module *M = F.getParent();
#ifdef POLLI_STORE_OUTPUT
  opt::GenerateOutput = true;
#endif

  legacy::FunctionPassManager PM = legacy::FunctionPassManager(M);

  Builder.populateFunctionPassManager(PM);
#ifdef POLLI_ENABLE_BASE_POINTERS
  PM.add(polli::createBasePointersPass());
#endif
  PM.doInitialization();
  PM.run(F);
  PM.doFinalization();

#ifdef POLLI_ENABLE_PAPI
  if (opt::havePapi()) {
    legacy::PassManager MPM;
    Builder.populateModulePassManager(MPM);
    MPM.add(polli::createTraceMarkerPass());
    MPM.run(*M);
  }
#endif

#ifdef POLLI_ENABLE_LIKWID
  if (opt::haveLikwid()) {
    legacy::PassManager MPM;
    Builder.populateModulePassManager(MPM);
    MPM.add(polli::createLikwidMarkerPass());
    MPM.run(*M);
  }
#endif

#ifdef POLLI_STORE_OUTPUT
  DEBUG(StoreModule(*M, M->getModuleIdentifier() + ".after.polly.ll"));
  opt::GenerateOutput = false;
#endif

  return F;
}
} // namespace polli
