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
    i++;
    Type *ArgTy = Arg.getType();

    /* TODO: Add more types to be suitable for spawning new functions. */
    if (IntegerType *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      Param P;
      P.Ty = IntTy;
      P.Name = Arg.getName();
      P.Val = ConstantInt::get(IntTy, *params[i], true);

      ParamV.push_back(P);
    }
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
  M = SourceF->getParent();
  NewM = new Module(M->getModuleIdentifier(), M->getContext());
  NewM->setTargetTriple(M->getTargetTriple());
  NewM->setDataLayout(M->getDataLayout());
  NewM->setMaterializer(M->getMaterializer());
  NewM->setModuleIdentifier(
      (M->getModuleIdentifier() + "." + SourceF->getName()).str() +
      K.getShortName().str() + ".ll");

  // Perform parameter value substitution.
  FunctionCloner<MainCreator, IgnoreSource, SpecializeEndpoint<Param>>
      Specializer(VMap, NewM);

  assert(!BaseF->isDeclaration() && "Uninstrumented function is a declaration");

  /* Perform a parameter specialization by taking the unchanged base function
   * and substitute all known parameter values.
   */
  Function *NewF;

  Specializer.setParameters(K);
  Specializer.setSource(SourceF);
  NewF = Specializer.start();

  RuntimeOptimizer RTOpt;
  RTOpt.Optimize(*NewF);

  DEBUG(log(Info, 2) << " specialize :: " << NewF->getName() << " (" << K
                     << ")\n");
  return NewF;
}
