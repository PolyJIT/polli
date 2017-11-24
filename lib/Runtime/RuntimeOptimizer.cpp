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
#define DEBUG_TYPE "runtime_optimizer"
#include <iostream>

#include "polli/RuntimeOptimizer.h"
#include "polli/Db.h"
#include "polli/Utils.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/LegacyPassManager.h"

#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polli/LikwidMarker.h"
#include "polli/log.h"
#include "polly/Canonicalization.h"
#include "polly/CodeGen/CodeGeneration.h"
#include "polly/CodeGen/CodegenCleanup.h"
#include "polly/CodeGen/IslAst.h"
#include "polly/LinkAllPasses.h"
#include "polly/Options.h"
#include "polly/RegisterPasses.h"
#include "polly/ScheduleOptimizer.h"
#include "polly/ScopDetection.h"
#include "polly/ScopInfo.h"
#include "polly/ScopPass.h"
#include "polly/Support/GICHelper.h"

#include "isl/isl-noexceptions.h"

REGISTER_LOG(console, DEBUG_TYPE);

namespace llvm {
class Function;
} // namespace llvm

using namespace llvm;
using namespace llvm::legacy;
using namespace polly;
using namespace isl;

namespace polli {
class TileSizeLearner : public polly::ScopPass {
public:
  static char ID;
  explicit TileSizeLearner() : polly::ScopPass(ID){};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.addRequired<llvm::ScalarEvolutionWrapperPass>();
    ScopPass::getAnalysisUsage(AU);
    AU.setPreservesAll();
  }

  bool runOnScop(Scop &S) override {
    DEBUG({
      std::string buf;
      raw_string_ostream os(buf);
      os << "\n==============================================================="
            "\n Learn TileSizes"
            "\n==============================================================="
            "\n";
      console->info(os.str());
    });
    ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();
    const Loop *L, *SecondL;
    uint64_t NumThreads = polli::opt::getNumThreads();
    uint64_t NumAccesses = 0;
    uint64_t MaxDimensions = 0;
    uint64_t TaskSize = 32;

    ConstantInt *FirstLevelTileSize =
        ConstantInt::get(Type::getInt64Ty(SE.getContext()), TaskSize);
    ConstantInt *SecondLevelTileSize =
        ConstantInt::get(Type::getInt64Ty(SE.getContext()), 32);

    for (auto &Stmt : S) {
      L = nullptr;
      if (Stmt.getNumIterators() > 0)
        L = Stmt.getLoopForDimension(0);
      MaxDimensions = (uint64_t)std::max((double)MaxDimensions,
                                         (double)Stmt.getNumIterators());
      if (!L)
        continue;

      /* First level */
      {
        auto *TripCount = SE.getBackedgeTakenCount(L);
        if (const SCEVConstant *Constant = dyn_cast<SCEVConstant>(TripCount)) {
          ConstantInt *CI = Constant->getValue();
          uint64_t Cnt = static_cast<uint64_t>(
              std::ceil((double)CI->getLimitedValue() / NumThreads));
          uint64_t OldCnt = static_cast<uint64_t>(
              std::ceil((double)FirstLevelTileSize->getLimitedValue()));

          TaskSize = std::max(Cnt, OldCnt);
          FirstLevelTileSize =
              ConstantInt::get(FirstLevelTileSize->getType(), TaskSize);
        }
      }

      /* Second level */
      SecondL = nullptr;
      if (Stmt.getNumIterators() > 1)
        SecondL = Stmt.getLoopForDimension(1);
      if (!SecondL)
        continue;
      {
        NumAccesses += Stmt.size();
        SecondLevelTileSize = ConstantInt::get(
            FirstLevelTileSize->getType(),
            static_cast<uint64_t>((double)TaskSize / NumAccesses));
      }
    }

    if (polly::opt::FirstLevelTileSizes.empty()) {
      polly::opt::FirstLevelTileSizes.addValue(
          FirstLevelTileSize->getLimitedValue());
      for (unsigned I = 1; I < MaxDimensions; I++) {
        polly::opt::FirstLevelTileSizes.addValue(
            std::numeric_limits<int>::max());
      }
    }
    DEBUG({
      std::string buf;
      raw_string_ostream os(buf);
      os << " FirstLevelTileSize : " << *FirstLevelTileSize << " tile size.\n";
      os << " SecondLevelTileSize : " << *SecondLevelTileSize
         << " tile size.\n";
      console->info(os.str());
    });
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}
};
char TileSizeLearner::ID = 0;

class PollyFnReport : public llvm::FunctionPass {
public:
  static char ID;
  explicit PollyFnReport() : llvm::FunctionPass(ID){};

  /// @name FunctionPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.addRequired<polly::ScopDetectionWrapperPass>();
    AU.addRequired<llvm::RegionInfoPass>();
    AU.setPreservesAll();
  }

  bool runOnFunction(llvm::Function &F) override {
    const Module *M = F.getParent();
    polly::ScopDetectionWrapperPass &SDWP =
        getAnalysis<polly::ScopDetectionWrapperPass>();
    polly::ScopDetection &SD = SDWP.getSD();
    llvm::RegionInfo &RI = getAnalysis<llvm::RegionInfoPass>().getRegionInfo();
    std::string Buf;
    raw_string_ostream Os(Buf);
    Os << "\n===============================================================";
    Os << "\n ScopDetection:: " << F.getName();
    Os << "\n===============================================================\n";
    for (auto &R : *RI.getTopLevelRegion()) {
      if (!R)
        continue;
      if (const RejectLog *L = SD.lookupRejectionLog(R.get()))
        L->print(Os << R->getNameStr() << "\n");
      else
        Os << R->getNameStr() << " No log entry found.\n";
      Os << "\n";
    }
    SDWP.print(Os, M);
    console->info(Os.str());
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

class PollyScopReport : public llvm::FunctionPass {
public:
  static char ID;
  explicit PollyScopReport() : llvm::FunctionPass(ID){};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.addRequired<polly::ScopInfoWrapperPass>();
    AU.setPreservesAll();
  }

  bool runOnFunction(Function &F) override {
    ScopInfoWrapperPass &SI = getAnalysis<polly::ScopInfoWrapperPass>();
    std::string Buf;
    raw_string_ostream Os(Buf);
    Os << "\n==============================================================="
          "\n Modelling"
          "\n===============================================================\n";
    SI.print(Os, F.getParent());
    console->info(Os.str());
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}

private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  PollyScopReport(const PollyScopReport &);
  // DO NOT IMPLEMENT
  const PollyScopReport &operator=(const PollyScopReport &);
};

class DBExport : public polly::ScopPass {
public:
  static char ID;
  explicit DBExport() : polly::ScopPass(ID){};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    ScopPass::getAnalysisUsage(AU);
    AU.addRequired<polly::IslAstInfoWrapperPass>();
    AU.setPreservesAll();
  }

  bool runOnScop(Scop &S) override {
    IslAstInfoWrapperPass &AI = getAnalysis<IslAstInfoWrapperPass>();
    std::string Buf, IslAstrStr, ScheduleTreeStr;
    raw_string_ostream Os(Buf);
    AI.printScop(Os, S);
    IslAstrStr = Os.str();

    isl::schedule STree = S.getScheduleTree();
    ScheduleTreeStr = STree.to_str();

    db::StoreTransformedScop(S.getFunction().getName().str(), IslAstrStr,
                             ScheduleTreeStr);

    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}
};

class PollyReport : public polly::ScopPass {
public:
  static char ID;
  explicit PollyReport() : polly::ScopPass(ID){};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    ScopPass::getAnalysisUsage(AU);
    AU.addRequired<polly::IslAstInfoWrapperPass>();
    AU.setPreservesAll();
  }

  bool runOnScop(Scop &S) override {
    auto &AIWP = getAnalysis<IslAstInfoWrapperPass>();
    std::string Buf;
    raw_string_ostream Os(Buf);
    Os << "\n==============================================================="
          "\n IslAst"
          "\n===============================================================\n";
    AIWP.printScop(Os, S);

    isl::schedule STree = S.getScheduleTree();
    std::string ST = STree.to_str();

    Os << "\n" << ST << "\n";
    console->info(Os.str());
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}
};

class PollyScheduleReport : public polly::ScopPass {
public:
  static char ID;
  explicit PollyScheduleReport() : polly::ScopPass(ID){};

  /// @name ScopPass interface
  //@{
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    ScopPass::getAnalysisUsage(AU);
    AU.addRequired<polly::IslScheduleOptimizer>();
    AU.setPreservesAll();
  }

  bool runOnScop(Scop &S) override {
    polly::IslScheduleOptimizer &SO =
        getAnalysis<polly::IslScheduleOptimizer>();
    std::string Buf;
    raw_string_ostream Os(Buf);
    Os << "\n==============================================================="
          "\n ScheduleReport"
          "\n===============================================================\n";
    SO.printScop(Os, S);
    console->info(Os.str());
    return false;
  }

  void print(llvm::raw_ostream &OS, const llvm::Module *) const override {}
  //@}

private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  PollyScheduleReport(const PollyReport &);
  // DO NOT IMPLEMENT
  const PollyScheduleReport &operator=(const PollyReport &);
};

char PollyFnReport::ID = 0;
char PollyReport::ID = 0;
char PollyScopReport::ID = 0;
char PollyScheduleReport::ID = 0;
char DBExport::ID = 0;

static void registerPolly(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  //polly::registerCanonicalicationPasses(PM);
  PM.add(polly::createCodePreparationPass());
  PM.add(polly::createScopDetectionWrapperPassPass());
  PM.add(polly::createScopInfoRegionPassPass());
  PM.add(new TileSizeLearner());
  PM.add(polly::createIslScheduleOptimizerPass());
  PM.add(polly::createCodeGenerationPass());
  PM.add(polly::createCodegenCleanupPass());

  // FIXME: This dummy ModulePass keeps some programs from miscompiling,
  // probably some not correctly preserved analyses. It acts as a barrier to
  // force all analysis results to be recomputed.
  //PM.add(createBarrierNoopPass());
}

static void registerPollyWithDiagnostics(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  //polly::registerCanonicalicationPasses(PM);
  PM.add(polly::createScopDetectionWrapperPassPass());
  PM.add(polly::createScopInfoRegionPassPass());
  if (!opt::runtime::UsePollyOptions)
    PM.add(new TileSizeLearner());
  PM.add(polly::createIslScheduleOptimizerPass());

  if (opt::runtime::EnableScheduleReport)
    PM.add(new PollyScheduleReport());
  if (opt::runtime::EnableDatabaseExport)
    PM.add(new DBExport());
  if (opt::runtime::EnableASTReport)
    PM.add(new PollyReport());

  PM.add(polly::createCodeGenerationPass());

  if (opt::runtime::EnableScopReport)
    PM.add(new PollyScopReport());
  if (opt::runtime::EnableFunctionReport)
    PM.add(new PollyFnReport());

  // FIXME: This dummy ModulePass keeps some programs from miscompiling,
  // probably some not correctly preserved analyses. It acts as a barrier to
  // force all analysis results to be recomputed.
  //PM.add(createBarrierNoopPass());
}

using PipelineFunc = std::function<void(const llvm::PassManagerBuilder &, llvm::legacy::PassManagerBase &)>;
static PipelineFunc ActivePipeline = registerPolly;

void SetOptimizationPipeline(PipelineType Choice) {
  switch(Choice) {
    case RELEASE:
      ActivePipeline = registerPolly;
      break;
    case DEBUG:
      ActivePipeline = registerPollyWithDiagnostics;
      break;
  }
}

PassManagerBuilder createPMB() {
  PassManagerBuilder Builder;

  Builder.VerifyInput = false;
  Builder.VerifyOutput = false;
  Builder.OptLevel = 3;
  Builder.SLPVectorize = true;
  Builder.SizeLevel = 0;
  Builder.LoopVectorize = true;

  polly::opt::PollyParallel = true;
  polly::opt::DetectParallel = true;

  polly::PollyDelinearize = opt::runtime::DisableDelinearization;

  if (!opt::runtime::UsePollyOptions) {
    polly::opt::UseContext = true;
    polly::opt::PollyParallelForce = false;
    polly::PollyProcessUnprofitable = false;
    polly::opt::FusionStrategy = "max";
    polly::opt::WholeComponent = true;
    polly::opt::FirstLevelTiling = true;
    polly::opt::SecondLevelTiling = false;
    polly::opt::RegisterTiling = false;
    polly::PollyAllowNonAffineSubRegions = false;
    polly::PollyInvariantLoadHoisting = true;
  }

  if (opt::runtime::EnablePolly) {
    Builder.addExtension(PassManagerBuilder::EP_EarlyAsPossible,
                         ActivePipeline);
  }

  return Builder;
}

SharedModule RuntimeOptimizer::operator()(SharedModule M) {
  PassManagerBuilder Builder = createPMB();
#ifdef POLLI_STORE_OUTPUT
  opt::GenerateOutput = true;
#endif

  legacy::PassManager PM = legacy::PassManager();
  legacy::FunctionPassManager FPM = legacy::FunctionPassManager(M.get());
  Builder.populateFunctionPassManager(FPM);
  Builder.populateModulePassManager(PM);

// PM.add(polli::createOpenMPTracerPass());

#ifdef POLLI_ENABLE_PAPI
  if (opt::havePapi())
    PM.add(polli::createTraceMarkerPass());
#endif

#ifdef POLLI_ENABLE_LIKWID
  if (opt::haveLikwid())
    PM.add(polli::createLikwidMarkerPass());
#endif

  FPM.doInitialization();

  bool Optimized = false;
  for (auto &F : *M) {
    FPM.run(F);
    bool FnOptimized = F.hasFnAttribute("polly-optimized");
    Optimized |= FnOptimized;
    DEBUG({
      if (FnOptimized)
        console->error("fn got optimized by polly");
      else
        console->error("fn did not get optimized by polly");
    });
  }

  FPM.doFinalization();
  PM.run(*M);

  if (Optimized)
    OptimizedModules.insert(M);

#ifdef POLLI_STORE_OUTPUT
  DEBUG(StoreModule(*M, M->getModuleIdentifier() + ".after.polly.ll"));
  opt::GenerateOutput = false;
#endif

  return M;
}
} // namespace polli
