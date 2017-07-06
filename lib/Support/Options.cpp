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
#include "llvm/Support/CommandLine.h"
#include <string>
#include <vector>

#include <unistd.h>

#define DEBUG_TYPE polyjit
#include "llvm/Support/Debug.h"

using namespace llvm;

llvm::cl::OptionCategory PolliCategory("PolyJIT Options",
                                       "Configure options of PolyJIT");
llvm::cl::OptionCategory
    PolyJIT_Runtime("libpjit Options", "Configure runtime options of libpjit "
                                       "(Use environment variable: PJIT_ARGS");
llvm::cl::OptionCategory
    PolyJIT_Compiletime("LLVMPolyJIT Options",
                        "Configure compile-time options of PolyJIT ");

namespace polli {
namespace opt {
spdlog::level::level_enum LogLevel;
static cl::opt<spdlog::level::level_enum, true> LogLevelX(
    "polli-log-level",
    cl::desc("Configure PolyJIT's log level."),
    cl::values(
        clEnumValN(spdlog::level::off, "off", "Off"),
        clEnumValN(spdlog::level::info, "info", "Info"),
        clEnumValN(spdlog::level::warn, "warn", "Warn"),
        clEnumValN(spdlog::level::err,  "error", "Error"),
        clEnumValN(spdlog::level::debug, "debug", "Debug"),
        clEnumValN(spdlog::level::trace, "trace", "Trace")),
    cl::location(LogLevel), cl::init(spdlog::level::off), cl::ZeroOrMore, cl::cat(PolyJIT_Runtime));

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
static cl::opt<bool, true> EnableLogFileX(
    "polli-enable-log", cl::desc("Enable logging to file instead of stderr"),
    cl::location(EnableLogFile), cl::init(false), cl::ZeroOrMore, cl::cat(PolliCategory));

namespace runtime {
PipelineType PipelineChoice;
static cl::opt<PipelineType, true> PipelineChoiceX(
    "polli-optimizer",
    cl::desc("Which optimization pipeline should be enabled?"),
    cl::values(
        clEnumValN(RELEASE, "release",
                   "Enable the default 'release' pipeline. No debug output"),
        clEnumValN(DEBUG, "debug", "Enable the debug pipeline. Additional "
                                   "configuration determines the amoun of "
                                   "debug output you get.")),
    cl::location(PipelineChoice), cl::init(RELEASE), cl::ZeroOrMore, cl::cat(PolyJIT_Runtime));

char OptLevel = ' ';
std::string MArch = "";
std::string MCPU = "";
std::vector<std::string> MAttrs;
std::string TargetTriple = "x86-64_unknown-linux-gnu";

bool DisableExecution;
static cl::opt<bool, true> DisableExecutionX(
    "polli-no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::location(DisableExecution), cl::init(false), cl::cat(PolyJIT_Runtime));

bool DisableSpecialization;
static cl::opt<bool, true>
    DisableSpecializationX("polli-no-specialization",
                           cl::desc("Disable specialziation"),
                           cl::location(DisableSpecialization), cl::init(false),
                           cl::cat(PolyJIT_Runtime));

bool GenerateOutput;
static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::location(GenerateOutput), cl::init(false), cl::cat(PolyJIT_Runtime));

bool EnablePapi;
static cl::opt<bool, true> EnablePapiX("polli-papi",
                                       cl::desc("Enable PAPI tracing"),
                                       cl::location(EnablePapi),
                                       cl::init(false),
                                       cl::cat(PolyJIT_Runtime));

bool EnableDatabaseExport;
static cl::opt<bool, true>
    EnableDatabaseExportX("polli-database-export",
                          cl::desc("Enable export of debug information to a "
                                   "configured database connection."),
                          cl::location(EnableDatabaseExport), cl::init(false),
                          cl::cat(PolyJIT_Runtime));

bool EnableScheduleReport;
static cl::opt<bool, true>
    EnableScheduleReportX("polli-schedule-report",
                          cl::desc("Print optimized schedule information"),
                          cl::location(EnableScheduleReport), cl::init(false),
                          cl::cat(PolyJIT_Runtime));

bool EnableScopReport;
static cl::opt<bool, true> EnableScopReportX(
    "polli-scop-report", cl::desc("Print optimized scop information"),
    cl::location(EnableScopReport), cl::init(false), cl::cat(PolyJIT_Runtime));

bool EnableFunctionReport;
static cl::opt<bool, true>
    EnableFunctionReportX("polli-function-report",
                          cl::desc("Print optimized function information"),
                          cl::location(EnableFunctionReport), cl::init(false),
                          cl::cat(PolyJIT_Runtime));

bool EnableASTReport;
static cl::opt<bool, true> EnableASTReportX(
    "polli-ast-report", cl::desc("Print optimized isl-ast information"),
    cl::location(EnableASTReport), cl::init(false), cl::cat(PolyJIT_Runtime));
} // namespace runtime

namespace compiletime {

bool InstrumentRegions;
static cl::opt<bool, true>
    InstrumentRegionsX("polli-instrument",
                       cl::desc("Enable instrumenting of SCoPs"),
                       cl::location(InstrumentRegions), cl::init(false),
                       cl::cat(PolyJIT_Compiletime));

bool AnalyzeIR;
static cl::opt<bool, true> AnalyzeIRX(
    "polli-analyze", cl::desc("Throw in a bunch of function printers for "
                              "PolyJIT's static compilation passes."),
    cl::location(AnalyzeIR), cl::init(false), cl::cat(PolyJIT_Compiletime));

bool CollectRegressionTests = false;
static cl::opt<bool, true> PolliCollectX(
    "polli-collect-modules",
    cl::desc("Collect Modules in the database for regression testing."),
    cl::ZeroOrMore, cl::location(CollectRegressionTests), cl::init(false),
    cl::cat(PolyJIT_Compiletime));

bool Enabled;
static cl::opt<bool, true> EnabledX("polli", cl::desc("Enable PolyJIT"),
                                    cl::location(Enabled), cl::init(false),
                                    cl::cat(PolyJIT_Compiletime));

} // namespace compiletime

void ValidateOptions() {
  using namespace runtime;
  if (EnableScheduleReport || EnableScopReport || EnableFunctionReport ||
      EnableASTReport || EnableDatabaseExport) {
    PipelineChoice = DEBUG;

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

  return 0;
}

} // namespace opt
} // namespace polli