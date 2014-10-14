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

#include <string>

extern llvm::cl::OptionCategory PolliCategory;

namespace llvm {
/* Polli options */
extern cl::list<std::string> LibPaths;
extern cl::list<std::string> Libraries;
extern cl::opt<std::string> InputFile;
extern cl::list<std::string> InputArgv;
extern cl::opt<std::string> EntryFunc;
extern cl::opt<std::string> FakeArgv0;
extern cl::opt<bool> DisableCoreFiles;

/* PolyJIT options */
extern cl::opt<bool> EnableCaddy;
extern cl::opt<bool> InstrumentRegions;
extern cl::opt<bool> EnableJitable;
extern cl::opt<bool> DisableRecompile;
extern cl::opt<bool> DisableExecution;
extern cl::opt<bool> AnalyzeIR;
extern cl::opt<bool> OptLevel;
extern cl::opt<std::string> OutputFilename;
extern cl::opt<std::string> TargetTriple;
extern cl::opt<std::string> MArch;
extern cl::opt<std::string> MCPU;
extern cl::opt<std::string> MAttrs;
extern cl::opt<llvm::Reloc::Model> RelocModel;
extern cl::opt<llvm::CodeModel::Model> CMModel;
extern cl::opt<bool> EnableJITExceptionHandling;
extern cl::opt<bool> GenerateSoftFloatCalls;
extern cl::opt<llvm::FloatABI::ABIType> FloatABIForCalls;
extern cl::opt<bool> EmitJitDebugInfo;
extern cl::opt<bool> EmitJitDebugInfoToDisk;

/* JIT ScopDetection options */
extern cl::opt<bool> AnalyzeOnly;
}
#endif
