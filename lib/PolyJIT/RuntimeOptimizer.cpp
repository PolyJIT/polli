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
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/ScopDetection.h"

#include "spdlog/spdlog.h"

namespace {
auto Console = spdlog::stderr_logger_st("polli");
}

namespace llvm {
class Function;
}

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;

namespace polli {

Function &OptimizeForRuntime(Function &F) {
  Module *M = F.getParent();
  Console->debug("optimizing {:>s}", F.getName().str());
  PassManagerBuilder Builder;

  FunctionPassManager PM = FunctionPassManager(M);

  Builder.VerifyInput = true;
  Builder.VerifyOutput = true;
  Builder.OptLevel = 0;

  Builder.populateFunctionPassManager(PM);
  PM.run(F);

  Console->debug("optimization complete");
  DEBUG(StoreModule(*M, M->getModuleIdentifier()));
  return F;
}
}
