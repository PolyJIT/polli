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

#include "spdlog/spdlog.h"
#include <unistd.h>

using namespace llvm;
using namespace spdlog;

llvm::cl::OptionCategory
    PolliCategory("Polli Options", "Configure the runtime options of polli");

namespace polli {

bool setupLogging() {
  spdlog::set_async_mode(1048576);
  spdlog::set_level(spdlog::level::trace);
  //spdlog::set_level((spdlog::level::level_enum)opt::LogLevel);
  return true;
}

namespace opt {
bool InstrumentRegions;
bool EnableJitable;
bool DisableRecompile;
bool DisableExecution;
bool DisablePreopt;
bool AnalyzeIR = false;
bool AnalyseOnly;
std::string ReportFilename;
bool GenerateOutput;
polli::LogType LogLevel;
bool Enabled;

std::vector<std::string> LibPaths;
std::vector<std::string> Libraries;
std::string InputFile;
std::vector<std::string> InputArgv;
std::string EntryFunc;
std::string FakeArgv0;
bool DisableCoreFiles = true;
char OptLevel = ' ';
std::string TargetTriple = "";
std::string MArch = "";
std::string MCPU = "";
std::vector<std::string> MAttrs;
llvm::Reloc::Model RelocModel = Reloc::Default;
llvm::CodeModel::Model CModel = CodeModel::JITDefault;
llvm::FloatABI::ABIType FloatABIForCalls = FloatABI::Default;
bool GenerateSoftFloatCalls = false;
bool EnableJITExceptionHandling = false;
bool EmitJitDebugInfo = false;
bool EmitJitDebugInfoToDisk = false;
bool EmitEnv = false;

/**
 * @brief Check, if we should perform PAPI based runtime instrumentation.
 *
 * @return True, if we should enable PAPI base runtime instrumentation.
 */
bool havePapi() {
  return std::getenv("POLLI_ENABLE_PAPI") != nullptr;
}

/**
 * @brief Check, if we have likwid support at run-time.
 *
 * @return bool
 */
bool haveLikwid() {
  if (EmitEnv) {
    for (char **current = environ; *current; current++) {
      auto Console = spdlog::stderr_logger_mt("polli/options");
      Console->info(*current);
    }
  }

  return std::getenv("LIKWID_MODE") != nullptr;
}
} // namespace opt
} // namespace polli

using namespace polli;
using namespace polli::opt;

static cl::opt<bool, true> EmitEnvX("polli-emit-env",
                                    cl::desc("Emit environment."),
                                    cl::location(EmitEnv), cl::init(false),
                                    cl::cat(PolliCategory));

static cl::opt<bool, true>
    InstrumentRegionsX("instrument", cl::desc("Enable instrumenting of SCoPs"),
                       cl::location(InstrumentRegions), cl::init(false),
                       cl::cat(PolliCategory));

static cl::opt<bool, true> EnableJitableX("jitable",
                                          cl::desc("Enable JIT extensions."),
                                          cl::location(EnableJitable),
                                          cl::init(false),
                                          cl::cat(PolliCategory));

static cl::opt<bool, true> DisablePreoptX(
    "disable-preopt", cl::desc("Disable polly's canonicalization"),
    cl::location(DisablePreopt), cl::init(false), cl::cat(PolliCategory));

static cl::opt<bool, true> DisableRecompileX(
    "no-recompilation", cl::desc("Disable recompilation of SCoPs"),
    cl::location(DisableRecompile), cl::init(false), cl::cat(PolliCategory));

static cl::opt<bool, true> DisableExecutionX(
    "no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::location(DisableExecution), cl::init(false), cl::cat(PolliCategory));

static cl::opt<bool, true> AnalyzeIRX(
    "polli-analyze", cl::desc("Throw in a bunch of function printers for "
                              "PolyJIT's static compilation passes."),
    cl::location(AnalyzeIR), cl::init(false), cl::cat(PolliCategory));

static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::location(GenerateOutput), cl::init(false), cl::cat(PolliCategory));

static cl::opt<polli::LogType, true>
    LogLevelX("polli-log-level", cl::desc("Log level for output messages"),
              cl::values(clEnumVal(polli::Trace, "all messages"),
                         clEnumVal(polli::Debug, "up to debug messages"),
                         clEnumVal(polli::Info, "up to info messages"),
                         clEnumVal(polli::Notice, "up to notice messages"),
                         clEnumVal(polli::Warn, "up to warn messages"),
                         clEnumVal(polli::Err, "up to error messages"),
                         clEnumVal(polli::Critical, "up to critical messages"),
                         clEnumVal(polli::Alert, "up to alert messages"),
                         clEnumVal(polli::Emerg, "up to emergency messages"),
                         clEnumVal(polli::Off, "silence"), clEnumValEnd),
              cl::location(LogLevel), cl::init(polli::Warn),
              cl::cat(PolliCategory));

static cl::opt<std::string, true>
    ReportFilenameX("polli-report-file",
                    cl::desc("Name of the report file to generate."),
                    cl::location(ReportFilename), cl::init("polli.report"),
                    cl::cat(PolliCategory));

static cl::list<std::string, std::vector<std::string>>
    LibPathsX("L", cl::Prefix, cl::desc("Specify a library search path"),
              cl::value_desc("directory"), cl::ZeroOrMore,
              cl::location(LibPaths), cl::cat(PolliCategory));

static cl::list<std::string, std::vector<std::string>>
    LibrariesX("l", cl::Prefix, cl::desc("Specify libraries to link to"),
               cl::value_desc("library prefix"), cl::ZeroOrMore,
               cl::location(Libraries), cl::cat(PolliCategory));

static cl::opt<std::string, true>
    InputFileX(cl::desc("<input bitcode>"), cl::Positional,
               cl::location(InputFile), cl::init("-"), cl::cat(PolliCategory));

static cl::list<std::string, std::vector<std::string>>
    InputArgvX(cl::ConsumeAfter, cl::desc("<program arguments>..."),
               cl::location(InputArgv), cl::cat(PolliCategory));

static cl::opt<std::string, true>
    EntryFuncX("entry-function",
               cl::desc("Specify the entry function (default = 'main') "
                        "of the executable"),
               cl::value_desc("function"), cl::location(EntryFunc),
               cl::init("main"), cl::cat(PolliCategory));

static cl::opt<std::string, true>
    FakeArgv0X("fake-argv0",
               cl::desc("Override the 'argv[0]' value passed into the executing"
                        " program"),
               cl::value_desc("executable"), cl::location(FakeArgv0),
               cl::cat(PolliCategory));

static cl::opt<bool, true>
    DisableCoreFilesX("disable-core-files", cl::Hidden,
                      cl::desc("Disable emission of core files if possible"),
                      cl::location(DisableCoreFiles));

static cl::opt<bool, true>
    PolliEnabledX("polli", cl::desc("Enable the polli JIT compiler"),
                  cl::ZeroOrMore, cl::location(polli::opt::Enabled),
                  cl::init(false), cl::cat(PolliCategory));
