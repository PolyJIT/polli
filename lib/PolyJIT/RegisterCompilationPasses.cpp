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

#include "polly/RegisterPasses.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
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

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

namespace {
auto Console = spdlog::stderr_logger_st("polli");
}

namespace polli {

void initializePolliPasses(PassRegistry &Registry) {
  initializePapiRegionPreparePass(Registry);
  initializePapiCScopProfilingPass(Registry);
  initializePapiCScopProfilingInitPass(Registry);
}

static void printConfig() {
  Console->info("PolyJIT - Config:");
  Console->info(" polyjit.jitable: {}", opt::EnableJitable);
  Console->info(" polyjit.recompile: {}", !opt::DisableRecompile);
  Console->info(" polyjit.execute: {}", !opt::DisableExecution);
  Console->info(" polyjit.instrument: {}", opt::InstrumentRegions);
}

void registerPolliPasses(llvm::legacy::PassManagerBase &PM) {
  if (polly::PollyDelinearize && opt::EnableJitable)
    polly::PollyDelinearize = false;

  if (opt::InstrumentRegions)
    PM.add(new PapiCScopProfilingInit());

  PM.add(new JitScopDetection(opt::EnableJitable));

  if (opt::InstrumentRegions)
    PM.add(new PapiCScopProfiling());
}

static void setupLogging() {
  spdlog::set_async_mode(1048576);
  spdlog::set_pattern("%v");
  spdlog::set_level(spdlog::level::warn);
}

static void registerPolli(const llvm::PassManagerBuilder &,
                          llvm::legacy::PassManagerBase &PM) {
  if (!opt::Enabled)
    return;

  setupLogging();
  printConfig();
  registerPollyPasses(PM);
  registerPolliPasses(PM);
}

/**
 * @brief Copy of opt's FunctionPassPrinter.
 *
 * We just fetch it here, for printing via polli-analyze (even from clang).
 */
struct FunctionPassPrinter : public FunctionPass {
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  static char ID;
  std::string PassName;
  bool QuietPass;

  FunctionPassPrinter(const PassInfo *PI, raw_ostream &out, bool Quiet)
      : FunctionPass(ID), PassToPrint(PI), Out(out), QuietPass(Quiet) {
    std::string PassToPrintName = PassToPrint->getPassName();
    PassName = "FunctionPass Printer: " + PassToPrintName;
  }

  bool runOnFunction(Function &F) override {
    if (!QuietPass)
      Out << "Printing analysis '" << PassToPrint->getPassName()
          << "' for function '" << F.getName() << "':\n";

    // Get and print pass...
    getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out, F.getParent());
    return false;
  }

  const char *getPassName() const override { return PassName.c_str(); }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char FunctionPassPrinter::ID = 0;

static void registerModuleExtractor(const llvm::PassManagerBuilder &,
                                    llvm::legacy::PassManagerBase &PM) {
  if (!opt::Enabled)
    return;

  if (polly::PollyDelinearize && opt::EnableJitable)
    polly::PollyDelinearize = false;

  if (!opt::DisableRecompile)
    PM.add(new ModuleExtractor());
}

static llvm::RegisterStandardPasses
    RegisterPolliInstrumentation(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                                 registerPolli);
static llvm::RegisterStandardPasses
    RegisterPolliModuleExtraction(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                                  registerModuleExtractor);
}
