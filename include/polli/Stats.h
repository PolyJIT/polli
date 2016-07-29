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

#include "llvm/IR/Function.h"
#include "llvm/ADT/Twine.h"
#include <stdint.h>

namespace llvm {
class Value;
}

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

void TrackStatsChange(const llvm::Function *F, const Stats &S);
} // namespace polli
#endif /* end of include guard: POLLI_STATS_H */
