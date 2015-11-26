//===-- FunctionCloner.h - Class definition for the ScopMapper --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2015 Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
//
// Policy based function cloning.
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_FUNCTION_CLONER_H
#define POLLI_FUNCTION_CLONER_H

#include "polli/Options.h"

#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/Transforms/Utils/Cloning.h"

#include "cppformat/format.h"

using namespace llvm;

namespace polli {

static inline void verifyFn(const Twine &Prefix, const Function *F) {
  std::string buffer;
  llvm::raw_string_ostream s(buffer);
  s << Prefix;
  if (F && !F->isDeclaration()) {
    if (!verifyFunction(*F, &s))
      s << " OK";
    else
      s << " FAILED";
  } else if (F && F->isDeclaration()) {
    F->getType()->print(s << " OK \n\t\t(declare) : ");
  } else {
    s << " OK (F is nullptr)";
  }

  outs() << fmt::format(s.str());
}

static inline void verifyFunctions(const Twine &Prefix, const Function *SrcF,
                                   const Function *TgtF) {

  verifyFn(Prefix + "Verify Source ", SrcF);
  verifyFn(Prefix + "Verify Target ", TgtF);
}

template <class OnCreate, class SourceAfterClone, class TargetAfterClone>
class FunctionCloner : public OnCreate,
                       public SourceAfterClone,
                       public TargetAfterClone {
public:
  explicit FunctionCloner(
      ValueToValueMapTy &map, Module *m = NULL)
      : ToM(m), From(nullptr), To(nullptr) {}

  void setTarget(Function *F) { To = F; }
  FunctionCloner &setSource(Function *F) {
    From = F;
    return *this;
  }

  void mapCalls(Function &SrcF, Module *TgtM, ValueToValueMapTy &VMap) const {
    for (Instruction &I : instructions(SrcF)) {
      if (isa<CallInst>(&I) || isa<InvokeInst>(&I)) {
        CallSite CS = CallSite(&I);
        if (Function *CalledF = CS.getCalledFunction()) {
          Function *NewF = cast<Function>(TgtM->getOrInsertFunction(
              CalledF->getName(), CalledF->getFunctionType(),
              CalledF->getAttributes()));
          NewF->setLinkage(CalledF->getLinkage());
          VMap[CalledF] = NewF;
        }
      }
    }
  }

  /* Clone the source function into the target function.
   * If target function does not exist, create one in
   * target module.
   * If target module does not exist, create the target
   * function in the source module. */
  Function *start(bool RemapCalls = false) {
    ValueToValueMapTy VMap;
    if (!ToM)
      ToM = From->getParent();

    if (!To)
      To = OnCreate::Create(From, ToM);
    OnCreate::MapArguments(VMap, From, To);

    /* Copy function body ExtractedF over to ClonedF */
    SmallVector<ReturnInst *, 8> Returns;

    // Collect all calls for remapping.
    if (RemapCalls)
      mapCalls(*From, ToM, VMap);

    DEBUG(polli::verifyFunctions("\t>> ", From, To));

    CloneFunctionInto(To, From, VMap, /* ModuleLevelChanges=*/true, Returns);

    SourceAfterClone::Apply(From, To, VMap);
    TargetAfterClone::Apply(From, To, VMap);

    DEBUG(polli::verifyFunctions("\t<< ", From, To));

    // Store function mapping for the linker.
    VMap[From] = To;
    return To;
  }

private:
  Module *ToM;
  Function *From;
  Function *To;
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
      VMap[&*Arg] = &*(NewArg++);
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
  static void Apply(Function *, Function *, ValueToValueMapTy &){
      /* Do nothing */
  };
};

struct IgnoreTarget {
  static void Apply(Function *, Function *, ValueToValueMapTy &){
      /* Do nothing */
  };
};

struct ConnectTarget {
  static void Apply(Function *From, Function *To, ValueToValueMapTy &VMap){
    /* We have to connect the function entry block to the entry block of the
     * target function unconditionally. This way, CreationPolicies can
     * modifiy the function entry.
     */

    LLVMContext &Context = To->getContext();
    IRBuilder<> Builder(Context);
    BasicBlock *EntryBB = &To->getEntryBlock();
    BasicBlock *SrcEntryBB = &From->getEntryBlock();
    BasicBlock *ClonedEntryBB = cast<BasicBlock>(VMap[SrcEntryBB]);

    Builder.SetInsertPoint(EntryBB);
    Builder.CreateBr(ClonedEntryBB);
  }
};

struct DestroySource {
  static void Apply(Function *SrcF, Function *, ValueToValueMapTy &VMap) {
    SrcF->deleteBody();
  }
};

struct DestroyTarget {
  static void Apply(Function *, Function *TgtF, ValueToValueMapTy &VMap) {
    TgtF->deleteBody();
  }
};

typedef FunctionCloner<CopyCreator, IgnoreSource, IgnoreTarget>
    DefaultFunctionCloner;

typedef FunctionCloner<CopyCreator, DestroySource, IgnoreTarget>
    MovingFunctionCloner;
}
#undef DEBUG_TYPE
#endif // POLLI_FUNCTION_CLONER_H
