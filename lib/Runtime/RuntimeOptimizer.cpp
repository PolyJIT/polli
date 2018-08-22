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
#include "polli/Utils.h"

#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/IR/LegacyPassManager.h"

#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polli/ExportMetrics.h"
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

#define LIKWID_PERFMON
namespace likwid {
#include <likwid.h>
}

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
    std::string Buf, IslAstStr, ScheduleTreeStr;
    raw_string_ostream Os(Buf);
    AI.printScop(Os, S);
    IslAstStr = Os.str();

    isl::schedule STree = S.getScheduleTree();
    ScheduleTreeStr = STree.to_str();

    polli::ScopMetadata MD;
    MD.RunID = opt::RunID;
    MD.FunctionName = S.getFunction().getName().str();
    MD.AST = IslAstStr;
    MD.Schedule = ScheduleTreeStr;
    MD.OutFile = opt::TrackScopMetadataFilename;

    polli::yaml::StoreScopMetadata(MD);

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
    console->debug(Os.str());
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

static int getTotalCacheSize(const likwid::CpuTopology_t Topo) {
  int Size = 0;
  for (uint32_t i = 0; i < Topo->numCacheLevels; i++) {
    Size += Topo->cacheLevels[i].size;
  }

  return Size;
}

PassManagerBuilder createPMB() {
  static int TopoInit = likwid::topology_init();
  static auto *CpuTopo = likwid::get_cpuTopology();
  PassManagerBuilder Builder;

  Builder.VerifyInput = false;
  Builder.VerifyOutput = false;
  Builder.OptLevel = 3;
  Builder.SLPVectorize = true;
  Builder.SizeLevel = 0;
  Builder.LoopVectorize = true;

  polly::opt::PollyParallel = true;
  polly::opt::DetectParallel = true;
  polly::opt::RegisterTiling = true;
  polly::opt::DynamicTileSizes = !opt::runtime::UsePollyOptions;
  polly::PollyDelinearize = !opt::runtime::DisableDelinearization;

  polly::opt::CacheSizeInBytes = getTotalCacheSize(CpuTopo);

  // Query likwid for more reliable data.
  polly::opt::NumberOfPhysicalCores = CpuTopo->activeHWThreads;

  if (opt::runtime::EnablePolly) {
    Builder.addExtension(PassManagerBuilder::EP_EarlyAsPossible,
                         ActivePipeline);
  }

  DEBUG(console->debug("Specializer: {:d} Delinearization: {:d}",
                       !opt::runtime::DisableSpecialization,
                       polly::PollyDelinearize));
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
    if (F.isDeclaration())
      continue;
    FPM.run(F);
    Optimized |= F.hasFnAttribute("polly-optimized");;
  }
  DEBUG(console->debug("{:s} optimized? {:d}", M->getName().str(), Optimized));

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
