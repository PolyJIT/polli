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
#include "llvm/IR/LegacyPassManager.h"  // for FunctionPassManager
#include "llvm/IR/Module.h"             // for Module
#include "llvm/Pass.h"                  // for ImmutablePass
#include "llvm/Support/Debug.h"         // for DEBUG
#include "polli/RuntimeOptimizer.h"     // for RuntimeOptimizer
#include "polli/Utils.h"                // for StoreModule
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"        // for createIslCodeGenerationPass, etc
namespace llvm { class Function; }

using namespace llvm;

namespace polli {
bool RuntimeOptimizer::Optimize(Function &F) {
  DEBUG(dbgs() << "[polli] Preparing " << F.getName() << " for launch!\n");
  Module *M = F.getParent();
  FunctionPassManager FPM = FunctionPassManager(M);

  FPM.add(new DataLayoutPass(M));
  FPM.add(llvm::createTypeBasedAliasAnalysisPass());
  FPM.add(llvm::createBasicAliasAnalysisPass());

  polly::registerCanonicalicationPasses(FPM);

  FPM.add(polly::createScopInfoPass());
  FPM.add(polly::createIslScheduleOptimizerPass());
  FPM.add(polly::createIslCodeGenerationPass());
  //  VectorizeConfig C;
  //    C.FastDep = true;
  //  FPM.add(createBBVectorizePass(C));
  //  FPM.add(polly::createIslCodeGenerationPass());

  bool result = FPM.run(F);

  DEBUG(StoreModule(*M, M->getModuleIdentifier()));
  return result;
}
}
