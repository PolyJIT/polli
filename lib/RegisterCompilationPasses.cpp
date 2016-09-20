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
#include "polli/InstrumentRegions.h"
#include "polli/ModuleExtractor.h"
#include "polli/Options.h"
#include "polli/PapiProfiling.h"
#include "polli/RegisterCompilationPasses.h"
#include "polli/log.h"

#include "polly/Canonicalization.h"
#include "polly/RegisterPasses.h"
#include "polly/CodeGen/CodegenCleanup.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"

#define DEBUG_TYPE "polyjit"

using namespace llvm;
using namespace polli;

namespace polli {

void initializePolliPasses(PassRegistry &Registry) {
  initializePapiCScopProfilingPass(Registry);
  initializePapiCScopProfilingInitPass(Registry);
  initializeJITScopDetectionPass(Registry);
}

struct InjectMain : public FunctionPass {
  std::string PassName;
  static char ID;

  InjectMain()
      : FunctionPass(ID), PassName("PolyJIT - Main Injector") {}

  bool runOnFunction(Function &F) override {
    bool IsMain = F.getName() == "main";

    if (IsMain) {
      Module *M = F.getParent();
      LLVMContext &Ctx = M->getContext();
      IRBuilder<> Builder(Ctx);
      Function *PJMainFn = cast<Function>(M->getOrInsertFunction(
          "pjit_library_init", Type::getVoidTy(Ctx), NULL));
      BasicBlock &Entry = F.getEntryBlock();
      Builder.SetInsertPoint(Entry.getFirstNonPHI());
      Builder.CreateCall(PJMainFn);
    }

    return IsMain;
  }

  const char *getPassName() const override { return PassName.c_str(); }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }
};

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
char InjectMain::ID = 0;

static void registerPolyJIT(const llvm::PassManagerBuilder &,
                            llvm::legacy::PassManagerBase &PM) {
  if (!opt::Enabled)
    return;

  PM.add(polly::createCodePreparationPass());
  PM.add(polli::createScopDetectionPass());

  if (opt::AnalyzeIR)
    PM.add(new FunctionPassPrinter<polli::JITScopDetection>(outs()));

  if (opt::InstrumentRegions) {
    PM.add(new PapiCScopProfiling());
    return;
  }

  PM.add(new ModuleExtractor());
  if (opt::AnalyzeIR)
    PM.add(new FunctionPassPrinter<ModuleExtractor>(outs()));
  PM.add(new InjectMain());
}

static llvm::RegisterStandardPasses
    RegisterPolyJIT(llvm::PassManagerBuilder::EP_VectorizerStart,
                    registerPolyJIT);
} // namespace polli
