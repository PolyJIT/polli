//===-- FunctionCloner.h - Class definition for the ScopMapper --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Policy based function cloning.
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_FUNCTION_CLONER_H
#define POLLI_FUNCTION_CLONER_H

#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;

namespace polli {
template
<
  class CreationPolicy,
  class DrainPolicy,
  class SinkPolicy
>
class FunctionCloner : public CreationPolicy,
                       public DrainPolicy,
                       public SinkPolicy {
  ValueToValueMapTy &VMap;
  Module   *TgtM;

  Function *SrcF;
  Function *TgtF;

public:
  explicit FunctionCloner<CreationPolicy, DrainPolicy, SinkPolicy>
    (ValueToValueMapTy& map, Module *m = NULL) : VMap(map), TgtM(m) {
      SrcF = NULL;
      TgtF = NULL;
    };

  void setTarget(Function *F) { TgtF = F; }
  void setSource(Function *F) { SrcF = F; }

  /* Clone the source function into the target function.
   * If target function does not exist, create one in
   * target module.
   * If target module does not exist, create the target
   * function in the source module. */
  Function *start() {
    if (!TgtM)
      TgtM = SrcF->getParent();

    if (!TgtF)
     TgtF = CreationPolicy::Create(SrcF, TgtM);

    TgtF->copyAttributesFrom(SrcF);

    CreationPolicy::MapArguments(VMap, SrcF, TgtF);

    /* Copy function body ExtractedF over to ClonedF */
    SmallVector<ReturnInst*, 8> Returns;
    CloneFunctionInto(TgtF, SrcF, VMap,/* ModuleLevelChanges=*/false, Returns);

    // Store function mapping for the linker.
    VMap[SrcF] = TgtF;

    DrainPolicy::Apply(SrcF, TgtF, VMap);
    SinkPolicy::Apply(TgtF, SrcF, VMap);

    // No need for the mapping anymore.
    for (Function::const_arg_iterator
         Arg = SrcF->arg_begin(), AE = SrcF->arg_end(); Arg != AE; ++Arg) {
      VMap.erase(Arg);
    }

    return TgtF;
  }
};

/*
 * Cloning policies.
 */
struct CopyCreator {
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                                                    Function *TgtF) {
    Function::arg_iterator NewArg = TgtF->arg_begin();
    for (Function::const_arg_iterator
         Arg = SrcF->arg_begin(), AE = SrcF->arg_end(); Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[Arg] = NewArg++;
    }
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    return Function::Create(SrcF->getFunctionType(),
                            SrcF->getLinkage(),
                            SrcF->getName(),
                            TgtM);
  }
};

/*
 * Endpoint policies for the function cloner host.
 */
struct IgnoreSource {
  static void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &VMap) {
    /* Do nothing */
  };
};

struct IgnoreTarget {
  static void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &VMap) {
    /* Do nothing */
  };
};

struct DestroyEndpoint {
  static void Apply(Function* TgtF, Function *SrcF, ValueToValueMapTy &VMap) {
    TgtF->deleteBody();
    VMap.erase(TgtF);
  }
};

struct InstrumentEndpoint {
  static void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &VMap) {
    if (TgtF->isDeclaration())
      return;

    Module *M = TgtF->getParent();
    LLVMContext &Ctx = M->getContext();
    IRBuilder<> Builder(Ctx);

    StringRef cbName = StringRef("polli.enter.runtime");
    PointerType *PtoArr = PointerType::get(Type::getInt8PtrTy(Ctx), 0);
    Function *PJITCB = cast<Function>(
      M->getOrInsertFunction(cbName, Type::getVoidTy(Ctx),
                                     Type::getInt8PtrTy(Ctx),
                                     Type::getInt32Ty(Ctx),
                                     PtoArr,
                                     NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);

    std::vector<Value *> Args(3);
    BasicBlock *BB = TgtF->begin();
    Builder.SetInsertPoint(BB->getFirstInsertionPt());

    /* Create a generic IR sequence of this example C-code:
     *
     * void foo(int n, int A[42]) {
     *  void *params[2];
     *  params[0] = &n;
     *  params[1] = &A;
     *
     *  pjit_callback("foo", 2, params);
     * }
     */

    /* Prepare a stack array for the parameters. We will pass a pointer to
     * this array into our callback function. */
    int argc = TgtF->arg_size();
    Value *ParamC = ConstantInt::get(Type::getInt32Ty(Ctx), argc, true);
    Value *Params = Builder.CreateAlloca(Type::getInt8PtrTy(Ctx),
                                         ParamC, "params");
    /* Store each parameter as pointer in the params array */
    int i = 0;
    Value *One    = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
    for (Function::arg_iterator Arg = TgtF->arg_begin(),
                                ArgE = TgtF->arg_end();
                                Arg != ArgE; ++Arg) {

      /* Allocate a slot on the stack for the i'th argument and store it */
      Value *Slot   = Builder.CreateAlloca(Arg->getType(), One,
                                           "params." + Twine(i));
      Builder.CreateStore(Arg, Slot);

      /* Bitcast the allocated stack slot to i8* */
      Value *Slot8 = Builder.CreateBitCast(Slot, Type::getInt8PtrTy(Ctx),
                                           "ps.i8ptr." + Twine(i));

      /* Get the appropriate slot in the parameters array and store
       * the stack slot in form of a i8*. */
      Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i);
      Value *Dest   = Builder.CreateGEP(Params, ArrIdx, "p." + Twine(i));
      //Builder.CreateAlignedStore(Slot8, Dest, 8);
      Builder.CreateStore(Slot8, Dest);

      i++;
    }

    Args[0] = Builder.CreateGlobalStringPtr(TgtF->getName());
    Args[1] = ParamC;
    Args[2] = Params;

    // Replace terminator after PolyJIT call with a return void.
    CallInst *CallPolyJIT = Builder.CreateCall(PJITCB, Args);
    BasicBlock *CallBB = CallPolyJIT->getParent();

    // Purge everything after the call.
    BasicBlock *CurBB = CallBB->getNextNode();
    while (CurBB != TgtF->end()) {
        BasicBlock *EraseBB = CurBB;
        CurBB = CurBB->getNextNode();
        EraseBB->removeFromParent();
    }

    ReplaceInstWithInst(CallBB->getTerminator(), ReturnInst::Create(Ctx));
  }
};

typedef
FunctionCloner<CopyCreator, IgnoreSource, IgnoreTarget> DefaultFunctionCloner;

typedef
FunctionCloner<CopyCreator, DestroyEndpoint, IgnoreTarget> MovingFunctionCloner;

typedef
FunctionCloner<CopyCreator, IgnoreSource, InstrumentEndpoint> InstrumentingFunctionCloner;
}
#endif //POLLI_FUNCTION_CLONER_H
