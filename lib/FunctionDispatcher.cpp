//===-- FunctionDispatcher.cpp ----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#include "polli/FunctionDispatcher.h"
#include "polly/LinkAllPasses.h"

RTParams getRuntimeParameters(Function *F, unsigned paramc, char **params) {
  RTParams RuntimeParams;
  int i = 0;
  for (Function::arg_iterator Arg = F->arg_begin(), ArgE = F->arg_end();
       Arg != ArgE; ++Arg, ++i) {
    Type *ArgTy = Arg->getType();

    /* TODO: Add more types to be suitable for spawning new functions. */
    if (IntegerType *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      APInt val =
          APInt(IntTy->getBitWidth(), (uint64_t)(*(uint64_t *)params[i]),
                IntTy->getSignBit());
      RuntimeParams.push_back(RuntimeParam(val, IntTy, Arg->getName()));
    }
  }

  return RuntimeParams;
}
