//===-- Stats.h - RUNTIME statistics ----------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_STATS_H
#define POLLI_STATS_H

#include "llvm/ADT/Twine.h"
#include "llvm/IR/Function.h"
#include <stdint.h>

namespace llvm {
class Value;
} // namespace llvm

namespace polli {
struct Stats {
  uint64_t NumCalls;
  uint64_t LookupTime;
  uint64_t LastRuntime;
  bool JumpIntoJIT;
  uint64_t RegionEnter;
  uint64_t RegionExit;
};

llvm::Value *registerStatStruct(llvm::Function &F,
                                const llvm::Twine &NameSuffix);

uint64_t GetCandidateId(const llvm::Function &F);
} // namespace polli
#endif // POLLI_STATS_H
