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

#include "spdlog/spdlog.h"


namespace polli {
class LikwidMarker : public llvm::ModulePass {
public:
  static char ID;
  explicit LikwidMarker(bool enable = true) : llvm::ModulePass(ID) {}

  /// @name ModulePass interface
  //@{
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
  virtual void releaseMemory() override;
  virtual bool runOnModule(llvm::Module &M) override;
  virtual void print(llvm::raw_ostream &OS,
                     const llvm::Module *) const override;
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

bool LikwidMarker::runOnModule(llvm::Module &M) {
  auto Console = spdlog::stderr_logger_st("polli/likwid");

  Console->warn("Working on {}", M.getModuleIdentifier());
  LLVMContext &Ctx = getGlobalContext();
  Function *OmpStartFn = M.getFunction("GOMP_loop_runtime_next");
  Function *ThreadInit = static_cast<Function *>(M.getOrInsertFunction(
      "likwid_markerThreadInit", Type::getVoidTy(Ctx), nullptr));
  Function *Start = static_cast<Function *>(
      M.getOrInsertFunction("likwid_markerStartRegion", Type::getVoidTy(Ctx),
                            Type::getInt8PtrTy(Ctx, 0), nullptr));
  Function *Stop = static_cast<Function *>(
      M.getOrInsertFunction("likwid_markerStopRegion", Type::getVoidTy(Ctx),
                            Type::getInt8PtrTy(Ctx, 0), nullptr));

  if (!OmpStartFn)
    return false;

  // Find the OpenMP sub function
  SmallVector<Function *, 4> SubFunctions;
  for (Function &F : M) {
    for (BasicBlock &BB : F) {
      for (BasicBlock::iterator I = BB.begin(), IE = BB.end(); I != IE; ++I) {
        if (CallInst *Call = dyn_cast<CallInst>(&*I)) {
          if (Call->getCalledFunction() == OmpStartFn) {
            SubFunctions.push_back(&F);
          }
        }
      }
    }
  }

  if (SubFunctions.size() == 0) {
    Console->warn("No OpenMP SubFunction found.");
    return false;
  }

  for (auto SubFn : SubFunctions) {
    Console->warn("OpenMP subfn found: {}", SubFn->getName().str());
    BasicBlock &Entry = SubFn->getEntryBlock();
    IRBuilder<> Builder(Ctx);

    Builder.SetInsertPoint(Entry.getFirstInsertionPt());
    Builder.Insert(CallInst::Create(ThreadInit));
    Builder.CreateCall(Start, Builder.CreateGlobalStringPtr(SubFn->getName()));

    for (BasicBlock &BB : *SubFn) {
      for (BasicBlock::iterator J = BB.begin(), JE = BB.end(); J != JE; ++J) {
        if (isa<ReturnInst>(&*J)) {
          Builder.SetInsertPoint(J);
          Builder.CreateCall(Stop, Builder.CreateGlobalStringPtr(SubFn->getName()));
        }
      }
    }
  }
  return true;
}

ModulePass *createLikwidMarkerPass() { return new LikwidMarker(); }
}

static RegisterPass<LikwidMarker>
    X("polli-likwid", "PolyJIT - Mark parallel regions with likwid calls.",
      false, false);

