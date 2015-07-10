//===-- RegisterCompilationPasses.cpp - LLVM Just in Time Compiler --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Register the compilation sequence required for the PolyJIT runtime support.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include "polli/RegisterCompilationPasses.h"
#include "polli/InstrumentRegions.h"
#include "polli/ModuleExtractor.h"

#include "polly/Canonicalization.h"
#include "polly/RegisterPasses.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polli/Options.h"
#include "polli/JitScopDetection.h"
#include "polli/PapiProfiling.h"
#include "polli/ScopMapper.h"
#include "polli/ModuleExtractor.h"

#include "spdlog/spdlog.h"

using namespace llvm;
using namespace polli;
using namespace spdlog::details;

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

namespace polli {

void initializePolliPasses(PassRegistry &Registry) {
  initializePapiCScopProfilingPass(Registry);
  initializePapiCScopProfilingInitPass(Registry);
}

static void printConfig() {
  auto Console = spdlog::stderr_logger_st("polli");
  Console->info("PolyJIT - Config:");
  Console->info(" polyjit.jitable: {}", opt::EnableJitable);
  Console->info(" polyjit.recompile: {}", !opt::DisableRecompile);
  Console->info(" polyjit.execute: {}", !opt::DisableExecution);
  Console->info(" polyjit.instrument: {}", opt::InstrumentRegions);
  Console->info(" polly.delinearize: {}", polly::PollyDelinearize);
  Console->info(" polly.aliaschecks: {}", polly::PollyUseRuntimeAliasChecks);
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
    //FIXME: We preserve everything, but LLVM will kill all passes that are
    //       needed by the module extractor in our compilation pipeline.
    //AU.setPreservesAll();
  }
};

template <> char FunctionPassPrinter<JitScopDetection>::ID = 0;
template <> char FunctionPassPrinter<ModuleExtractor>::ID = 0;

static void registerPolyJIT(const llvm::PassManagerBuilder &,
                            llvm::legacy::PassManagerBase &PM) {
  if (!opt::Enabled)
    return;

  if (polly::PollyDelinearize && opt::EnableJitable)
    polly::PollyDelinearize = false;

  if (polly::PollyUseRuntimeAliasChecks && opt::EnableJitable)
    polly::PollyUseRuntimeAliasChecks = false;

  setupLogging();
  DEBUG(printConfig());

  registerPollyPasses(PM);

  // Schedule us inbetween detection and polly's codegen.
  PM.add(new JitScopDetection(opt::EnableJitable));
  if (opt::AnalyzeIR)
    PM.add(new FunctionPassPrinter<JitScopDetection>(outs()));

  if (opt::InstrumentRegions)
    PM.add(new PapiCScopProfiling());

  if (!opt::DisableRecompile) {
    PM.add(new ScopMapper());
    PM.add(new ModuleExtractor());
    if (opt::AnalyzeIR)
      PM.add(new FunctionPassPrinter<ModuleExtractor>(outs()));
  }
}

static llvm::RegisterStandardPasses
    RegisterPolyJIT(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                    registerPolyJIT);
} // namespace polli
