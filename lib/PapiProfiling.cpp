//===- PapiProfiling.cpp - Instrument PAPI Profiling ------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "papi"
#include "llvm/Support/Debug.h"

#include "polli/PapiProfiling.h"
#include "papi.h"
#include "llvm/Analysis/LoopInfo.h"

#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"

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
using namespace polly;

STATISTIC(InstrumentedRegions, "Number of instrumented regions");

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

static void PapiCreateAdd(Instruction *InsertBefore, Constant *ElemPtr,
                          Module *M, std::string prefix = "papi.counters.") {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);
  Constant *PapiGetTimeFn =
      M->getOrInsertFunction("PAPI_get_virt_usec", Builder.getInt64Ty(), NULL);
  Value *OldVal, *NewVal, *Current;

  Builder.SetInsertPoint(InsertBefore);
  OldVal = Builder.CreateLoad(ElemPtr, prefix + "summand");
  Current = Builder.CreateCall(PapiGetTimeFn, prefix + "time");
  NewVal = Builder.CreateAdd(OldVal, Current, prefix + "sum");

  Builder.CreateStore(NewVal, ElemPtr);
}

static void PapiCreateSub(Instruction *InsertBefore, Constant *ElemPtr,
                          Module *M, std::string prefix = "papi.counters.") {
  LLVMContext &Context = M->getContext();
  IRBuilder<> Builder(Context);
  Constant *PapiGetTimeFn =
      M->getOrInsertFunction("PAPI_get_virt_usec", Builder.getInt64Ty(), NULL);
  Value *OldVal, *NewVal, *Current;

  Builder.SetInsertPoint(InsertBefore);
  OldVal = Builder.CreateLoad(ElemPtr, prefix + "minuend");
  Current = Builder.CreateCall(PapiGetTimeFn, prefix + "subtrahend");
  NewVal = Builder.CreateSub(OldVal, Current, prefix + "difference");
  Builder.CreateStore(NewVal, ElemPtr);
}

static void InsertProfilingInitCall(Function *MainFn, const char *FnName,
                                    GlobalValue *Array = 0,
                                    PointerType *arrayType = 0) {
  LLVMContext &Context = MainFn->getContext();
  Module &M = *MainFn->getParent();
  Type *ArgVTy = PointerType::getUnqual(Type::getInt8PtrTy(Context));
  PointerType *UIntPtr = arrayType ? arrayType : Type::getInt64PtrTy(Context);
  Constant *InitFn = M.getOrInsertFunction(
      FnName, Type::getInt32Ty(Context), Type::getInt32Ty(Context), ArgVTy,
      UIntPtr, Type::getInt32Ty(Context), (Type *)0);

  Constant *PapiSetup = M.getOrInsertFunction(
      "papi_region_setup", Type::getVoidTy(Context), (Type *)0);

  // Skip over any allocas in the entry block.
  BasicBlock *Entry = MainFn->begin();
  BasicBlock::iterator InsertPos = Entry->begin();
  while (isa<AllocaInst>(InsertPos))
    ++InsertPos;

  // This could force argc and argv into programs that wouldn't otherwise have
  // them, but instead we just pass null values in.
  std::vector<Value *> Args(4);
  Args[0] = Constant::getNullValue(Type::getInt32Ty(Context));
  Args[1] = Constant::getNullValue(ArgVTy);

  std::vector<Constant *> GEPIndices(
      2, Constant::getNullValue(Type::getInt64Ty(Context)));
  unsigned NumElements = 0;
  if (Array) {
    Args[2] = ConstantExpr::getGetElementPtr(Array, GEPIndices);
    NumElements =
        cast<ArrayType>(Array->getType()->getElementType())->getNumElements();
  } else {
    // If this profiling instrumentation doesn't have a constant array, just
    // pass null.
    Args[2] = ConstantPointerNull::get(UIntPtr);
  }
  Args[3] = ConstantInt::get(Type::getInt32Ty(Context), NumElements);

  CallInst *InitCall = CallInst::Create(InitFn, Args, "newargc", InsertPos);
  CallInst::Create(PapiSetup, "", InsertPos);

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
      Instruction::CastOps opcode;
      if (!AI->use_empty()) {
        opcode = CastInst::getCastOpcode(InitCall, true, AI->getType(), true);
        AI->replaceAllUsesWith(
            CastInst::Create(opcode, InitCall, AI->getType(), "", InsertPos));
      }
      opcode =
          CastInst::getCastOpcode(AI, true, Type::getInt32Ty(Context), true);
      InitCall->setArgOperand(
          0, CastInst::Create(opcode, AI, Type::getInt32Ty(Context),
                              "argc.cast", InitCall));
    } else {
      AI->replaceAllUsesWith(InitCall);
      InitCall->setArgOperand(0, AI);
    }
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

void PapiProfiling::instrumentFunction(int idx, Function *F,
                                       GlobalValue *Array) {
  Module *M = F->getParent();
  LLVMContext &Context = M->getContext();
  Constant *ElemPtr;
  std::vector<Constant *> Indices(2);
  BasicBlock *EntryBB = F->begin();
  BasicBlock::iterator InsertPos;
  IRBuilder<> Builder(Context);
  Constant *PapiGetTimeFn =
      M->getOrInsertFunction("PAPI_get_virt_usec", Builder.getInt64Ty(), NULL);

  Indices[0] = Constant::getNullValue(Type::getInt64Ty(Context));
  Indices[1] = ConstantInt::get(Type::getInt64Ty(Context), idx);
  ElemPtr = ConstantExpr::getGetElementPtr(Array, Indices);

  // Store initial time in the array
  InsertPos = EntryBB->getFirstNonPHIOrDbgOrLifetime();
  while (isa<AllocaInst>(InsertPos))
    ++InsertPos;

  PapiCreateSub(InsertPos, ElemPtr, M, "papi.functions.");

  // Deal with calls on the control path
  for (Function::iterator i = F->begin(), e = F->end(); i != e; ++i) {
    BasicBlock *bb = i;
    for (BasicBlock::iterator ii = bb->begin(), ee = bb->end(); ii != ee;
         ++ii) {
      // Surround a function call by timing counters.
      if (isa<CallInst>(ii)) {
        // Never instrument our own timing Fn!
        CallInst *call = dyn_cast<CallInst>(ii);
        if (call->getCalledFunction() == PapiGetTimeFn)
          continue;

        PapiCreateAdd(ii, ElemPtr, M, "papi.functions.");
        PapiCreateSub(++ii, ElemPtr, M, "papi.functions.");
      }

      if (isa<ReturnInst>(ii))
        PapiCreateAdd(ii, ElemPtr, M, "papi.functions.");
    }
  }
}

/**
 * @brief Insert instrumentation calls into a LLVM IR module.
 *
 * @param M
 * @return bool
 */
bool PapiProfiling::runOnModule(Module &M) {
  int toInstrument = 0;
  LLVMContext &Context = M.getContext();

  Function *Main = M.getFunction("main");
  if (Main == 0) {
    errs() << "WARNING: cannot insert papi profiling into a module"
           << " with no main function!\n";
    return false; // No main, no instrumentation!
  }

  // Calculate needed array space
  for (auto &elem : M) {
    if (elem.isDeclaration())
      continue;
    ++toInstrument;
  }

  // Create a global array to hold the results.
  Type *ATy = ArrayType::get(Type::getInt64Ty(Context), toInstrument);
  GlobalVariable *Counters =
      new GlobalVariable(M, ATy, false, GlobalValue::InternalLinkage,
                         Constant::getNullValue(ATy), "PapiProfTime");

  // Place the necessary PAPI calls.
  int num = 0;
  for (Module::iterator i = M.begin(), e = M.end(); i != e; ++i) {
    if (i->isDeclaration())
      continue;

    instrumentFunction(num, i, Counters);
    ++num;
  }

  InsertProfilingInitCall(Main, "llvm_start_papi_profiling", Counters);
  return true;
}

void PapiProfiling::print(raw_ostream &OS, const llvm::Module *M) const {}


void PapiRegionPrepare::createPapiEntry(Region *R) {
  RegionInfo *RI = R->getRegionInfo();
  BasicBlock *Entry = R->getEntry();
  BasicBlock *Exit = R->getExit();
  Loop *L = LI->getLoopFor(Entry);
  Loop *ExitL = LI->getLoopFor(Exit);
  std::vector<BasicBlock *> Preds;

  unsigned totalPreds = 0;
  for (pred_iterator PI = pred_begin(Entry), E = pred_end(Entry); PI != E;
       ++PI) {

    BasicBlock *PredBB = (*PI);
    totalPreds++;
    // Don't include loop backedges in the predecessor split.
    if (!L || !L->contains(PredBB) || (L->contains(PredBB) && (L == ExitL)))
      Preds.push_back(PredBB);
  }

  // No need to split. Function entry.
  if (Preds.size() == 0)
    return;

  // No need to split, if we would have to split all our predecessors.
  if (totalPreds == Preds.size())
    return;

  SmallVector<BasicBlock *, 2> SplitBBs;
  if (Entry->isLandingPad())
    SplitLandingPadPredecessors(Entry, Preds, ".papi.exit", ".papi.others",
                                this, SplitBBs);
  else
    SplitBBs.push_back(
        SplitBlockPredecessors(Entry, Preds, ".papi.entry", this));
  RI->splitBlock(SplitBBs[0], Entry);

  /* Update the region exits for siblings of our current region.
   *
   & Check if the region of our predecessors shares it's Exit
   * BB with our EntryBB. If yes, update the exit block.
   */
  for (auto &Pred : Preds) {
    Region *PredR = RI->getRegionFor(Pred);

    if (PredR->getExit() == Entry)
      PredR->replaceExit(*(SplitBBs.begin()));
  }
}

bool PapiRegionPrepare::isParent(Region *R, Region *Child) {
  RegionInfo *RI = R->getRegionInfo();
  if (Child == RI->getTopLevelRegion())
    return false;

  if (R != Child->getParent())
    return isParent(R, Child->getParent());

  return true;
}

void PapiRegionPrepare::createPapiExit(Region *R) {
  BasicBlock *Exit = R->getExit();
  RegionInfo *RI = R->getRegionInfo();
  std::vector<BasicBlock *> Preds;

  // Function exit, no problem.
  if (!Exit)
    return;
  // Already an unique exit.
  if (Exit->getUniquePredecessor())
    return;

  if (isValidBB(R->getEntry(), Exit, LI, DT))
    return;

  /* Not sure about this anymore, recheck */
  for (pred_iterator PI = pred_begin(Exit), E = pred_end(Exit); PI != E; ++PI) {
    Region *PredR = RI->getRegionFor((*PI));

    if (PredR && (R == PredR || isParent(R, PredR)))
      Preds.push_back((*PI));
  }

  assert(Preds.size() > 0 && "No predecessors found!");
  if (Preds.size() > 0) {
    SmallVector<BasicBlock *, 2> SplitBBs;
    if (Exit->isLandingPad())
      SplitLandingPadPredecessors(Exit, Preds, ".papi.exit", ".papi.others",
                                  this, SplitBBs);
    else
      SplitBBs.push_back(
          SplitBlockPredecessors(Exit, Preds, ".papi.exit", this));
    RI->setRegionFor(SplitBBs[0], R);
  }
}

bool PapiRegionPrepare::runOnRegion(Region *R, RGPassManager &RGM) {
  LI = &getAnalysis<LoopInfo>();
  DT = &getAnalysis<DominatorTree>();

  createPapiExit(R);
  createPapiEntry(R);
  return true;
}

char PapiProfiling::ID = 0;
char PapiRegionPrepare::ID = 0;

INITIALIZE_PASS_BEGIN(PapiRegionPrepare, "papi-prepare",
                      "Insert Entry/Exit blocks for PAPI region counters",
                      false, false)
INITIALIZE_PASS_END(PapiRegionPrepare, "papi-prepare",
                    "Insert Entry/Exit blocks for PAPI region counters", false,
                    false)

INITIALIZE_PASS_BEGIN(PapiProfiling, "insert-papi-profiling",
                      "Insert PAPI timing information", false, false)
INITIALIZE_PASS_END(PapiProfiling, "insert-papi-profiling",
                    "Insert PAPI timing information", false, false)
