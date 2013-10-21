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
#define DEBUG_TYPE "papi"
#include "llvm/Support/Debug.h"

#include "polli/InstrumentRegions.h"
#include "papi.h"

#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"

#include "polly//ScopDetection.h"
#include "polli/NonAffineScopDetection.h"

#include "llvm/Assembly/Writer.h"

#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/CFG.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"
#include "llvm/IR/IRBuilder.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"

#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

#include <string>
#include <deque>

using namespace llvm;
using namespace polli;
using namespace polly;

STATISTIC(InstrumentedRegions, "Number of instrumented regions");
STATISTIC(NoSingleExit, "Number of regions without single exit edge");
STATISTIC(NoSingleEntry, "Number of regions without single exit edge");

static uint64_t EventID = 0;
static std::vector<uint64_t> IDStack;

static void PapiRegionEnterSCoP(Instruction *InsertBefore, Module *M,
                                std::string dbgStr = "") {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);
  std::vector<Value *> Args(2);
  Constant *PapiScopEnterFn = M->getOrInsertFunction(
      "papi_region_enter_scop", Builder.getVoidTy(), Type::getInt64Ty(Context),
      Builder.getInt8PtrTy(), NULL);

  Builder.SetInsertPoint(InsertBefore);
  Args[0] = ConstantInt::get(Type::getInt64Ty(Context), ++EventID, false);
  Args[1] = Builder.CreateGlobalStringPtr(dbgStr);

  Builder.CreateCall(PapiScopEnterFn, Args);

  IDStack.push_back(EventID);
}

static void PapiRegionExitSCoP(Instruction *InsertBefore, Module *M,
                               std::string dbgStr = "") {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);
  std::vector<Value *> Args(2);
  Constant *PapiScopExitFn = M->getOrInsertFunction(
      "papi_region_exit_scop", Builder.getVoidTy(), Type::getInt64Ty(Context),
      Builder.getInt8PtrTy(), NULL);

  Builder.SetInsertPoint(InsertBefore);
  Args[0] = ConstantInt::get(Type::getInt64Ty(Context), IDStack.back(), false);
  Args[1] = Builder.CreateGlobalStringPtr(dbgStr);

  Builder.CreateCall(PapiScopExitFn, Args);
  IDStack.pop_back();
}

static void PapiRegionEnter(Instruction *InsertBefore, Module *M) {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);

  Constant *PapiScopEnterFn =
      M->getOrInsertFunction("papi_region_enter", Builder.getVoidTy(),
                             Type::getInt64Ty(Context), NULL);
  Builder.SetInsertPoint(InsertBefore);
  Builder.CreateCall(
      PapiScopEnterFn,
      ConstantInt::get(Type::getInt64Ty(Context), ++EventID, false));
  IDStack.push_back(EventID);
}

static void PapiRegionExit(Instruction *InsertBefore, Module *M) {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);

  Constant *PapiScopEnterFn = M->getOrInsertFunction(
      "papi_region_exit", Builder.getVoidTy(), Type::getInt64Ty(Context), NULL);
  Builder.SetInsertPoint(InsertBefore);
  Builder.CreateCall(
      PapiScopEnterFn,
      ConstantInt::get(Type::getInt64Ty(Context), IDStack.back(), false));
  IDStack.pop_back();
}

static void PapiCreateInit(Function *F) {
  LLVMContext &Context = F->getContext();
  Module *M = F->getParent();
  IRBuilder<> Builder(Context);
  Constant *PapiLibInitFn = M->getOrInsertFunction(
      "PAPI_library_init", Builder.getInt32Ty(), Builder.getInt32Ty(), NULL);

  Instruction *Insert = F->getEntryBlock().getFirstInsertionPt();
  Builder.SetInsertPoint(Insert);
  Builder.CreateCall(PapiLibInitFn, Builder.getInt32(PAPI_VER_CURRENT),
                     "papi.lib.init");
}

static void InsertProfilingInitCall(Function *MainFn) {
  LLVMContext &Context = MainFn->getContext();
  Module &M = *MainFn->getParent();

  // Skip over any allocas in the entry block.
  BasicBlock *Entry = MainFn->begin();
  BasicBlock::iterator InsertPos = Entry->begin();
  while (isa<AllocaInst>(InsertPos))
    ++InsertPos;

  Type *ArgVTy = PointerType::getUnqual(Type::getInt8PtrTy(Context));
  Constant *PapiSetup =
      M.getOrInsertFunction("papi_region_setup", Type::getVoidTy(Context),
                            IntegerType::getInt32Ty(Context), ArgVTy, (Type *)0);

  std::vector<Value *> Args(2);
  Args[0] = Constant::getNullValue(Type::getInt32Ty(Context));
  Args[1] = Constant::getNullValue(ArgVTy);

  CallInst *InitCall = CallInst::Create(PapiSetup, Args, "", InsertPos);

  // If argc or argv are not available in main, just pass null values in.
  Function::arg_iterator AI;
  switch (MainFn->arg_size()) {
  default:
  case 2:
    AI = MainFn->arg_begin();
    ++AI;
    if (AI->getType() != ArgVTy) {
      Instruction::CastOps opcode =
          CastInst::getCastOpcode(AI, false, ArgVTy, false);
      InitCall->setArgOperand(
          1, CastInst::Create(opcode, AI, ArgVTy, "argv.cast", InitCall));
    } else {
      InitCall->setArgOperand(1, AI);
    }
  /* FALL THROUGH */
  case 1:
    AI = MainFn->arg_begin();
    // If the program looked at argc, have it look at the return value of the
    // init call instead.
    if (!AI->getType()->isIntegerTy(32)) {
      Instruction::CastOps opcode =
          CastInst::getCastOpcode(AI, true, Type::getInt32Ty(Context), true);
      InitCall->setArgOperand(
          0, CastInst::Create(opcode, AI, Type::getInt32Ty(Context),
                              "argc.cast", InitCall));
    } else
      InitCall->setArgOperand(0, AI);
  case 0:
    break;
  }
}

static bool isValidBB(BasicBlock *Dominator, BasicBlock *BB, LoopInfo *LI,
                      DominatorTree *DT) {
  Loop *L = LI->getLoopFor(BB);
  Loop *DomL = LI->getLoopFor(Dominator);

  if (!DT->dominates(Dominator, BB))
    return false;

  if (L && L->contains(Dominator))
    return true;

  for (pred_iterator PI = pred_begin(BB), E = pred_end(BB); PI != E; ++PI) {
    if (!DomL || DomL != L) {
      if (L && L->contains(*PI))
        return false;
    }
  }

  return true;
}

static BasicBlock *getSafeEntryFor(BasicBlock *Entry, BasicBlock *Exit,
                                   LoopInfo *LI) {
  Loop *L = LI->getLoopFor(Entry);
  Loop *ExitL = LI->getLoopFor(Exit);
  std::vector<BasicBlock *> Preds;
  unsigned totalPreds = 0;

  for (pred_iterator PI = pred_begin(Entry), E = pred_end(Entry); PI != E;
       ++PI) {
    totalPreds++;
    if (!L || !L->contains(*PI) || (L->contains(*PI) && (L == ExitL)))
      Preds.push_back(*PI);
  }

  // Function entry.
  if (Preds.size() == 0)
    return Entry;

  // Unique predecessor not required.
  if (totalPreds == Preds.size())
    return Entry;

  // outs() << "F:" << ":" << Entry->getName() << "->"
  //       << Exit->getName() << "\n";
  assert(Preds.size() == 1 &&
         "More than 1 predecessor outside of this region (-papi-prepare)!");
  if (Preds.size() != 1) {
    DEBUG(dbgs() << "More than 1 predecessor outside of this region (-papi-prepare)!");
    ++NoSingleEntry;
  }

  return Preds[0];
}

static BasicBlock *getSafeExitFor(BasicBlock *Entry, BasicBlock *Exit,
                                  LoopInfo *LI, DominatorTree *DT) {
  if (!Exit)
    return 0;
  if (isValidBB(Entry, Exit, LI, DT))
    return Exit;

  // Check our predecessors, there has to be a valid exit (after papi-prepare).
  std::vector<BasicBlock *> SafeExits;
  for (pred_iterator PI = pred_begin(Exit), E = pred_end(Exit); PI != E; ++PI) {
    if (isValidBB(Entry, (*PI), LI, DT))
      SafeExits.push_back((*PI));
  }

  // Validate our candidates.
  int exits = SafeExits.size();
  if (exits > 1) {
    DEBUG(dbgs() << "Too many exit candidates found.");
    ++NoSingleExit;
  }

  if (exits == 0) {
    DEBUG(dbgs() << "Couldn't find a safe place for a counter.");
    ++NoSingleExit;
  }

  if (!exits)
   return NULL;

  return SafeExits[0];
}

//-----------------------------------------------------------------------------
//
// PapiCScopProfilingInitPasss
//
//-----------------------------------------------------------------------------
bool PapiCScopProfilingInit::runOnModule(Module &M) {
  DEBUG(dbgs() << "PapiCScop $ Initializing module\n");
  Function *Main = M.getFunction("main");
  if (Main == 0) {
    errs() << "WARNING: cannot insert papi profiling into a module"
           << " with no main function!\n";
    return false; // No main, no instrumentation!
  }

  // Just place our atexit call and initialize papi library calls.
  InsertProfilingInitCall(Main);
  PapiCreateInit(Main);

  return false;
}

//-----------------------------------------------------------------------------
//
// PapiCScopProfilingPass
//
//-----------------------------------------------------------------------------
bool PapiCScopProfiling::runOnScop(CScop &S) {
  DEBUG(dbgs() << "PapiCScop $ CScop: " << S.getRegion().getNameStr() << "\n");
  LI = &getAnalysis<LoopInfo>();
  DT = &getAnalysis<DominatorTree>();

  const Region &R = S.getRegion();
  BasicBlock *Entry, *Exit;

  /* Use the curent Region-Exit, we will chose an appropriate place
   * for a PAPI counter later. */
  if ((Entry = getSafeEntryFor(R.getEntry(), R.getExit(), LI)) &&
      (Exit = getSafeExitFor(Entry, R.getExit(), LI, DT))) {
    Module *M = R.getEntry()->getParent()->getParent();
    instrumentRegion(M, *Entry, *Exit);
    DEBUG(dbgs() << "PapiCScop $ Entry: " << Entry->getName()
                 << " Exit: " << Exit->getName() << "\n");
  }
  return false;
}

void PapiCScopProfiling::print(raw_ostream &OS, const Module *M) const {}

void PapiCScopProfiling::instrumentRegion(Module *M, BasicBlock &Entry,
                                          BasicBlock &Exit) {
  // The first entry is always(!) the region we want to time.
  // All following edges are subregions and have to be treated
  // like function calls.
  BasicBlock::iterator InsertPos = Entry.getFirstNonPHIOrDbgOrLifetime();

  // Adjust insertion point for landing pads / allocas
  if (Entry.isLandingPad())
    ++InsertPos;
  while (isa<AllocaInst>(InsertPos))
    ++InsertPos;

  Function *F = Entry.getParent();
  std::string name = F->getName().str() + "::" + Entry.getName().str();
  PapiRegionEnterSCoP(InsertPos, M, name);

  /* Preserve the correct order for stack tracing.
   * This will make us "sneak" past a previously entered
   * call to ExitSCoP.*/
  while (isa<CallInst>(InsertPos))
    ++InsertPos;

  name = F->getName().str() + "::" + Exit.getName().str();
  InsertPos = Exit.getFirstNonPHIOrDbgOrLifetime();
  PapiRegionExitSCoP(InsertPos, M, name);

  ++InstrumentedRegions;
}

//-----------------------------------------------------------------------------
//
// PapiRegionProfilingPass
//
//-----------------------------------------------------------------------------

// Scan the available regions for profiling and track insert positions.
bool PapiRegionProfiling::runOnFunction(Function &F) {
  RI = &getAnalysis<RegionInfo>();
  LI = &getAnalysis<LoopInfo>();
  JSD = &getAnalysis<NonAffineScopDetection>();
  DT = &getAnalysis<DominatorTree>();

  if (!JSD->size())
    return false;

  Region *TopLevel = RI->getTopLevelRegion(), *Next;
  std::deque<Region *> ToVisit;
  bool isScop;
  Edge tmp;
  AnnotatedEdge p;
  BasicBlock *Entry, *Exit;
  SubRegions EEs;

  ToVisit.push_back(TopLevel);
  while (!ToVisit.empty()) {
    Next = ToVisit.front();
    ToVisit.pop_front();
    EEs.clear();

    /* Use the curent Region-Exit, we will chose an appropriate place
     * for a PAPI counter later. */
    Entry = getSafeEntryFor(Next->getEntry(), Next->getExit(), LI);
    Exit = getSafeExitFor(Entry, Next->getExit(), LI, DT);

    tmp = std::make_pair(Entry, Exit);
    isScop = JSD->count(Next) != 0;

    if (isScop || ((F.getName() == "main") && Next->isTopLevelRegion())) {
      p = std::make_pair(tmp, isScop);
      EEs.push_back(p);
      InstrumentedRegions++;
      BlocksToInstrument.push_back(EEs);
    }

    for (auto &elem : *Next)
      ToVisit.push_back(elem);
  }

  return true;
}

bool PapiRegionProfiling::doFinalization(Module &M) {
  int toInstrument = 0;
  LLVMContext &Context = M.getContext();

  Function *Main = M.getFunction("main");
  if (Main == 0) {
    errs() << "WARNING: cannot insert papi profiling into a module"
           << " with no main function!\n";
    return false; // No main, no instrumentation!
  }

  // Calculate needed array space
  toInstrument = BlocksToInstrument.size();

  // Create a global array to hold the results.
  Type *ATy = ArrayType::get(Type::getInt64Ty(Context), toInstrument);
  GlobalVariable *Counters =
      new GlobalVariable(M, ATy, false, GlobalValue::InternalLinkage,
                         Constant::getNullValue(ATy), "PapiRegionProfTime");

  // Place the necessary PAPI calls.
  for (unsigned i = 0; i < BlocksToInstrument.size(); ++i)
    instrumentRegion(i, &M, BlocksToInstrument.at(i), Counters);

  InsertProfilingInitCall(Main);
  PapiCreateInit(Main);

  return true;
}

void PapiRegionProfiling::instrumentRegion(unsigned idx, Module *M,
                                           SubRegions Edges,
                                           GlobalValue *Array) {
  LLVMContext &Context = M->getContext();
  std::vector<Constant *> Indices(2);

  // The first entry is always(!) the region we want to time.
  // All following edges are subregions and have to be treated
  // like function calls.
  AnnotatedEdge AnEdge = Edges[0];
  Edge R = AnEdge.first;
  BasicBlock *BB = R.first;
  BB->getTerminator();
  BasicBlock::iterator InsertPos = BB->getFirstNonPHIOrDbgOrLifetime();

  // Adjust insertion point for landing pads / allocas
  if (BB->isLandingPad())
    ++InsertPos;
  while (isa<AllocaInst>(InsertPos)) {
    ++InsertPos;
  }

  // Prepare GEP for accessing the proper array element.
  Indices[0] = Constant::getNullValue(Type::getInt64Ty(Context));
  Indices[1] = ConstantInt::get(Type::getInt64Ty(Context), idx);

  // If it's a SCoP
  bool isSCoP = AnEdge.second;

  // Store initial time in the array
  Function *F = BB->getParent();
  std::string name = F->getName().str() + "::" + BB->getName().str();
  if (isSCoP) {
    /* Preserve the correct order for stack tracing.
     * This will make us "sneak" past a previously entered
     * call to ExitSCoP.*/
    while (isa<CallInst>(InsertPos)) {
      ++InsertPos;
    }
    PapiRegionEnterSCoP(InsertPos, M, name);
  } else {
    PapiRegionEnter(InsertPos, M);
  }

  // Store final time at exit of the region.
  if (R.second) {
    InsertPos = R.second->getFirstNonPHIOrDbgOrLifetime();
    if (isSCoP) {
      PapiRegionExitSCoP(InsertPos, M, name);
    } else {
      PapiRegionExit(InsertPos, M);
    }
  } else {
    // If we are the TopLevel-Region, we don't have an exit block.
    Function *F = R.first->getParent();
    for (Function::iterator i = F->begin(), e = F->end(); i != e; ++i) {
      BasicBlock *bb = i;
      for (BasicBlock::iterator j = bb->begin(), f = bb->end(); j != f; ++j)
        if (isa<ReturnInst>(j)) {
          if (isSCoP) {
            PapiRegionExitSCoP(j, M, name);
          } else {
            PapiRegionExit(j, M);
          }
        }
    }
  }
}

char PapiRegionProfiling::ID = 0;
char PapiCScopProfiling::ID = 0;
char PapiCScopProfilingInit::ID = 0;

INITIALIZE_PASS_BEGIN(PapiCScopProfilingInit, "pprof-init",
                      "PAPI CScop Profiling (Initialization)", false, false);
INITIALIZE_PASS_END(PapiCScopProfilingInit, "pprof-init",
                      "PAPI CScop Profiling (Initialization)", false, false);

INITIALIZE_PASS_BEGIN(PapiCScopProfiling, "pprof-caddy",
                      "PAPI CScop Profiling", false, false);
INITIALIZE_PASS_DEPENDENCY(LoopInfo);
INITIALIZE_PASS_DEPENDENCY(DominatorTree);
INITIALIZE_PASS_DEPENDENCY(CScopInfo);
INITIALIZE_PASS_END(PapiCScopProfiling, "pprof-caddy",
                      "PAPI CScop Profiling", false, false);

INITIALIZE_PASS_BEGIN(PapiRegionProfiling, "pprof",
                      "PAPI Region Profiling", false, false);
INITIALIZE_PASS_DEPENDENCY(DominatorTree);
INITIALIZE_PASS_DEPENDENCY(LoopInfo);
INITIALIZE_PASS_DEPENDENCY(RegionInfo);
INITIALIZE_PASS_DEPENDENCY(ScopDetection);
INITIALIZE_PASS_DEPENDENCY(NonAffineScopDetection);
INITIALIZE_PASS_END(PapiRegionProfiling, "pprof",
                      "PAPI Region Profiling", false, false);
