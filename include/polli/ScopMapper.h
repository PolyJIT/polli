//===-- ScopMapper.h - Class definition for the ScopMapper ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_SCOP_MAPPER_H 
#define POLLI_SCOP_MAPPER_H 

#include "llvm/Pass.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/Transforms/Utils/Cloning.h"

#include <set>

using namespace llvm;

namespace polli {

template
<
  class DrainPolicy,
  class SinkPolicy
>
class FunctionCloner : public DrainPolicy,
                       public SinkPolicy {
  ValueToValueMapTy &VMap;
  Module   *TgtM;
  
  Function *SrcF;
  Function *TgtF;
  
  Function *createTargetF(Module *M) {
    return Function::Create(SrcF->getFunctionType(),
                            SrcF->getLinkage(),
                            SrcF->getName(),
                            M);
  }
public:
  explicit FunctionCloner<DrainPolicy, SinkPolicy>
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
     TgtF = createTargetF(TgtM); 

    TgtF->copyAttributesFrom(SrcF);
  
    /* Copy function body ExtractedF over to ClonedF */
    Function::arg_iterator NewArg = TgtF->arg_begin();
    for (Function::const_arg_iterator
         Arg = SrcF->arg_begin(), AE = SrcF->arg_end(); Arg != AE; ++Arg) {
      NewArg->setName(Arg->getName());
      VMap[Arg] = NewArg++;
    }
  
    SmallVector<ReturnInst*, 8> Returns;
    CloneFunctionInto(TgtF, SrcF, VMap,/* ModuleLevelChanges=*/false, Returns);

    // No need for the mapping anymore.
    for (Function::const_arg_iterator
         Arg = SrcF->arg_begin(), AE = SrcF->arg_end(); Arg != AE; ++Arg) {
      VMap.erase(Arg);
    }
    
    // Store function mapping for the linker.
    VMap[SrcF] = TgtF;
    
    DrainPolicy::Apply(SrcF, &VMap);
    SinkPolicy::Apply(TgtF, &VMap);

    return TgtF;
  }
};


/* 
 * Endpoint policies for the function cloner host.
 */
struct IgnoreSource {
  static void Apply(Function *SrcF, ValueToValueMapTy* VMap = NULL) {
    /* Do nothing */
  };
};

struct IgnoreTarget {
  static void Apply(Function *TgtF, ValueToValueMapTy* VMap = NULL) {
    /* Do nothing */
  };
};

struct DestroyEndpoint {
  static void Apply(Function* EndPoint, ValueToValueMapTy* VMap = NULL) {
    EndPoint->deleteBody();
    VMap->erase(EndPoint);
  }
};

struct InstrumentEndpoint {
  static void Apply(Function *EndPoint, ValueToValueMapTy* VMap = NULL) {
    if (EndPoint->isDeclaration())
      return;
    
    Module *M = EndPoint->getParent();
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
    BasicBlock *BB = EndPoint->begin();
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
    int argc = EndPoint->arg_size();
    Value *ParamC = ConstantInt::get(Type::getInt32Ty(Ctx), argc, true);
    Value *Params = Builder.CreateAlloca(Type::getInt8PtrTy(Ctx),
                                         ParamC, "params");
    /* Store each parameter as pointer in the params array */
    int i = 0;
    Value *One    = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
    for (Function::arg_iterator Arg = EndPoint->arg_begin(),
                                ArgE = EndPoint->arg_end();
                                Arg != ArgE; ++Arg) {

      /* Allocate a slot on the stack for the i'th argument and store it */
      Value *Slot   = Builder.CreateAlloca(Arg->getType(), One,
                                           "params." + Twine(i));
      Builder.CreateAlignedStore(Arg, Slot, 4);
     
      /* Bitcast the allocated stack slot to i8* */
      Value *Slot8 = Builder.CreateBitCast(Slot, Type::getInt8PtrTy(Ctx),
                                           "ps.i8ptr." + Twine(i)); 
        
      /* Get the appropriate slot in the parameters array and store
       * the stack slot in form of a i8*. */
      Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i);
      Value *Dest   = Builder.CreateGEP(Params, ArrIdx, "p." + Twine(i));
      Builder.CreateAlignedStore(Slot8, Dest, 8); 

      i++;
    }

    Args[0] = Builder.CreateGlobalStringPtr(EndPoint->getName());
    Args[1] = ParamC;
    Args[2] = Params;

    Builder.CreateCall(PJITCB, Args);
  }
};

typedef FunctionCloner<IgnoreSource, IgnoreTarget> DefaultFunctionCloner;
typedef FunctionCloner<DestroyEndpoint, IgnoreTarget> MovingFunctionCloner;
typedef FunctionCloner<IgnoreSource,
                       InstrumentEndpoint> InstrumentingFunctionCloner;

class ScopMapper : public FunctionPass {
public:
  typedef std::set<Function *> FunctionSet;
  typedef FunctionSet::iterator iterator;

  iterator begin() { return CreatedFunctions.begin(); }
  iterator end() { return CreatedFunctions.end(); }

  typedef std::set<Module *> ModuleSet;
  typedef ModuleSet::iterator module_iterator;

  module_iterator modules_begin() { return CreatedModules.begin(); }
  module_iterator modules_end() { return CreatedModules.end(); }

  static char ID;
  explicit ScopMapper() : FunctionPass(ID) {}
  
  void moveFunctionIntoModule(Function *F, Module *Dest);

  /// @name FunctionPass interface
  //@{
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  virtual void releaseMemory() {};
  virtual bool runOnFunction(Function &F);
  virtual void print(raw_ostream &OS, const Module *) const {};
  //@}
private:
  //===--------------------------------------------------------------------===//
  // DO NOT IMPLEMENT
  ScopMapper(const ScopMapper&);
  // DO NOT IMPLEMENT
  const ScopMapper &operator=(const ScopMapper &);

  ValueToValueMapTy VMap;
  
  Module *M;
  FunctionSet CreatedFunctions;
  ModuleSet CreatedModules;
};
}
#endif //POLLI_SCOP_MAPPER_H
