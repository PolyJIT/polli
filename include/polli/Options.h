//===--------------- polli/Options.h - The Polli option category *- C++ -*-===//
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

#ifndef POLLI_OPTIONS_H
#define POLLI_OPTIONS_H

#include "spdlog/spdlog.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

#include <string>
#include <vector>

extern llvm::cl::OptionCategory PolliCategory;
extern llvm::cl::OptionCategory PolyJitRuntime;
extern llvm::cl::OptionCategory PolyJitCompiletime;

namespace polli {
enum PipelineType {
    RELEASE,
    DEBUG
};

namespace opt {
extern bool EnableTracking;
extern std::string TrackMetricsFilename;
extern std::string TrackScopMetadataFilename;
extern bool EnableLogFile;
extern bool DisableRecompile;
extern bool DisableCoreFiles;
extern std::string EntryFunc;
extern std::string FakeArgv0;

extern spdlog::level::level_enum LogLevel;

extern int RunID;

namespace runtime {
extern char OptLevel;
extern std::string TargetTriple;
extern std::string MArch;
extern std::string MCPU;
extern std::vector<std::string> MAttrs;

extern bool DisableExecution;
extern bool DisableSpecialization;
extern bool EnablePapi;
extern bool EnableDatabaseExport;
extern bool GenerateOutput;
extern bool EnableScheduleReport;
extern bool EnableScopReport;
extern bool EnableFunctionReport;
extern bool EnableASTReport;
extern bool UsePollyOptions;
extern bool DisableDelinearization;
extern bool EnablePolly;

extern PipelineType PipelineChoice;
} // namespace runtime

namespace compiletime {
extern bool Enabled;
extern bool InstrumentRegions;
extern bool AnalyzeIR;
extern bool ProfileScops;
extern bool CollectRegressionTests;
} // namespace compiletime


void ValidateOptions();

/**
 * @brief Check, if we're wrapped in a likwid binary, e.g., likwid-perfctr.
 *
 * @return bool
 */
bool haveLikwid();

/**
 * Get the number of OpenMP-Threads available to us.
 */
uint64_t getNumThreads();
} // namespace opt
} // namespace polli
#endif
