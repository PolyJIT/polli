//===-- LikwidMarker.cpp - LikwidMarker pass --------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Place likwidMarker* calls in parallel regions.
//
//===----------------------------------------------------------------------===//
#include "polli/LikwidMarker.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Type.h"
#include "llvm/Pass.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassSupport.h"

namespace polli {
class LikwidMarker : public llvm::FunctionPass {
public:
  static char ID;
  explicit LikwidMarker(bool enable = true) : llvm::FunctionPass(ID) {}

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const;
  virtual void releaseMemory();
  virtual bool runOnFunction(llvm::Function &F);
  virtual void print(llvm::raw_ostream &OS, const llvm::Module *) const;
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  LikwidMarker(const LikwidMarker &);
  // DO NOT IMPLEMENT
  const LikwidMarker &operator=(const LikwidMarker &);
};
}

using namespace polli;
using namespace llvm;

char LikwidMarker::ID = 0;

namespace polli {
void LikwidMarker::getAnalysisUsage(llvm::AnalysisUsage &AU) const {}

void LikwidMarker::releaseMemory() {}

void LikwidMarker::print(llvm::raw_ostream &OS, const llvm::Module *) const {}

bool LikwidMarker::runOnFunction(llvm::Function &F) {
  Module *M = F.getParent();
  LLVMContext &Ctx = M->getContext();
  Function *OmpStartFn = M->getFunction("GOMP_parallel_loop_runtime_start");
  //Function *OmpStartFn = M->getFunction("GOMP_loop_runtime_next");
  Function *OmpEndFn = M->getFunction("GOMP_parallel_end");
  //Function *OmpEndFn = M->getFunction("GOMP_loop_end_nowait");
  Function *ThreadInit = static_cast<Function *>(M->getOrInsertFunction(
      "likwid_markerThreadInit", Type::getVoidTy(Ctx), nullptr));
  Function *Start = static_cast<Function *>(
      M->getOrInsertFunction("likwid_markerStartRegion", Type::getVoidTy(Ctx),
                             Type::getInt8PtrTy(Ctx, 0), nullptr));
  Function *Stop = static_cast<Function *>(
      M->getOrInsertFunction("likwid_markerStopRegion", Type::getVoidTy(Ctx),
                             Type::getInt8PtrTy(Ctx, 0), nullptr));

  IRBuilder<> Builder(Ctx);
  if (!OmpStartFn || !OmpEndFn)
    return false;

  for (BasicBlock &BB : F) {
    for (BasicBlock::iterator I = BB.begin(), IE = BB.end(); I != IE; ++I) {
      if (CallInst *Call = dyn_cast<CallInst>(&*I)) {
        if (Call->getCalledFunction() == OmpStartFn) {
          Builder.SetInsertPoint(++I);
          Builder.Insert(CallInst::Create(ThreadInit));
          Builder.CreateCall(Start, Builder.CreateGlobalStringPtr(F.getName()));
        }

        if (Call->getCalledFunction() == OmpEndFn) {
          Builder.SetInsertPoint(I);
          Builder.CreateCall(Stop, Builder.CreateGlobalStringPtr(F.getName()));
        }
      }
    }
  }
  return true;
}

FunctionPass *createLikwidMarkerPass() {
  return new LikwidMarker();
}
}

static RegisterPass<LikwidMarker>
    X("polli-likwid", "PolyJIT - Mark parallel regions with likwid calls.",
      false, false);
