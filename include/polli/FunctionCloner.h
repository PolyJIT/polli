//===-- FunctionCloner.h - Class definition for the cloner     --*- C++ -*-===//
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
#include "polli/Utils.h"
#include "polli/TypeMapper.h"
#include "polli/log.h"
#include "polli/FuncTools.h"

#include "llvm/Analysis/PostDominators.h"
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
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/Linker/IRMover.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;

namespace polli {
namespace log {
REGISTER_LOG(console, "cloner");
}


static inline void verifyFn(const Twine &Prefix, const Function *F) {
  std::string buffer;
  llvm::raw_string_ostream s(buffer);
  s << Prefix;
  if (F && !F->isDeclaration()) {
    if (!verifyFunction(*F, &s))
      s << " OK";
    else {
      F->getParent()->dump();
      s << " FAILED";
    }
  } else if (F && F->isDeclaration()) {
    F->getType()->print(s << " OK \n\t\t(declare) : ");
  } else {
    s << " OK (F is nullptr)";
  }
  errs() << "\n" << s.str() << "\n";
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
      : VMap(map), ToM(m), From(nullptr), To(nullptr) {}

  void setTarget(Function *F) { To = F; }
  FunctionCloner &setSource(Function *F) {
    From = F;
    return *this;
  }

  void setDominatorTree(DominatorTree *DT) {
    this->DT = DT;
  }

  void mapCalls(Function &SrcF, Module *TgtM, ValueToValueMapTy &VMap) const {
    if (SrcF.getParent() == TgtM)
      return;

    SPDLOG_DEBUG("cloner", "Checking for functions to remap in {:s}",
                 SrcF.getName().str());
    for (Instruction &I : instructions(SrcF)) {
      if (isa<CallInst>(&I) || isa<InvokeInst>(&I)) {
        CallSite CS = CallSite(&I);
        if (Function *CalledF = CS.getCalledFunction()) {
          Function *NewF = cast<Function>(TgtM->getOrInsertFunction(
              CalledF->getName(), CalledF->getFunctionType(),
              CalledF->getAttributes()));
          NewF->setLinkage(CalledF->getLinkage());
          VMap[CalledF] = NewF;
          SPDLOG_DEBUG("cloner", "Mapped: {:s}", NewF->getName().str());
        }
      }
    }
  }

  void mapGlobals(Function &SrcF, Module *TgtM,
                  ValueToValueMapTy &VMap) const {
    if (SrcF.getParent() == TgtM)
      return;

    GlobalList GVs = apply<GlobalList>(SrcF, selectGV);
    for (auto *GV : GVs) {
      GlobalValue *NewGV = TgtM->getNamedGlobal(GV->getName());
      if (!NewGV) {
        NewGV = cast<GlobalValue>(
            TgtM->getOrInsertGlobal(GV->getName(), GV->getValueType()));
      }
      VMap[GV] = NewGV;
    }
  }

  /* Clone the source function into the target function.
   * If target function does not exist, create one in
   * target module.
   * If target module does not exist, create the target
   * function in the source module. */
  Function *start(bool RemapCalls = false, DominatorTree *DT = nullptr,
                  bool RemapGlobals = true) {
    if (!ToM)
      ToM = From->getParent();

    if (!To)
      To = OnCreate::Create(From, ToM);
    OnCreate::MapArguments(VMap, From, To);

    /* Copy function body ExtractedF over to ClonedF */
    SmallVector<ReturnInst *, 8> Returns;

    DEBUG(polli::verifyFunctions("\t>> ", From, To));

    if (RemapGlobals)
      mapGlobals(*From, ToM, VMap);
    // Collect all calls for remapping.
    if (RemapCalls)
      mapCalls(*From, ToM, VMap);

    ClonedCodeInfo CI;
    IRMover::IdentifiedStructTypeSet DstStructTypesSet;
    TypeMapTy TM(DstStructTypesSet);
    CloneFunctionInto(To, From, VMap, /* ModuleLevelChanges=*/true, Returns,
                      "", &CI, &TM);

    SourceAfterClone::Apply(From, To, VMap);
    TargetAfterClone::Apply(From, To, VMap);

    if (DT)
      polli::removeFunctionFromDomTree(To, *DT);

    DEBUG(polli::verifyFunctions("\t<< ", From, To));

    // Store function mapping for the linker.
    VMap[From] = To;
    return To;
  }

private:
  ValueToValueMapTy &VMap;
  Module *ToM;
  DominatorTree *DT;
  Function *From;
  Function *To;
};

/*
 * Cloning policies.
 */
struct CopyCreator {
  void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    Function::arg_iterator NewArg = TgtF->arg_begin();
    for (Function::const_arg_iterator Arg = SrcF->arg_begin(),
                                      AE = SrcF->arg_end();
         Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[&*Arg] = &*(NewArg++);
    }
  }

  Function *Create(Function *SrcF, Module *TgtM) {
    return Function::Create(SrcF->getFunctionType(), SrcF->getLinkage(),
                            SrcF->getName(), TgtM);
  }
};

/*
 * Endpoint policies for the function cloner host.
 */
struct IgnoreSource {
  void Apply(Function *, Function *, ValueToValueMapTy &){
      /* Do nothing */
  };
};

struct IgnoreTarget {
  void Apply(Function *, Function *, ValueToValueMapTy &){
      /* Do nothing */
  };
};

struct ConnectTarget {
  void Apply(Function *From, Function *To, ValueToValueMapTy &VMap){
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
  void Apply(Function *SrcF, Function *, ValueToValueMapTy &VMap) {
    SrcF->deleteBody();
  }
};

struct DestroyTarget {
  void Apply(Function *, Function *TgtF, ValueToValueMapTy &VMap) {
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
