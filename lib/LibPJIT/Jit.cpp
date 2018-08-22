#include "llvm/PassRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/TargetSelect.h"

#include "polli/ExportMetrics.h"
#include "polli/Jit.h"
#include "polli/Options.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/log.h"

#include "pprof/Tracing.h"
#include "polly/RegisterPasses.h"
namespace papi {
#include <papi.h>
} // namespace papi

using llvm::InitializeNativeTarget;
using llvm::InitializeNativeTargetAsmParser;
using llvm::InitializeNativeTargetAsmPrinter;
using llvm::PassRegistry;
using llvm::PrettyStackTraceProgram;

using polli::opt::ValidateOptions;

using polly::initializePollyPasses;

REGISTER_LOG(console, "jit");

namespace polli {
static std::unique_ptr<PrettyStackTraceProgram> StackTrace;

static void SetupJitEventData(JitEventData &Data) {
  Data.RunID = opt::RunID;
  Data.OutFile = opt::TrackMetricsFilename;
}

static void SetupDefaultRegions(RegionMapTy &Regions) {
  Regions[JitRegion::START] = "START";
  Regions[JitRegion::CODEGEN] = "CODEGEN";
  Regions[JitRegion::VARIANTS] = "VARIANTS";
  Regions[JitRegion::CACHE_HIT] = "CACHE_HIT";
  Regions[JitRegion::REQUESTS] = "REQUESTS";
  Regions[JitRegion::BLOCKED] = "BLOCKED";
}

static void SetupLLVM() {
  PassRegistry &Registry = *PassRegistry::getPassRegistry();
  polly::initializePollyPasses(Registry);
  initializeCore(Registry);
  initializeScalarOpts(Registry);
  initializeVectorization(Registry);
  initializeIPO(Registry);
  initializeAnalysis(Registry);
  initializeTransformUtils(Registry);
  initializeInstCombine(Registry);
  initializeInstrumentation(Registry);
  initializeTarget(Registry);
  initializeCodeGenPreparePass(Registry);
  initializeAtomicExpandPass(Registry);

  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();
  InitializeNativeTargetAsmParser();
}

void PolyJIT::setup() {
  papi::PAPI_library_init(PAPI_VER_CURRENT);
  llvm::cl::ParseEnvironmentOptions("profile-scops", "PJIT_ARGS", "");

  StackTrace = std::make_unique<PrettyStackTraceProgram>(0, nullptr);
  opt::ValidateOptions();
  SetupJitEventData(EventData);
  SetupDefaultRegions(Regions);
  SetupLLVM();
  SetOptimizationPipeline(opt::runtime::PipelineChoice);

  enter(JitRegion::START, papi::PAPI_get_real_usec());
}

void PolyJIT::tearDown() {
  exit(JitRegion::START, papi::PAPI_get_real_usec());
  EventData.Events =
      llvm::SmallVector<JitEventData::EventTy, 8>(Events.begin(), Events.end());
  EventData.Entries = llvm::SmallVector<JitEventData::EventTy, 8>(
      Entries.begin(), Entries.end());
  EventData.Regions = llvm::SmallVector<JitEventData::IdToNameTy, 8>(
      Regions.begin(), Regions.end());

  yaml::StoreRun(EventData);
}
} // namespace polli
