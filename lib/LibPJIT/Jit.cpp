#include "llvm/PassRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/TargetSelect.h"

#include "polli/Db.h"
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
using llvm::InitializeNativeTargetAsmPrinter;
using llvm::InitializeNativeTargetAsmParser;
using llvm::PassRegistry;
using llvm::PrettyStackTraceProgram;

using polli::opt::ValidateOptions;
using polli::tracing::setup_tracing;

using polly::initializePollyPasses;

REGISTER_LOG(console, "jit");

namespace polli {
using StackTracePtr = std::unique_ptr<PrettyStackTraceProgram>;
static StackTracePtr StackTrace;

void PolyJIT::setup() {
  setup_tracing();
  enter(JitRegion::START, papi::PAPI_get_real_usec());

  StackTrace = StackTracePtr(new PrettyStackTraceProgram(0, nullptr));

  // Make sure to initialize tracing before planting the atexit handler.
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

  /* CACHE_HIT */
  enter(JitRegion::CACHE_HIT, 0);

  Regions[JitRegion::START] = "START";
  Regions[JitRegion::CODEGEN] = "CODEGEN";
  Regions[JitRegion::VARIANTS] = "VARIANTS";
  Regions[JitRegion::CACHE_HIT] = "CACHE_HIT";

  SetOptimizationPipeline(opt::runtime::PipelineChoice);
  opt::ValidateOptions();
  db::ValidateOptions();
}

void PolyJIT::tearDown() {
  exit(JitRegion::START, papi::PAPI_get_real_usec());
  db::StoreRun(Events, Entries, Regions);
}
} // namespace polli
