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

#include <string>
#include <vector>
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

extern llvm::cl::OptionCategory PolliCategory;

namespace polli {

namespace opt {
extern std::string EntryFunc;
extern std::string FakeArgv0;

extern bool DisableCoreFiles;

extern bool InstrumentRegions;
extern bool EnableJitable;
extern bool DisableRecompile;
extern bool DisableExecution;
extern bool DisableSpecialization;
extern bool AnalyzeIR;
extern char OptLevel;
extern bool CollectRegressionTests;

extern std::string TargetTriple;
extern std::string MArch;
extern std::string MCPU;
extern std::vector<std::string> MAttrs;

extern bool GenerateSoftFloatCalls;

extern bool AnalyseOnly;
extern std::string ReportFilename;

extern bool DisablePreopt;
extern bool GenerateOutput;

/**
 * @brief Should PolyJIT be enabled?
 *
 * This pushes PolyJIT's static passes into the compilation pipeline.
 */
extern bool Enabled;

/**
 * @brief Check, if we're wrapped in a likwid binary, e.g., likwid-perfctr.
 *
 * @return bool
 */
bool haveLikwid();

/**
 * @brief Check, if we should perform PAPI based runtime instrumentation.
 *
 * @return True, if we should enable PAPI base runtime instrumentation.
 */
bool havePapi();

void loadOptionsFromEnv();

/**
 * Get the number of OpenMP-Threads available to us.
 */
uint64_t getNumThreads();
}
}
#endif
