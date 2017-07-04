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

#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

#include <string>
#include <vector>

extern llvm::cl::OptionCategory PolliCategory;
extern llvm::cl::OptionCategory PolyJIT_Runtime;
extern llvm::cl::OptionCategory PolyJIT_Compiletime;

namespace polli {
namespace opt {
extern bool DisableRecompile;
extern bool DisableCoreFiles;
extern std::string EntryFunc;
extern std::string FakeArgv0;

namespace runtime {
extern char OptLevel;
extern std::string TargetTriple;
extern std::string MArch;
extern std::string MCPU;
extern std::vector<std::string> MAttrs;

extern bool DisableExecution;
extern bool DisableSpecialization;
extern bool EnablePapi;
extern bool GenerateOutput;
}

namespace compiletime {
extern bool Enabled;
extern bool InstrumentRegions;
extern bool AnalyzeIR;
extern bool CollectRegressionTests;
}

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
}
}
#endif
