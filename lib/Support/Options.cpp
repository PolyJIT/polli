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
bool DisableRecompile;
static cl::opt<bool, true> DisableRecompileX(
    "no-recompilation", cl::desc("Disable recompilation of SCoPs"),
    cl::location(DisableRecompile), cl::init(false), cl::cat(PolliCategory));

bool DisableCoreFiles = true;
static cl::opt<bool, true>
    DisableCoreFilesX("disable-core-files", cl::Hidden,
                      cl::desc("Disable emission of core files if possible"),
                      cl::location(DisableCoreFiles), cl::init(false),
                      cl::cat(PolliCategory));

namespace runtime {

char OptLevel = ' ';
std::string MArch = "";
std::string MCPU = "";
std::vector<std::string> MAttrs;
std::string TargetTriple = "x86-64_unknown-linux-gnu";

bool DisableExecution;
static cl::opt<bool, true> DisableExecutionX(
    "pjit-no-execution",
    cl::desc("Disable execution just produce all intermediate files"),
    cl::location(DisableExecution), cl::init(false), cl::cat(PolyJIT_Runtime));

bool DisableSpecialization;
static cl::opt<bool, true>
    DisableSpecializationX("pjit-no-specialization",
                           cl::desc("Disable specialziation"),
                           cl::location(DisableSpecialization), cl::init(false),
                           cl::cat(PolyJIT_Runtime));

bool GenerateOutput;
static cl::opt<bool, true> GenerateOutputX(
    "polli-debug-ir",
    cl::desc("Store all IR files inside a unique subdirectory."),
    cl::location(GenerateOutput), cl::init(false), cl::cat(PolyJIT_Runtime));

bool EnablePapi;
static cl::opt<bool, true> EnablePapiX(
    "pjit-enable-papi",
    cl::desc("Enable PAPI tracing"),
    cl::location(EnablePapi), cl::init(false), cl::cat(PolyJIT_Runtime));
} // namespace runtime

namespace compiletime {

bool InstrumentRegions;
static cl::opt<bool, true>
    InstrumentRegionsX("instrument", cl::desc("Enable instrumenting of SCoPs"),
                       cl::location(InstrumentRegions), cl::init(false),
                       cl::cat(PolyJIT_Compiletime));

bool AnalyzeIR;
static cl::opt<bool, true>
    AnalyzeIRX("polli-analyze",
               cl::desc("Throw in a bunch of function printers for "
                        "PolyJIT's static compilation passes."),
               cl::location(AnalyzeIR), cl::init(false),
               cl::cat(PolyJIT_Compiletime));

bool CollectRegressionTests = false;
static cl::opt<bool, true> PolliCollectX(
    "polli-collect-modules",
    cl::desc("Collect Modules in the database for regression testing."),
    cl::ZeroOrMore, cl::location(CollectRegressionTests),
    cl::init(false), cl::cat(PolyJIT_Compiletime));

bool Enabled;
static cl::opt<bool, true> EnabledX(
    "polli",
    cl::desc("Enable PolyJIT"),
    cl::location(Enabled), cl::init(false), cl::cat(PolyJIT_Compiletime));

} // namespace compiletime

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