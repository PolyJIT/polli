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
#include "polli/Options.h"
#include "polli/LikwidMarker.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/Debug.h"

#include "llvm/Pass.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassRegistry.h"
#include "llvm/PassSupport.h"

#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polly/RegisterPasses.h"
#include "polly/Options.h"

#include "spdlog/spdlog.h"

namespace {
auto Console = spdlog::stderr_logger_st("polli/optimizer");
}

namespace llvm {
class Function;
}

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;

namespace polli {
static void registerPolly(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  polly::registerPollyPasses(PM);
}

Function &OptimizeForRuntime(Function &F) {
  Module *M = F.getParent();
  PassManagerBuilder Builder;
  opt::GenerateOutput = true;
  polly::opt::PollyParallel = true;

  PassManager MPM;
  FunctionPassManager PM = FunctionPassManager(M);

  Builder.VerifyInput = true;
  Builder.VerifyOutput = true;
  Builder.OptLevel = 3;
  Builder.addGlobalExtension(PassManagerBuilder::EP_EarlyAsPossible,
                             registerPolly);
  Builder.populateFunctionPassManager(PM);
  Builder.populateModulePassManager(MPM);
  PM.doInitialization();
  PM.run(F);
  PM.doFinalization();

  MPM.add(polli::createLikwidMarkerPass());
  MPM.run(*M);
    Console->warn("\t LikwidMarker support active.");
    Console->warn("\t LikwidMarker support NOT active.");

  StoreModule(*M, M->getModuleIdentifier() + ".after.polly.ll");
  opt::GenerateOutput = false;

  return F;
}
}
