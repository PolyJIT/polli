//===-- RegisterCompilationPasses.cpp - LLVM Just in Time Compiler --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Register the compilation sequence required for the PolyJIT runtime support.
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "polli/Options.h"
#include "polli/JitScopDetection.h"
#include "polli/ScopMapper.h"

using namespace llvm;

static cl::opt<bool>
PolliEnabled("polli", cl::desc("Enable the polli JIT compiler"),
             cl::init(false), cl::ZeroOrMore, cl::cat(PolliCategory));

namespace polli {
static void registerPolli(const llvm::PassManagerBuilder &Builder,
                          llvm::legacy::PassManagerBase &PM) {
  if (!PolliEnabled)
    return;

  PM.add(new JitScopDetection(opt::EnableJitable));
  PM.add(new ScopMapper());
  // PM.add(new ModuleExtractor())
}

static llvm::RegisterStandardPasses
    RegisterPolliInstrumentation(llvm::PassManagerBuilder::EP_LoopOptimizerEnd,
                                 registerPolli);
}
