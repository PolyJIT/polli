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
#include "llvm/Support/Debug.h"

#include "polli/RuntimeOptimizer.h"
#include "polli/Utils.h"

#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"

#include "polly/ScopDetection.h"

#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/PassManagers.h"
#include "llvm/Analysis/CFGPrinter.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

namespace polli {
bool RuntimeOptimizer::Optimize(Function &F) {
  DEBUG(dbgs() << "[polli] Preparing " << F.getName() << " for launch!\n");
  Module *M = F.getParent();
  FunctionPassManager FPM = FunctionPassManager(M);

  FPM.add(new DataLayout(M));
  FPM.add(llvm::createTypeBasedAliasAnalysisPass());
  FPM.add(llvm::createBasicAliasAnalysisPass());

  polly::registerCanonicalicationPasses(FPM);

  FPM.add(polly::createScopInfoPass());
  FPM.add(polly::createDOTPrinterPass());

  //  FPM.add(polly::createDeadCodeElimPass());

  //  FPM.add(polly::createPoccPass());
  //  FPM.add(polly::createPlutoOptimizerPass());
  FPM.add(polly::createIslScheduleOptimizerPass());
  //  FPM.add(polly::createJSONExporterPass());

  FPM.add(polly::createCodeGenerationPass());
  //  VectorizeConfig C;
  //    C.FastDep = true;
  //  FPM.add(createBBVectorizePass(C));
  //  FPM.add(polly::createIslCodeGenerationPass());

  FPM.add(llvm::createCFGPrinterPass());
  FPM.doInitialization();
  bool result = FPM.run(F);
  FPM.doFinalization();

  //DEBUG(StoreModule(*M, M->getModuleIdentifier()));
  StoreModule(*M, M->getModuleIdentifier());
  return result;
}
}
