//===---- RegisterCompilationPasses.h - LLVM Just in Time Compiler --------===//
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
#ifndef POLLI_REGISTER_COMPILATION_PASSES_H
#define POLLI_REGISTER_COMPILATION_PASSES_H

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/PassRegistry.h"

namespace llvm {
namespace legacy {
class PassManagerBase;
}

class PassRegistry;
}

namespace polli {
void registerPolli(llvm::legacy::PassManagerBase &PM);
void initializePolliPasses(llvm::PassRegistry &Registry);
}
#endif
