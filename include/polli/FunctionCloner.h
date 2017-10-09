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
#ifndef POLLI_FUNCTIONCLONER_H
#define POLLI_FUNCTIONCLONER_H

#include "polli/FuncTools.h"
#include "polli/Options.h"
#include "polli/TypeMapper.h"
#include "polli/Utils.h"
#include "polli/log.h"

#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Linker/IRMover.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <chrono>

using namespace llvm;

namespace polli {
namespace log {
REGISTER_LOG(console, "cloner");
} // namespace log

static inline void verifyFn(const Twine &Prefix, const Function *F) {
  std::string Buffer;
  llvm::raw_string_ostream S(Buffer);
  S << Prefix;
  if (F && !F->isDeclaration()) {
    if (!verifyFunction(*F, &S))
      S << " OK";
    else {
      F->print(S, nullptr, true, true);
      S << " FAILED";
    }
  } else if (F && F->isDeclaration()) {
    F->getType()->print(S << " OK \n\t\t(declare) : ");
  } else {
    S << " OK (F is nullptr)";
  }
  errs() << "\n" << S.str() << "\n";
}

static inline void verifyFunctions(const Twine &Prefix, const Function *SrcF,
                                   const Function *TgtF) {

  verifyFn(Prefix + "Verify Source ", SrcF);
  verifyFn(Prefix + "Verify Target ", TgtF);
}

class FunctionClonerBase {
public:
  FunctionClonerBase()
      : ToM(nullptr), DT(nullptr), From(nullptr), To(nullptr) {}

  auto setTargetModule(Module *M) -> void { ToM = M; }

  auto setSource(Function *F) -> void { From = F; }

  auto setDominatorTree(DominatorTree *_DT) -> void { DT = _DT; }

  virtual ~FunctionClonerBase() = default;

  virtual Function *start(ValueToValueMapTy &VMap, bool RemapCalls = false,
                          bool RemapGlobals = true) = 0;

protected:
  Module *ToM;
  DominatorTree *DT;
  Function *From;
  Function *To;
};

template <class OnCreate, class SourceAfterClone, class TargetAfterClone>
class FunctionCloner : public FunctionClonerBase,
                       public OnCreate,
                       public SourceAfterClone,
                       public TargetAfterClone {
public:
  FunctionCloner() : FunctionClonerBase() {}

  /* Clone the source function into the target function.
   * If target function does not exist, create one in
   * target module.
   * If target module does not exist, create the target
   * function in the source module. */
  Function *start(ValueToValueMapTy &VMap, bool RemapCalls = false,
                  bool RemapGlobals = true) {
    using namespace std::placeholders;
    if (!ToM)
      ToM = From->getParent();

    if (!To)
      To = OnCreate::Create(From, ToM);
    OnCreate::MapArguments(VMap, From, To);

    // Prepare the source function.
    // We need to substitute all instructions that use ConstantExpressions.
    InstrList L = apply<InstrList>(
        *From, std::bind(constantExprToInstruction, _1, _2, std::ref(VMap)));

    /* Copy function body ExtractedF over to ClonedF */
    SmallVector<ReturnInst *, 8> Returns;

    DEBUG(polli::verifyFunctions("\t>> ", From, To));

    // Collect all calls for remapping.
    if (RemapCalls)
      mapCalls(*From, ToM, VMap);

    if (RemapGlobals)
      mapGlobals(*From, ToM, VMap);

    ClonedCodeInfo CI;
    CloneFunctionInto(To, From, VMap, /* ModuleLevelChanges=*/true, Returns, "",
                      &CI);

    SourceAfterClone::Apply(From, To, VMap);
    TargetAfterClone::Apply(From, To, VMap);

    if (DT)
      polli::removeFunctionFromDomTree(*To, *DT);

    DEBUG(polli::verifyFunctions("\t<< ", From, To));

    // Store function mapping for the linker.
    VMap[From] = To;
    return To;
  }

private:
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
          if (CalledF->hasPersonalityFn())
            NewF->setPersonalityFn(CalledF->getPersonalityFn());
          VMap[CalledF] = NewF;

          if (isa<IntrinsicInst>(&I))
            continue;
          NewF->setLinkage(GlobalValue::LinkageTypes::ExternalLinkage);
          SPDLOG_DEBUG("cloner", "Mapped: {:s}", NewF->getName().str());
        }
      }
    }
  }

  void mapGlobals(Function &SrcF, Module *TgtM, ValueToValueMapTy &VMap) const {
    Module *SrcM = SrcF.getParent();
    if (SrcM == TgtM)
      return;

    GlobalList GVs = apply<GlobalList>(SrcF, selectGV);
    for (GlobalValue *GV : GVs) {
      bool IsInternal =
          GV->getLinkage() == GlobalValue::LinkageTypes::InternalLinkage;

      GlobalValue *NewGV = TgtM->getNamedGlobal(GV->getName());
      if (NewGV)
        continue;

      if (GlobalVariable *GVar = dyn_cast<GlobalVariable>(GV)) {
        bool IsConstant = GVar->isConstant();
        GlobalVariable *NewGVar = cast<GlobalVariable>(
            TgtM->getOrInsertGlobal(GVar->getName(), GVar->getValueType()));

        NewGVar->setConstant(IsConstant);
        NewGVar->setLinkage(GlobalValue::ExternalLinkage);
        NewGVar->setUnnamedAddr(GlobalValue::UnnamedAddr::None);

        if (GVar->hasInitializer())
          NewGVar->setInitializer(GVar->getInitializer());
        NewGVar->setAlignment(GVar->getAlignment());
        NewGVar->setThreadLocalMode(GVar->getThreadLocalMode());
        NewGVar->setVisibility(GVar->getVisibility());

        if (IsInternal) {
          /* We need to change the visibility of the original symbol to
           * external visible for the weak_odr linkage to work.
           *
           * Example:
           *   Global variable declared static:
           *   static int A[10];
           *
           * To avoid name collisions we will rename the symbol before
           * we remap it.
           */

          using namespace std::chrono;
          milliseconds Ms = duration_cast<milliseconds>(
              system_clock::now().time_since_epoch());
          GV->setName(GV->getName() + "_POLYJIT_GLOBAL_" + fmt::format("{:d}", Ms.count()));
          GV->setLinkage(GlobalValue::LinkageTypes::ExternalLinkage);
        }

        NewGVar->setName(GV->getName());

        if (IsConstant)
          NewGVar->setLinkage(GVar->getLinkage());
        else
          NewGVar->setLinkage(GlobalValue::LinkageTypes::AvailableExternallyLinkage);

        if (!IsConstant) {
          if (NewGVar->getValueType()->isAggregateType()) {
            NewGVar->setInitializer(
                ConstantAggregateZero::get(GVar->getValueType()));
          } else {
            NewGVar->setInitializer(
                Constant::getNullValue(GVar->getValueType()));
          }
        }
        VMap[GV] = NewGVar;
      }
    }
  }
};

/*
 * Cloning policies.
 */
struct CopyCreator {
  void MapArguments(ValueToValueMapTy &VMap, Function *SrcF, Function *TgtF) {
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
  void Apply(Function *From, Function *To, ValueToValueMapTy &VMap) {
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
} // namespace polli
#undef DEBUG_TYPE
#endif // POLLI_FUNCTIONCLONER_H
