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

llvm::cl::OptionCategory
    PolliCategory("Polli Options", "Configure the runtime options of polli");

namespace polli {
namespace opt {

std::vector<std::string> LibPaths;
std::vector<std::string> Libraries;
std::string InputFile;
std::vector<std::string> InputArgv;
std::string EntryFunc;
std::string FakeArgv0;
bool DisableCoreFiles;
bool InstrumentRegions;
bool EnableCaddy;
bool EnableJitable;
bool DisableRecompile;
bool DisableExecution;
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
}
}

using namespace llvm;
static cl::opt<bool, true> EnableCaddyX(
    "caddy", cl::desc("Enable Caddy. Requires the 'caddy' branch of polly."),
    cl::init(false), cl::cat(PolliCategory),
    cl::location(polli::opt::EnableCaddy));

static cl::opt<bool, true>
    InstrumentRegionsX("instrument", cl::desc("Enable instrumenting of SCoPs"),
                       cl::init(false), cl::cat(PolliCategory),
                       cl::location(polli::opt::InstrumentRegions));

static cl::opt<bool, true> EnableJitableX("jitable",
                                    cl::desc("Enable JIT extensions."),
                                    cl::init(false), cl::cat(PolliCategory),
                                    cl::location(polli::opt::EnableJitable));

static cl::opt<bool, true>
    DisablePreoptX("disable-preopt",
                   cl::desc("Disable polly's canonicalization"),
                   cl::init(false), cl::cat(PolliCategory),
                   cl::location(polli::opt::DisablePreopt));

static cl::opt<bool, true>
    DisableRecompileX("no-recompilation",
                      cl::desc("Disable recompilation of SCoPs"),
                      cl::init(false), cl::cat(PolliCategory),
                      cl::location(polli::opt::DisableRecompile));

static cl::opt<bool, true> DisableExecutionX(
    "no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::init(false), cl::cat(PolliCategory),
    cl::location(polli::opt::DisableExecution));

static cl::opt<bool, true> AnalyzeIRX(
    "polli-analyze",
    cl::desc("Only analyze the IR. This disables recompilation & execution."),
    cl::init(false), cl::cat(PolliCategory),
    cl::location(polli::opt::AnalyzeIR));

static cl::opt<char, true>
    OptLevelX("O", cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
                            "(default = '-O2')"),
              cl::Prefix, cl::ZeroOrMore, cl::init(' '),
              cl::location(polli::opt::OptLevel));

static cl::opt<std::string, true>
    OutputFilenameX("o", cl::desc("Override output filename"),
                    cl::value_desc("filename"),
                    cl::location(polli::opt::OutputFilename));

static cl::opt<std::string, true>
    TargetTripleX("mtriple", cl::desc("Override target triple for module"),
                  cl::location(polli::opt::TargetTriple));

static cl::opt<std::string, true>
    MArchX("march",
           cl::desc("Architecture to generate assembly for (see --version)"),
           cl::location(polli::opt::MArch));

static cl::opt<std::string, true> MCPUX(
    "mcpu", cl::desc("Target a specific cpu type (-mcpu=help for details)"),
    cl::value_desc("cpu-name"), cl::init(""), cl::location(polli::opt::MCPU));

static cl::list<std::string, std::vector<std::string>>
    MAttrsX("mattr", cl::CommaSeparated,
            cl::desc("Target specific attributes (-mattr=help for details)"),
            cl::value_desc("a1,+a2,-a3,..."), cl::location(polli::opt::MAttrs));

static cl::opt<Reloc::Model, true> RelocModelX(
    "relocation-model", cl::desc("Choose relocation model"),
    cl::init(Reloc::Default),
    cl::values(
        clEnumValN(Reloc::Default, "default",
                   "Target default relocation model"),
        clEnumValN(Reloc::Static, "static", "Non-relocatable code"),
        clEnumValN(Reloc::PIC_, "pic",
                   "Fully relocatable, position independent code"),
        clEnumValN(Reloc::DynamicNoPIC, "dynamic-no-pic",
                   "Relocatable external references, non-relocatable code"),
        clEnumValEnd),
    cl::location(polli::opt::RelocModel));

static cl::opt<llvm::CodeModel::Model, true> CModelX(
    "code-model", cl::desc("Choose code model"),
    cl::init(CodeModel::JITDefault),
    cl::values(clEnumValN(CodeModel::JITDefault, "default",
                          "Target default JIT code model"),
               clEnumValN(CodeModel::Small, "small", "Small code model"),
               clEnumValN(CodeModel::Kernel, "kernel", "Kernel code model"),
               clEnumValN(CodeModel::Medium, "medium", "Medium code model"),
               clEnumValN(CodeModel::Large, "large", "Large code model"),
               clEnumValEnd),
    cl::location(polli::opt::CModel));

static cl::opt<bool, true> EnableJITExceptionHandlingX(
    "jit-enable-eh", cl::desc("Emit exception handling information"),
    cl::init(false), cl::location(polli::opt::EnableJITExceptionHandling));

static cl::opt<bool, true> GenerateSoftFloatCallsX(
    "soft-float", cl::desc("Generate software floating point library calls"),
    cl::init(false), cl::location(polli::opt::GenerateSoftFloatCalls));

static cl::opt<llvm::FloatABI::ABIType, true> FloatABIForCallsX(
    "float-abi", cl::desc("Choose float ABI type"), cl::init(FloatABI::Default),
    cl::values(clEnumValN(FloatABI::Default, "default",
                          "Target default float ABI type"),
               clEnumValN(FloatABI::Soft, "soft",
                          "Soft float ABI (implied by -soft-float)"),
               clEnumValN(FloatABI::Hard, "hard",
                          "Hard float ABI (uses FP registers)"),
               clEnumValEnd),
    cl::location(polli::opt::FloatABIForCalls));

static cl::opt<bool, true>
// In debug builds, make this default to true.
#ifdef NDEBUG
#define EMIT_DEBUG false
#else
#define EMIT_DEBUG true
#endif
    EmitJitDebugInfoX("jit-emit-debug",
                      cl::desc("Emit debug information to debugger"),
                      cl::init(EMIT_DEBUG),
                      cl::location(polli::opt::EmitJitDebugInfo));
#undef EMIT_DEBUG

static cl::opt<bool, true>
    EmitJitDebugInfoToDiskX("jit-emit-debug-to-disk", cl::Hidden,
                            cl::desc("Emit debug info objfiles to disk"),
                            cl::init(false),
                            cl::location(polli::opt::EmitJitDebugInfoToDisk));

static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::init(false), cl::location(polli::opt::GenerateOutput));

static cl::opt<polli::LogType, true> LogLevelX(
    "polli-log-level", cl::desc("Log level for output messages"),
    cl::values(clEnumVal(polli::Info, "Info messages (very spammy!)"),
               clEnumVal(polli::Debug, "Up to debug messages"),
               clEnumVal(polli::Warning, "Up to warning messages"),
               clEnumVal(polli::Error, "Error messages only"), clEnumValEnd),
    cl::location(polli::opt::LogLevel));

static cl::opt<std::string, true> ReportFilenameX(
    "polli-report-file", cl::desc("Name of the report file to generate."),
    cl::init("polli.report"), cl::location(polli::opt::ReportFilename));

