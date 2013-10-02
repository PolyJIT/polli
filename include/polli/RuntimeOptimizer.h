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

#include "llvm/IR/Function.h"

using namespace llvm;

namespace polli {
/// @brief RuntimeOptimizer provides a small interface to control the
//  optimization of specialized functions at run time.
//
//
class RuntimeOptimizer {
public:
  explicit RuntimeOptimizer() {};

  bool Optimize(Function &F);
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  RuntimeOptimizer(const RuntimeOptimizer &);
  // DO NOT IMPLEMENT
  const RuntimeOptimizer &operator=(const RuntimeOptimizer &);
};
}
#endif // RUNTIMEOPTIMIZER_H
