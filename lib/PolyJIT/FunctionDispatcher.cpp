//===-- FunctionDispatcher.cpp ----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#include "polli/FunctionDispatcher.h"

#include "llvm/IR/Function.h"
#include "llvm/Support/Casting.h"

#include <map>

void getRuntimeParameters(Function *F, unsigned paramc, char **params,
                          std::vector<Param> &ParamV) {
  int i = 0;
  for (const Argument &Arg : F->args()) {
    Type *ArgTy = Arg.getType();

    /* TODO: Add more types to be suitable for spawning new functions. */
    if (IntegerType *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      Param P;
      P.Ty = IntTy;
      P.Name = Arg.getName();
      switch(IntTy->getBitWidth()) {
      case 8:
        P.Val = ConstantInt::get(IntTy, *(uint8_t *)params[i], true);
        break;
      case 16:
        P.Val = ConstantInt::get(IntTy, *(uint16_t *)params[i], true);
        break;
      case 32:
        P.Val = ConstantInt::get(IntTy, *(uint32_t *)params[i], true);
        break;
      case 64:
        P.Val = ConstantInt::get(IntTy, *(uint64_t *)params[i], true);
        break;
      }

      ParamV.push_back(P);
    }
    i++;
  }
}

Function *VariantFunction::getOrCreateVariant(const FunctionKey &K) {
  if (Variants.count(K))
    return Variants[K];

  Function *Variant = createVariant(K);
  Variants[K] = Variant;

  return Variant;
}

Function *VariantFunction::createVariant(const FunctionKey &K) {
  ValueToValueMapTy VMap;

  /* Copy properties of our source module */
  Module *M, *NewM;

  // Prepare a new module to hold our new function.
  M = SourceF.getParent();
  NewM = new Module(M->getModuleIdentifier(), M->getContext());
  NewM->setTargetTriple(M->getTargetTriple());
  NewM->setDataLayout(M->getDataLayout());
  NewM->setMaterializer(M->getMaterializer());
  NewM->setModuleIdentifier(
      (M->getModuleIdentifier() + "." + SourceF.getName()).str() +
      K.getShortName().str() + ".ll");

  // Perform parameter value substitution.
  FunctionCloner<MainCreator, IgnoreSource, SpecializeEndpoint<Param>>
      Specializer(VMap, NewM);

  assert(!BaseF->isDeclaration() && "Uninstrumented function is a declaration");

  /* Perform a parameter specialization by taking the unchanged base function
   * and substitute all known parameter values.
   */
  Specializer.setParameters(K);
  Specializer.setSource(&SourceF);

  return &(OptimizeForRuntime(*Specializer.start()));
}
