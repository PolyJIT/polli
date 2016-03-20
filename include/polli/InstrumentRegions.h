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
#ifndef POLLI_INSTRUMENT_REGIONS_H
#define POLLI_INSTRUMENT_REGIONS_H

#include "llvm/Pass.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/LoopInfo.h"

#include "polli/ScopDetection.h"
#include "polly/Support/ScopHelper.h"

namespace llvm {
class Value;
class Instruction;
class GlobalVariable;
class GlobalValue;
class LoopInfo;
class PointerType;
class RegionInfo;
class Region;
}

typedef SmallVector<std::pair<Instruction *, Instruction *>, 8> TimerPairs;

namespace polli {
class JITScopDetection;

/**
 * @brief Initialize PAPI CSCoP profiling
 */
class PapiCScopProfilingInit : public ModulePass {
public:
  explicit PapiCScopProfilingInit() : ModulePass(ID) {};

  /**
   * @name ModulePass interface
   * @{ */
  static char ID;
  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }

  virtual bool runOnModule(Module &M);
  /**  @} */
};

/**
 * @brief Instrument SCoPs for PAPI profiling
 */
class PapiCScopProfiling : public FunctionPass {
public:
  explicit PapiCScopProfiling() : FunctionPass(ID) {}

  /**
   * @name FunctionPass interface
   * @{ */
  static char ID;

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<polli::JITScopDetection>();
    AU.addRequired<RegionInfoPass>();
  }

  virtual bool runOnFunction(Function &);
  /**  @} */

private:
  JITScopDetection *SD;
  RegionInfoPass *RI;

  bool processRegion(const Region *R);

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
  void instrumentRegion(Module *M, std::vector<BasicBlock *> &EntryBBs,
                        std::vector<BasicBlock *> &ExitBBs, const Region *R,
                        std::string entryName, std::string exitName);

  /**
   * @brief Print analysis information. Empty.
   *
   * @param
   * @param
   */
  void print(raw_ostream &, const Module *) const {}
};
}

namespace llvm {
class PassRegistry;
void initializePapiCScopProfilingPass(llvm::PassRegistry &);
void initializePapiCScopProfilingInitPass(llvm::PassRegistry &);
}
#endif // POLLI_INSTRUMENT_REGIONS_H

