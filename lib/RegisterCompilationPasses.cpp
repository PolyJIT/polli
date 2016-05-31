//===-- RegisterCompilationPasses.cpp - LLVM Just in Time Compiler --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2015 Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
//
// Register the compilation sequence required for the PolyJIT runtime support.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include "polli/InstrumentRegions.h"
#include "polli/ModuleExtractor.h"
#include "polli/Options.h"
#include "polli/PapiProfiling.h"
#include "polli/RegisterCompilationPasses.h"
#include "polli/ScopDetection.h"

#include "polly/Canonicalization.h"
#include "polly/RegisterPasses.h"
#include "polly/CodeGen/CodegenCleanup.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"


#include "cppformat/format.h"

using namespace llvm;
using namespace polli;

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

namespace polli {

void initializePolliPasses(PassRegistry &Registry) {
  initializePapiCScopProfilingPass(Registry);
  initializePapiCScopProfilingInitPass(Registry);
  initializeJITScopDetectionPass(Registry);
}

static void printConfig() {
  errs() << fmt::format("PolyJIT - Config:\n");
  errs() << fmt::format(" polyjit.jitable: {}\n", opt::EnableJitable);
  errs() << fmt::format(" polyjit.recompile: {}\n", !opt::DisableRecompile);
  errs() << fmt::format(" polyjit.execute: {}\n", !opt::DisableExecution);
  errs() << fmt::format(" polyjit.instrument: {}\n", opt::InstrumentRegions);
  errs() << fmt::format(" polly.delinearize: {}\n", polly::PollyDelinearize);
  errs() << fmt::format(" polly.aliaschecks: {}\n",
                        polly::PollyUseRuntimeAliasChecks);
  errs() << fmt::format(" polyjit.collect-regression: {}\n",
                        opt::CollectRegressionTests);
}

/**
 * @brief Copy of opt's FunctionPassPrinter.
 *
 * We just fetch it here, for printing via polli-analyze (even from clang).
 */
template <class T> struct FunctionPassPrinter : public FunctionPass {
  std::string PassName;
  raw_ostream &Out;
  static char ID;
  T *P;

  FunctionPassPrinter(raw_ostream &out)
      : FunctionPass(ID), PassName("PolyJIT - FunctionPassPrinter"), Out(out) {}

  bool runOnFunction(Function &F) override {
    P = &getAnalysis<T>();

    Out << fmt::format("Printing analysis '{:s}' for function '{:s}':\n",
                       P->getPassName(), F.getName().str());
    P->print(Out, F.getParent());
    return true;
  }

  const char *getPassName() const override { return PassName.c_str(); }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<T>();
    // FIXME: We preserve everything, but LLVM will kill all passes that are
    //       needed by the module extractor in our compilation pipeline.
    // AU.setPreservesAll();
  }
};

template <> char FunctionPassPrinter<JITScopDetection>::ID = 0;
template <> char FunctionPassPrinter<ModuleExtractor>::ID = 0;

static void registerPolyJIT(const llvm::PassManagerBuilder &,
                            llvm::legacy::PassManagerBase &PM) {
  if (!opt::Enabled)
    return;

  DEBUG(printConfig());

  PM.add(polly::createCodePreparationPass());
  polly::registerCanonicalicationPasses(PM);
  PM.add(polli::createScopDetectionPass());

  if (opt::AnalyzeIR)
    PM.add(new FunctionPassPrinter<polli::JITScopDetection>(outs()));

  if (opt::InstrumentRegions) {
    PM.add(new PapiCScopProfiling());
    return;
  }

  if (!opt::DisableRecompile) {
    PM.add(new ModuleExtractor());
    if (opt::AnalyzeIR)
      PM.add(new FunctionPassPrinter<ModuleExtractor>(outs()));
  }
  PM.add(llvm::createBarrierNoopPass());
}

static llvm::RegisterStandardPasses
    RegisterPolyJIT(llvm::PassManagerBuilder::EP_VectorizerStart,
                    registerPolyJIT);
} // namespace polli
