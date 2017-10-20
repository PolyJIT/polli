#include "polli/Jit.h"
#include "polli/Db.h"
#include "polli/Options.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/log.h"
#include "pprof/pprof.h"

#include "llvm/IR/Function.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/PassRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/TargetSelect.h"

#include "polly/RegisterPasses.h"
#include <papi.h>

using namespace llvm;

REGISTER_LOG(console, "jit");

namespace polli {
using StackTracePtr = std::unique_ptr<llvm::PrettyStackTraceProgram>;
static StackTracePtr StackTrace;

void PolyJIT::setup() {
  tracing::setup_tracing();
  enter(JitRegion::START, PAPI_get_real_usec());

  using polly::initializePollyPasses;
  StackTrace = StackTracePtr(new llvm::PrettyStackTraceProgram(0, nullptr));

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
  exit(JitRegion::START, PAPI_get_real_usec());
  db::StoreRun(Events, Entries, Regions);
}
} // namespace polli
