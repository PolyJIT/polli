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

using namespace llvm;

llvm::cl::OptionCategory
    PolliCategory("Polli Options", "Configure the runtime options of polli");

namespace polli {
namespace opt {
bool InstrumentRegions;
bool EnableJitable;
bool DisableRecompile;
bool DisableExecution;

std::vector<std::string> LibPaths;
std::vector<std::string> Libraries;
std::string InputFile;
std::vector<std::string> InputArgv;
std::string EntryFunc;
std::string FakeArgv0;
bool DisableCoreFiles;
bool AnalyzeIR;
char OptLevel;
std::string OutputFilename;
std::string TargetTriple;
std::string MArch;
std::string MCPU;
std::vector<std::string> MAttrs;
llvm::Reloc::Model RelocModel;
llvm::CodeModel::Model CModel;
bool EnableJITExceptionHandling;
bool GenerateSoftFloatCalls;
llvm::FloatABI::ABIType FloatABIForCalls;
bool EmitJitDebugInfo;
bool EmitJitDebugInfoToDisk;
bool AnalyseOnly;
std::string ReportFilename;
bool DisablePreopt;
bool GenerateOutput;
LogType LogLevel;
bool Enabled;
}
}

using namespace polli;
using namespace polli::opt;
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

static cl::opt<char, true>
    OptLevelX("O", cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
                            "(default = '-O2')"),
              cl::Prefix, cl::ZeroOrMore, cl::location(OptLevel),
              cl::init(' '));

static cl::opt<std::string, true>
    OutputFilenameX("o", cl::desc("Override output filename"),
                    cl::value_desc("filename"), cl::location(OutputFilename));

static cl::opt<std::string, true>
    TargetTripleX("mtriple", cl::desc("Override target triple for module"),
                  cl::location(TargetTriple));

static cl::opt<std::string, true>
    MArchX("march",
           cl::desc("Architecture to generate assembly for (see --version)"),
           cl::location(MArch));

static cl::opt<std::string, true>
    MCPUX("mcpu",
          cl::desc("Target a specific cpu type (-mcpu=help for details)"),
          cl::location(MCPU), cl::value_desc("cpu-name"), cl::init(""));

static cl::list<std::string, std::vector<std::string>>
    MAttrsX("mattr", cl::CommaSeparated,
            cl::desc("Target specific attributes (-mattr=help for details)"),
            cl::value_desc("a1,+a2,-a3,..."), cl::location(MAttrs));

static cl::opt<Reloc::Model, true> RelocModelX(
    "relocation-model", cl::desc("Choose relocation model"),
    cl::location(RelocModel), cl::init(Reloc::Default),
    cl::values(
        clEnumValN(Reloc::Default, "default",
                   "Target default relocation model"),
        clEnumValN(Reloc::Static, "static", "Non-relocatable code"),
        clEnumValN(Reloc::PIC_, "pic",
                   "Fully relocatable, position independent code"),
        clEnumValN(Reloc::DynamicNoPIC, "dynamic-no-pic",
                   "Relocatable external references, non-relocatable code"),
        clEnumValEnd));

static cl::opt<llvm::CodeModel::Model, true> CModelX(
    "code-model", cl::desc("Choose code model"), cl::location(CModel),
    cl::init(CodeModel::JITDefault),
    cl::values(clEnumValN(CodeModel::JITDefault, "default",
                          "Target default JIT code model"),
               clEnumValN(CodeModel::Small, "small", "Small code model"),
               clEnumValN(CodeModel::Kernel, "kernel", "Kernel code model"),
               clEnumValN(CodeModel::Medium, "medium", "Medium code model"),
               clEnumValN(CodeModel::Large, "large", "Large code model"),
               clEnumValEnd));

static cl::opt<bool, true> EnableJITExceptionHandlingX(
    "jit-enable-eh", cl::desc("Emit exception handling information"),
    cl::location(EnableJITExceptionHandling), cl::init(false));

static cl::opt<bool, true> GenerateSoftFloatCallsX(
    "soft-float", cl::desc("Generate software floating point library calls"),
    cl::location(GenerateSoftFloatCalls), cl::init(false));

static cl::opt<llvm::FloatABI::ABIType, true> FloatABIForCallsX(
    "float-abi", cl::desc("Choose float ABI type"),
    cl::location(FloatABIForCalls), cl::init(FloatABI::Default),
    cl::values(clEnumValN(FloatABI::Default, "default",
                          "Target default float ABI type"),
               clEnumValN(FloatABI::Soft, "soft",
                          "Soft float ABI (implied by -soft-float)"),
               clEnumValN(FloatABI::Hard, "hard",
                          "Hard float ABI (uses FP registers)"),
               clEnumValEnd));

static cl::opt<bool, true>
// In debug builds, make this default to true.
#ifdef NDEBUG
#define EMIT_DEBUG false
#else
#define EMIT_DEBUG true
#endif
    EmitJitDebugInfoX("jit-emit-debug",
                      cl::desc("Emit debug information to debugger"),
                      cl::location(EmitJitDebugInfo), cl::init(EMIT_DEBUG));
#undef EMIT_DEBUG

static cl::opt<bool, true>
    EmitJitDebugInfoToDiskX("jit-emit-debug-to-disk", cl::Hidden,
                            cl::desc("Emit debug info objfiles to disk"),
                            cl::location(EmitJitDebugInfoToDisk),
                            cl::init(false));

static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::location(GenerateOutput), cl::init(false), cl::cat(PolliCategory));

static cl::opt<polli::LogType, true>
    LogLevelX("polli-log-level", cl::desc("Log level for output messages"),
              cl::values(clEnumVal(Info, "Info messages (very spammy!)"),
                         clEnumVal(Debug, "Up to debug messages"),
                         clEnumVal(Warning, "Up to warning messages"),
                         clEnumVal(Error, "Error messages only"), clEnumValEnd),
              cl::location(LogLevel), cl::cat(PolliCategory));

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
