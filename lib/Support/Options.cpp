//===------------- polli/Options.cpp - The Polli option category *- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Introduce an option category for Polli.
//
//===----------------------------------------------------------------------===//

#include "polli/Options.h"
#include "polli/Utils.h"
#include "polli/log.h"
#include "llvm/Support/CommandLine.h"
#include <string>
#include <vector>

#include <unistd.h>

#define DEBUG_TYPE polyjit
#include "llvm/Support/Debug.h"

REGISTER_LOG(console, "polyjit.options");

using namespace llvm;
using namespace llvm::cl;
using std::string;

llvm::cl::OptionCategory PolliCategory("PolyJIT Options",
                                       "Configure options of PolyJIT");
llvm::cl::OptionCategory PolyJitRuntime("libpjit Options",
                                        "Configure runtime options of libpjit "
                                        "(Use environment variable: PJIT_ARGS");
llvm::cl::OptionCategory
    PolyJitCompiletime("LLVMPolyJIT Options",
                       "Configure compile-time options of PolyJIT ");

namespace polli {
namespace opt {
bool EnableTracking;
static ::opt<bool, true> EnableTrackingX("polli-track",
                                         ::desc("Track metrics in .yml files."),
                                         ::location(EnableTracking),
                                         ::init(false), ::cat(PolyJitRuntime));

string TrackMetricsFilename;
static ::opt<string, true> TrackMetricsFilenameX(
    "polli-track-metrics-outfile", ::desc("Path for .yml outfile."),
    ::location(TrackMetricsFilename), ::init("UNSET"), ::cat(PolyJitRuntime));

string TrackScopMetadataFilename;
static ::opt<string, true>
    TrackScopMetadataFilenameX("polli-track-scop-metadata-outfile",
                               ::desc("Path for .yml outfile."),
                               ::location(TrackScopMetadataFilename),
                               ::init("UNSET"), ::cat(PolyJitRuntime));
string Experiment;
static ::opt<string, true> ExperimentX(
    "polli-experiment", ::desc("Name of the experiment we are running under."),
    ::location(Experiment), ::init("unknown"), ::cat(PolyJitRuntime));

string ExperimentUUID;
static ::opt<string, true>
    ExperimentUUIDX("polli-experiment-uuid", ::desc("Experiment UUID."),
                    ::location(ExperimentUUID),
                    ::init("00000000-0000-0000-0000-000000000000"),
                    ::cat(PolyJitRuntime));

string Project;
static ::opt<string, true> ProjectX("polli-project",
                                    ::desc("The project we are running under."),
                                    ::location(Project), ::init("unknown"),
                                    ::cat(PolyJitRuntime));

string Domain;
static ::opt<string, true> DomainX("polli-domain",
                                   ::desc("The domain we are running under."),
                                   ::location(Domain), ::init("unknown"),
                                   ::cat(PolyJitRuntime));

string Group;
static ::opt<string, true> GroupX("polli-group",
                                  ::desc("The group we are running under."),
                                  ::location(Group), ::init("unknown"),
                                  ::cat(PolyJitRuntime));

string SourceUri;
static ::opt<string, true>
    SourceUriX("polli-src-uri", ::desc("The src_uri we are running under."),
               ::location(SourceUri), ::init("unknown"), ::cat(PolyJitRuntime));

string Argv0;
static ::opt<string, true> Argv0X("polli-argv",
                                  ::desc("The command we are executing."),
                                  ::location(SourceUri), ::init("unknown"),
                                  ::cat(PolyJitRuntime));

string RunGroupUUID;
static ::opt<string, true> RunGroupUUIDX(
    "polli-run-group", ::desc("RunGroup (UUID)"), ::location(RunGroupUUID),
    ::init("00000000-0000-0000-0000-000000000000"), ::cat(PolyJitRuntime));

int RunID;
static ::opt<int, true> RunIdX("polli-run-id", ::desc("RunGroup (UUID)"),
                               ::location(RunID), ::init(0),
                               ::cat(PolyJitRuntime));

spdlog::level::level_enum LogLevel;
static cl::opt<spdlog::level::level_enum, true>
    LogLevelX("polli-log-level", cl::desc("Configure PolyJIT's log level."),
              cl::values(clEnumValN(spdlog::level::off, "off", "Off"),
                         clEnumValN(spdlog::level::info, "info", "Info"),
                         clEnumValN(spdlog::level::warn, "warn", "Warn"),
                         clEnumValN(spdlog::level::err, "error", "Error"),
                         clEnumValN(spdlog::level::debug, "debug", "Debug"),
                         clEnumValN(spdlog::level::trace, "trace", "Trace")),
              cl::location(LogLevel), cl::init(spdlog::level::off),
              cl::ZeroOrMore, cl::cat(PolyJitRuntime));

bool DisableRecompile;
static cl::opt<bool, true> DisableRecompileX(
    "polli-no-recompilation", cl::desc("Disable recompilation of SCoPs"),
    cl::location(DisableRecompile), cl::init(false), cl::cat(PolliCategory));

bool DisableCoreFiles = true;
static cl::opt<bool, true>
    DisableCoreFilesX("polli-disable-core-files",
                      cl::desc("Disable emission of core files if possible"),
                      cl::location(DisableCoreFiles), cl::init(false),
                      cl::cat(PolliCategory));

bool EnableLogFile;
static cl::opt<bool, true>
    EnableLogFileX("polli-enable-log",
                   cl::desc("Enable logging to file instead of stderr"),
                   cl::location(EnableLogFile), cl::init(false), cl::ZeroOrMore,
                   cl::cat(PolliCategory));

namespace runtime {
PipelineType PipelineChoice;
static cl::opt<PipelineType, true> PipelineChoiceX(
    "polli-optimizer",
    cl::desc("Which optimization pipeline should be enabled?"),
    cl::values(
        clEnumValN(RELEASE, "release",
                   "Enable the default 'release' pipeline. No debug output"),
        clEnumValN(DEBUG, "debug",
                   "Enable the debug pipeline. Additional "
                   "configuration determines the amount of "
                   "debug output you get.")),
    cl::location(PipelineChoice), cl::init(RELEASE), cl::ZeroOrMore,
    cl::cat(PolyJitRuntime));

char OptLevel = ' ';
std::string MArch = "";
std::string MCPU = "";
std::vector<std::string> MAttrs;
std::string TargetTriple = "x86-64_unknown-linux-gnu";

bool DisableExecution;
static cl::opt<bool, true> DisableExecutionX(
    "polli-no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::location(DisableExecution), cl::init(false), cl::cat(PolyJitRuntime));

bool DisableDelinearization;
static cl::opt<bool, true> DisableDelinearizationX(
    "polli-no-delinearization",
    cl::desc("Disable delinearization of multi-dimensional arrays"),
    cl::location(DisableDelinearization), cl::init(false),
    cl::cat(PolliCategory));

bool DisableSpecialization;
static cl::opt<bool, true>
    DisableSpecializationX("polli-no-specialization",
                           cl::desc("Disable specialziation"),
                           cl::location(DisableSpecialization), cl::init(false),
                           cl::cat(PolyJitRuntime));

bool GenerateOutput;
static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::location(GenerateOutput), cl::init(false), cl::cat(PolyJitRuntime));

bool EnablePapi;
static cl::opt<bool, true> EnablePapiX("polli-papi",
                                       cl::desc("Enable PAPI tracing"),
                                       cl::location(EnablePapi),
                                       cl::init(false),
                                       cl::cat(PolyJitRuntime));

bool EnableDatabaseExport;
static cl::opt<bool, true>
    EnableDatabaseExportX("polli-database-export",
                          cl::desc("Enable export of debug information to a "
                                   "configured database connection."),
                          cl::location(EnableDatabaseExport), cl::init(false),
                          cl::cat(PolyJitRuntime));

bool EnableScheduleReport;
static cl::opt<bool, true>
    EnableScheduleReportX("polli-schedule-report",
                          cl::desc("Print optimized schedule information"),
                          cl::location(EnableScheduleReport), cl::init(false),
                          cl::cat(PolyJitRuntime));

bool EnableScopReport;
static cl::opt<bool, true> EnableScopReportX(
    "polli-scop-report", cl::desc("Print optimized scop information"),
    cl::location(EnableScopReport), cl::init(false), cl::cat(PolyJitRuntime));

bool EnableFunctionReport;
static cl::opt<bool, true>
    EnableFunctionReportX("polli-function-report",
                          cl::desc("Print optimized function information"),
                          cl::location(EnableFunctionReport), cl::init(false),
                          cl::cat(PolyJitRuntime));

bool EnableASTReport;
static cl::opt<bool, true> EnableASTReportX(
    "polli-ast-report", cl::desc("Print optimized isl-ast information"),
    cl::location(EnableASTReport), cl::init(false), cl::cat(PolyJitRuntime));

bool UsePollyOptions;
static cl::opt<bool, true> UsePollyOptionsX(
    "polli-use-polly-options",
    cl::desc("Use Polly's settings in the optimizer pipeline."),
    cl::location(UsePollyOptions), cl::init(true), cl::cat(PolyJitRuntime));

bool EnablePolly;
static cl::opt<bool, true>
    EnablePollyX("polli-enable-polly",
                 cl::desc("Use Polly's settings in the optimizer pipeline."),
                 cl::location(EnablePolly), cl::init(true),
                 cl::cat(PolyJitRuntime));

} // namespace runtime

namespace compiletime {

bool InstrumentRegions;
static cl::opt<bool, true>
    InstrumentRegionsX("polli-instrument",
                       cl::desc("Enable instrumenting of SCoPs"),
                       cl::location(InstrumentRegions), cl::init(false),
                       cl::cat(PolyJitCompiletime));

bool AnalyzeIR;
static cl::opt<bool, true>
    AnalyzeIRX("polli-analyze",
               cl::desc("Throw in a bunch of function printers for "
                        "PolyJIT's static compilation passes."),
               cl::location(AnalyzeIR), cl::init(false),
               cl::cat(PolyJitCompiletime));

bool ProfileScops;
static cl::opt<bool, true>
    ProfileScopsX("polli-profile-scops",
                  cl::desc("Instrument regions that are not yet a "
                           "valid SCoP for runtime-profiling"),
                  cl::location(ProfileScops), cl::init(false),
                  cl::cat(PolyJitCompiletime));

bool CollectRegressionTests = false;
static cl::opt<bool, true> PolliCollectX(
    "polli-collect-modules",
    cl::desc("Collect Modules in the database for regression testing."),
    cl::ZeroOrMore, cl::location(CollectRegressionTests), cl::init(false),
    cl::cat(PolyJitCompiletime));

bool Enabled;
static cl::opt<bool, true> EnabledX("polli", cl::desc("Enable PolyJIT"),
                                    cl::location(Enabled), cl::init(false),
                                    cl::cat(PolyJitCompiletime));

} // namespace compiletime

void ValidateOptions() {
  using namespace runtime;
  if (EnableScheduleReport || EnableScopReport || EnableFunctionReport ||
      EnableASTReport || EnableDatabaseExport) {
    PipelineChoice = DEBUG;
  }

  // This needs to be supported via environment variable too
  // because there is no way for the tool 'benchbuild' to provide
  // the run_id as program argument for now.
  if (RunID == 0) {
    if (const char *RunId = std::getenv("BB_DB_RUN_ID")) {
      opt::RunID = RunId ? std::stoi(RunId) : 0;
    }
  }
}

/**
 * @brief Check, if we have likwid support at run-time.
 *
 * @return bool
 */
bool haveLikwid() { return std::getenv("LIKWID_MODE") != nullptr; }

uint64_t getNumThreads() {
  if (const char *NumThreadsStr = std::getenv("OMP_NUM_THREADS")) {
    return std::atoi(NumThreadsStr);
  }

  return std::thread::hardware_concurrency();
}

} // namespace opt
} // namespace polli
