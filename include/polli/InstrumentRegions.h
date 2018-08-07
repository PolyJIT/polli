//===- InstrumentRegions.cpp - Instrument Regions PAPI ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This takes a region and instruments the Entry and Exit blocks with calls
// to the PAPI library.
//
// The initial implementation only instruments the region with timing calls
// to measure the runtime that was spent inside the region.
//
// We need to make sure that the instrumentation is placed one a single entry
// edge and a single exit edge. Therefore, it is necessary to transform the
// regions before we perform any instrumentation.
//===----------------------------------------------------------------------===//
#ifndef POLLI_INSTRUMENTREGIONS_H
#define POLLI_INSTRUMENTREGIONS_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"

#include "polly/Support/ScopHelper.h"

namespace llvm {
class Instruction;
class GlobalVariable;
class GlobalValue;
class LoopInfo;
class PointerType;
class Region;
class RegionInfo;
class Value;
} // namespace llvm

using TimerPairs =
    llvm::SmallVector<std::pair<llvm::Instruction *, llvm::Instruction *>, 8>;

namespace polli {
class JITScopDetection;

/**
 * @brief Initialize PAPI CSCoP profiling
 */
class PapiCScopProfilingInit : public llvm::ModulePass {
public:
  explicit PapiCScopProfilingInit() : llvm::ModulePass(ID) {};

  /**
   * @name ModulePass interface
   * @{ */
  static char ID;
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  virtual bool runOnModule(llvm::Module &M);
  /**  @} */
};

/**
 * @brief Instrument SCoPs for PAPI profiling
 */
class PapiCScopProfiling : public llvm::FunctionPass {
public:
  explicit PapiCScopProfiling() : llvm::FunctionPass(ID) {}

  /**
   * @name FunctionPass interface
   * @{ */
  static char ID;

  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  virtual bool runOnFunction(llvm::Function &);
  /**  @} */

private:
  JITScopDetection *SD;
  llvm::RegionInfoPass *RI;

  bool processRegion(const llvm::Region *R);

  /**
   * @brief Instrument a region for papi profiling
   *
   * @param M Module the instrumented region is in.
   * @param EntryBBs the entry BBs to this region
   * @param ExitBBs the exit BBs of this region
   * @param R the region we want to instrument
   * @param entryName name of our region entry
   * @param exitName name of our region exit
   */
  void instrumentRegion(llvm::Module *M,
                        std::vector<llvm::BasicBlock *> &EntryBBs,
                        std::vector<llvm::BasicBlock *> &ExitBBs,
                        const llvm::Region *R, const std::string& EntryName,
                        const std::string& ExitName);

  /**
   * @brief Print analysis information. Empty.
   *
   * @param
   * @param
   */
  void print(llvm::raw_ostream &, const llvm::Module *) const {}
};
} // namespace polli

namespace llvm {
class PassRegistry;
void initializePapiCScopProfilingPass(llvm::PassRegistry &);
void initializePapiCScopProfilingInitPass(llvm::PassRegistry &);
} // namespace llvm
#endif // POLLI_INSTRUMENTREGIONS_H

