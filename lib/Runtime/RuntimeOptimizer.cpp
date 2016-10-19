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
#include "polli/BasePointers.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/LegacyPassManager.h"

#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"
#include "polly/ScopDetection.h"
#include "polly/ScopInfo.h"
#include "polly/ScopPass.h"
#include "polly/CodeGen/IslAst.h"
#include "polly/ScheduleOptimizer.h"
#include "polly/CodeGen/CodegenCleanup.h"
#include "polly/CodeGen/CodeGeneration.h"
#include "polly/Options.h"
#include "polli/log.h"
#include "polli/LikwidMarker.h"

REGISTER_LOG(console, "optmize");

namespace llvm {
class Function;
} // namespace llvm

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;

namespace polli {
class PollyFnReport : public llvm::FunctionPass {
public:
  static char ID;
  explicit PollyFnReport() : llvm::FunctionPass(ID) {};

  /// @name FunctionPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.addRequired<polly::ScopDetection>();
    AU.addRequired<llvm::RegionInfoPass>();
    AU.setPreservesAll();
  }

  bool runOnFunction(llvm::Function &F) override {
    const Module *M = F.getParent();
    polly::ScopDetection &SD = getAnalysis<polly::ScopDetection>();
    llvm::RegionInfo &RI = getAnalysis<llvm::RegionInfoPass>().getRegionInfo();
    std::string buf;
    raw_string_ostream os(buf);
    os << "\n===============================================================";
    os << "\n ScopDetection:: " << F.getName();
    os << "\n===============================================================\n";
    for (auto &R : *RI.getTopLevelRegion()) {
      if (!R)
        continue;
      if (const RejectLog *L = SD.lookupRejectionLog(R.get()))
        L->print(os << R->getNameStr() << "\n");
      else
        os << "No log found O.o\n";

      os << "\n";
    }
    SD.print(os, M);
    console->error(os.str());
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}
private:

  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  PollyFnReport(const PollyFnReport &);
  // DO NOT IMPLEMENT
  const PollyFnReport &operator=(const PollyFnReport &);
};

class PollyReport : public polly::ScopPass {
public:
  static char ID;
  explicit PollyReport() : polly::ScopPass(ID) {};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.addRequired<polly::ScopInfoRegionPass>();
    AU.addRequired<polly::IslAstInfo>();
    AU.setPreservesAll();
  }

  bool runOnScop(Scop &S) override {
    IslAstInfo &AI = getAnalysis<IslAstInfo>();
    std::string buf;
    raw_string_ostream os(buf);
    os << "\n==============================================================="
          "\n IslAst"
          "\n===============================================================\n";
    AI.printScop(os, S);
    console->error(os.str());
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}

private:

  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  PollyReport(const PollyReport &);
  // DO NOT IMPLEMENT
  const PollyReport &operator=(const PollyReport &);
};

char PollyFnReport::ID = 0;
char PollyReport::ID = 0;

static void registerPolly(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {

  PM.add(polly::createCodePreparationPass());
  PM.add(polly::createScopDetectionPass());
  PM.add(new PollyFnReport());
  PM.add(polly::createScopInfoRegionPassPass());
  PM.add(polly::createIslAstInfoPass());
  PM.add(polly::createIslScheduleOptimizerPass());
  PM.add(polly::createCodeGenerationPass());
  PM.add(new PollyReport());
  // FIXME: This dummy ModulePass keeps some programs from miscompiling,
  // probably some not correctly preserved analyses. It acts as a barrier to
  // force all analysis results to be recomputed.
  PM.add(createBarrierNoopPass());
  PM.add(polly::createCodegenCleanupPass());
}

PassManagerBuilder createPMB() {
  PassManagerBuilder Builder;

  Builder.VerifyInput = false;
  Builder.VerifyOutput = false;
  Builder.OptLevel = 3;
  polly::opt::PollyParallel = true;
  polly::opt::DetectParallel = true;
  polly::opt::UseContext = true;
  polly::opt::PollyParallelForce = true;
  polly::PollyProcessUnprofitable = false;
  polly::PollyVectorizerChoice = VectorizerChoice::VECTORIZER_POLLY;
  polly::PollyInvariantLoadHoisting = true;
  // We accept them blindly.
  polly::ProfitabilityMinPerLoopInstructions = 0;

  Builder.addExtension(PassManagerBuilder::EP_VectorizerStart, registerPolly);

  return Builder;
}

Function &OptimizeForRuntime(Function &F) {
  PassManagerBuilder Builder = createPMB();
  Module *M = F.getParent();
#ifdef POLLI_STORE_OUTPUT
  opt::GenerateOutput = true;
#endif

  legacy::PassManager PM = legacy::PassManager();

  Builder.populateModulePassManager(PM);

#ifdef POLLI_ENABLE_BASE_POINTERS
  PM.add(polli::createBasePointersPass());
#endif

  //PM.add(polli::createOpenMPTracerPass());

#ifdef POLLI_ENABLE_PAPI
  if (opt::havePapi())
    PM.add(polli::createTraceMarkerPass());
#endif

#ifdef POLLI_ENABLE_LIKWID
  if (opt::haveLikwid())
    PM.add(polli::createLikwidMarkerPass());
#endif

  PM.run(*M);

#ifdef POLLI_STORE_OUTPUT
  DEBUG(StoreModule(*M, M->getModuleIdentifier() + ".after.polly.ll"));
  opt::GenerateOutput = false;
#endif

  DEBUG({
    if (F.hasFnAttribute("polly-optimized"))
      console->error("fn got optimized by polly");
    else
      console->error("fn did not get optimized by polly");
  });

  return F;
}
} // namespace polli
