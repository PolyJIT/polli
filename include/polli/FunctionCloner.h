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

#include "llvm/Support/raw_ostream.h"

using namespace llvm;
namespace polli {

template <class CreationPolicy, class DrainPolicy, class SinkPolicy>
class FunctionCloner : public CreationPolicy,
                       public DrainPolicy,
                       public SinkPolicy {
public:
  explicit FunctionCloner<CreationPolicy, DrainPolicy, SinkPolicy>(
      ValueToValueMapTy &map, Module *m = NULL)
      : VMap(map), TgtM(m), SrcF(nullptr), TgtF(nullptr) {}

  void setTarget(Function *F) { TgtF = F; }
  FunctionCloner& setSource(Function *F) { SrcF = F; return *this; }

  /* Optional: Set the pass we piggy-back ourself on. This enables
  * access to BasicBlockUtils which require Passes to operate on. */
  void setSinkHostPass(Pass *HostP) {
    SinkPolicy &pPolicy = *this;
    pPolicy.setPass(HostP);
  }

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

    CreationPolicy::MapArguments(VMap, SrcF, TgtF);

    /* Copy function body ExtractedF over to ClonedF */
    SmallVector<ReturnInst *, 8> Returns;
    CloneFunctionInto(TgtF, SrcF, VMap, /* ModuleLevelChanges=*/true, Returns);

    TgtF->copyAttributesFrom(SrcF);

    // Store function mapping for the linker.
    VMap[SrcF] = TgtF;

    DrainPolicy::Apply(SrcF, TgtF, VMap);
    SinkPolicy::Apply(TgtF, SrcF, VMap);

    return TgtF;
  }

private:
  ValueToValueMapTy &VMap;
  Module *TgtM;
  Function *SrcF;
  Function *TgtF;
};

/*
 * Cloning policies.
 */
struct CopyCreator {
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    Function::arg_iterator NewArg = TgtF->arg_begin();
    for (Function::const_arg_iterator Arg = SrcF->arg_begin(),
                                      AE = SrcF->arg_end();
         Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[Arg] = NewArg++;
    }
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    return Function::Create(SrcF->getFunctionType(), SrcF->getLinkage(),
                            SrcF->getName(), TgtM);
  }
};

/*
 * Endpoint policies for the function cloner host.
 */
struct IgnoreSource {
  static void Apply(Function *, Function *, ValueToValueMapTy &) {
    /* Do nothing */
  };
};

struct IgnoreTarget {
  static void Apply(Function *, Function *, ValueToValueMapTy &) {
    /* Do nothing */
  };
};

struct DestroyEndpoint {
  static void Apply(Function *TgtF, Function *, ValueToValueMapTy &VMap) {
    TgtF->deleteBody();
    VMap.erase(TgtF);
  }
};

typedef FunctionCloner<CopyCreator, IgnoreSource, IgnoreTarget>
DefaultFunctionCloner;

typedef FunctionCloner<CopyCreator, DestroyEndpoint, IgnoreTarget>
MovingFunctionCloner;

}
#endif // POLLI_FUNCTION_CLONER_H
