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
#include "llvm/Analysis/Passes.h"
#include "llvm/IR/LegacyPassManager.h" // for FunctionPassManager
#include "llvm/IR/Module.h"            // for Module
#include "llvm/Pass.h"                 // for ImmutablePass
#include "llvm/Support/Debug.h"        // for DEBUG
#include "polli/RuntimeOptimizer.h"    // for RuntimeOptimizer
#include "polli/Utils.h"               // for StoreModule
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h" // for createIslCodeGenerationPass, etc

#include "llvm/Analysis/RegionInfo.h"

#include "llvm/PassManager.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/ScopDetection.h"

#include "pprof/pprof.h"
#include "pprof/tracing.h"

namespace llvm {
class Function;
}

using namespace llvm;
using namespace polly;

namespace polli {
Function *OptimizeForRuntime(Function *F) {
  Module *M = F->getParent();
  FunctionPassManager PM = FunctionPassManager(M);

  polly::ScopDetection *SD =
      (polly::ScopDetection *)polly::createScopDetectionPass();

  PM.add(new DataLayoutPass());
  PM.add(llvm::createTypeBasedAliasAnalysisPass());
  PM.add(llvm::createBasicAliasAnalysisPass());
  polly::registerCanonicalicationPasses(PM);
  PM.add(SD);
  PM.add(polly::createScopInfoPass());
  PM.add(polly::createIslScheduleOptimizerPass());
  PM.add(polly::createCodeGenerationPass());

  pprof_trace_entry("JIT-Opt");
  PM.run(*F);
  pprof_trace_exit("JIT-Opt");

  DEBUG(StoreModule(*M, M->getModuleIdentifier()));

  return F;
}
}
