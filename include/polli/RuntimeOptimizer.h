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
#ifndef POLLI_RUNTIMEOPTIMIZER_H
#define POLLI_RUNTIMEOPTIMIZER_H
#include "polli/Options.h"
#include <memory>

#include "llvm/IR/Module.h"
#include <set>

namespace polli {
using SharedModule = std::shared_ptr<llvm::Module>;
void SetOptimizationPipeline(PipelineType Choice);

// @brief Optimize a function during the runtime of the program.
//
// We only perform relatively 'cheap' optimizations here, to avoid increasing
// the run-time overhead by too much.
//
// @param F The function to optimize
// @return The optimized function.
struct RuntimeOptimizer {
  std::set<SharedModule> &OptimizedModules;
  explicit RuntimeOptimizer(std::set<SharedModule> &ModRef)
      : OptimizedModules(ModRef) {}
  SharedModule operator()(SharedModule M);
};
} // namespace polli
#endif // POLLI_RUNTIMEOPTIMIZER_H
