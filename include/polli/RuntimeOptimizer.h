//===-- RuntimeOptimizer.h - JIT function optimizer -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines a small interface to determine the benefits of optimizing
// a given function at run time. If the benefit exceeds a threshold the
// optimization should be executed, e.g. with Polly.
//
//===----------------------------------------------------------------------===//
#ifndef RUNTIMEOPTIMIZER_H
#define RUNTIMEOPTIMIZER_H
#include <memory>
#include "polli/Options.h"

#include "llvm/IR/Function.h"

using namespace llvm;

namespace polli {
void SetOptimizationPipeline(PipelineType Choice);

/// @brief Optimize a function during the runtime of the program.
//
// We only perform relatively 'cheap' optimizations here, to avoid increasing
// the run-time overhead by too much.
//
// @param F The function to optimize
// @return The optimized function.
std::shared_ptr<Module> optimizeForRuntime(std::shared_ptr<Module> M);
}
#endif // RUNTIMEOPTIMIZER_H
