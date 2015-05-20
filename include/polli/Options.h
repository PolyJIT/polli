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

#include "llvm/Support/CommandLine.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Target/TargetOptions.h"

#include <string>

extern llvm::cl::OptionCategory PolliCategory;

namespace polli {

/**
 * @brief Initialize spdlog with default values.
 *
 * @return void
 */
void setupLogging();

enum LogType {
  Trace,
  Debug,
  Info,
  Notice,
  Warn,
  Err,
  Critical,
  Alert,
  Emerg,
  Off
};

namespace opt {
extern std::vector<std::string> LibPaths;
extern std::vector<std::string> Libraries;

extern std::string InputFile;
extern std::vector<std::string> InputArgv;

extern std::string EntryFunc;
extern std::string FakeArgv0;

extern bool DisableCoreFiles;

extern bool InstrumentRegions;
extern bool EnableJitable;
extern bool DisableRecompile;
extern bool DisableExecution;
extern bool AnalyzeIR;
extern char OptLevel;

extern std::string TargetTriple;
extern std::string MArch;
extern std::string MCPU;
extern std::vector<std::string> MAttrs;

extern llvm::Reloc::Model RelocModel;
extern llvm::CodeModel::Model CModel;

extern bool EnableJITExceptionHandling;
extern bool GenerateSoftFloatCalls;

extern llvm::FloatABI::ABIType FloatABIForCalls;

extern bool EmitJitDebugInfo;
extern bool EmitJitDebugInfoToDisk;

extern bool AnalyseOnly;
extern std::string ReportFilename;

extern bool DisablePreopt;
extern bool GenerateOutput;

/**
 * @brief What logs should be visible to the user.
 *
 * Default is 'warn'
 */
extern polli::LogType LogLevel;

/**
 * @brief Should PolyJIT be enabled?
 *
 * This pushes PolyJIT's static passes into the compilation pipeline.
 */
extern bool Enabled;
}
}
#endif
