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
#include "polli/RegisterCompilationPasses.h"
#include "polli/InstrumentRegions.h"
#include "polli/ModuleExtractor.h"
#include "polli/Options.h"
#include "polli/PapiProfiling.h"
#include "polli/ProfileScops.h"
#include "polli/log.h"

#include "polly/Canonicalization.h"
#include "polly/CodeGen/CodegenCleanup.h"
#include "polly/RegisterPasses.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"

#define DEBUG_TYPE "polyjit"

using namespace llvm;
using namespace polli;

namespace {
REGISTER_LOG(console, "register");
}

namespace polli {

void initializePolliPasses(PassRegistry &Registry) {
  initializePapiCScopProfilingPass(Registry);
  initializePapiCScopProfilingInitPass(Registry);
  initializeJITScopDetectionPass(Registry);
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
                       P->getPassName().str(), F.getName().str());
    P->print(Out, F.getParent());
    return true;
  }

  StringRef getPassName() const override { return PassName.c_str(); }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<T>();
    AU.setPreservesAll();
  }
};

template <> char FunctionPassPrinter<JITScopDetection>::ID = 0;
template <> char FunctionPassPrinter<ModuleExtractor>::ID = 0;

static void registerProfileScops(const PassManagerBuilder &,
                                 llvm::legacy::PassManagerBase &PM) {
  if (opt::compiletime::ProfileScops) {
    polly::registerCanonicalicationPasses(PM);
    PM.add(polly::createScopDetectionWrapperPassPass());
    PM.add(polli::createProfileScopsPass());
  }
}

static void registerPolyJIT(const llvm::PassManagerBuilder &,
                            llvm::legacy::PassManagerBase &PM) {
  if (!opt::compiletime::Enabled)
    return;

  polly::registerCanonicalicationPasses(PM);
  PM.add(polly::createCodePreparationPass());
  PM.add(polli::createScopDetectionPass());

  if (opt::compiletime::AnalyzeIR)
    PM.add(new FunctionPassPrinter<polli::JITScopDetection>(outs()));

  if (opt::compiletime::InstrumentRegions) {
    PM.add(new PapiCScopProfiling());
    return;
  }

  PM.add(new ModuleExtractor());
  PM.add(new ModuleInstrumentation());
  if (opt::compiletime::AnalyzeIR)
    PM.add(new FunctionPassPrinter<ModuleExtractor>(outs()));
}

static llvm::RegisterStandardPasses
    RegisterPolyJIT(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                    registerPolyJIT);
static llvm::RegisterStandardPasses
    RegisterProfileScops(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                         registerProfileScops);
} // namespace polli
