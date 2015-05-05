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

#include "spdlog/spdlog.h"
#include <map>

namespace {
auto Console = spdlog::stderr_logger_st("polli");
}

void getRuntimeParameters(Function *F, unsigned paramc, void *params,
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
        P.Val = ConstantInt::get(IntTy, *((uint8_t **)params)[i]);
        break;
      case 16:
        P.Val = ConstantInt::get(IntTy, *((uint16_t **)params)[i]);
        break;
      case 32:
        P.Val = ConstantInt::get(IntTy, *((uint32_t **)params)[i]);
        break;
      case 64:
        P.Val = ConstantInt::get(IntTy, *((uint64_t **)params)[i]);
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
  Console->warn("variant generated");

  return Variant;
}

/**
 * @brief  Convert srcF signature into a 'main' function format,
 * i.e. f(int argc, char** argv). This way the parameters can be passed by
 * the MCJIT while it does not support real parameter passing at run time.
 *
 * The parameters are unpacked inside the function again, maybe it does not
 * get too inefficient ;-).
 */
struct MainCreator {
  /**
   * @brief Unpack the parameters from the array onto the stack. O2 version.
   *
   * @param Builder IRBuilder we use to create the unpack stuff.
   * @param VMap Value-to-Value map to track rewritten arguments.
   * @param SrcF Source function we convert to main() format.
   * @param TgtF Target function we convert into.
   */
  static void CreateUnpackParamsO2(IRBuilder<> &Builder,
                                   ValueToValueMapTy &VMap, Function *SrcF,
                                   Function *TgtF) {
    // 2nd argument is our array, 1st is argc
    Function::arg_iterator TgtArg = TgtF->arg_begin();
    Argument *ArgC = TgtArg;
    Value *ArgV = ++TgtArg;

    ArgC->setName("argc");
    ArgV->setName("argv");

    // Unpack params. Allocate space on the stack and store the pointers.
    // TODO:This is very inefficient.
    // Some parameters are not required anymore.
    LLVMContext &Ctx = Builder.getContext();
    unsigned i = 0;
    for (Argument &Arg : SrcF->args()) {
      Value *Idx0 = ConstantInt::get(Type::getInt32Ty(Ctx), 0);
      Value *IdxI = ConstantInt::get(Type::getInt8Ty(Ctx), i++);

      Type *ArgTy = Arg.getType();
      Value *ArrIdx =
          Builder.CreateInBoundsGEP(ArgV, { Idx0, IdxI }, "pprof.param.idx");
      Value *LoadArr = Builder.CreateLoad(ArrIdx);
      Value *CastVal = Builder.CreateBitCast(LoadArr, ArgTy);
      VMap[&Arg] = CastVal;
    }
  }

  /**
   * @brief Map arguments from an array back to single values.
   *
   * @param VMap Value-To-Value tracker.
   * @param SrcF Source function.
   * @param TgtF Target function.
   */
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    LLVMContext &Context = TgtF->getContext();
    IRBuilder<> Builder(Context);

    BasicBlock *EntryBB = BasicBlock::Create(Context, "entry.param", TgtF);
    Builder.SetInsertPoint(EntryBB);

    CreateUnpackParamsO2(Builder, VMap, SrcF, TgtF);
  }

  /**
   * @brief Create a new target function to perform the main creator policy on.
   *
   * @param SrcF Source function to create a main-version from.
   * @param TgtM Target module to create the new function into.
   *
   * @return A new function, with main()-compatible signature.
   */
  static Function *Create(Function *SrcF, Module *TgtM) {
    LLVMContext &Ctx = TgtM->getContext();
    Type *RetType = IntegerType::getInt32Ty(Ctx);
    PointerType *PtoArr = ArrayType::get(Type::getInt8PtrTy(Ctx),
                                         SrcF->arg_size())->getPointerTo();

    Function *F = cast<Function>(TgtM->getOrInsertFunction(
        SrcF->getName(), RetType, Type::getInt32Ty(Ctx), PtoArr, NULL));

    F->setLinkage(SrcF->getLinkage());
    return F;
  }
};

//===----------------------------------------------------------------------===//
// SpecializeEndpoint policy.
//
// Specializes the endpoint with a list of parameter values.
// All uses of the a Value are replaced with the parameter value associated
// to this value.
//
template <class ParamT> class SpecializeEndpoint {
private:
  ParamVector<ParamT> SpecValues;

public:
  void setParameters(ParamVector<ParamT> const &Values) { SpecValues = Values; }

  Function::arg_iterator getArgument(Function *F, StringRef ArgName) {
    Function::arg_iterator result = F->arg_begin(), end = F->arg_end();

    // 'Cheap' find
    while (result != end && result->getName() != ArgName)
      ++result;

    return result;
  }

  /**
   * @brief TODO: Add comments here.
   *
   * @param AllValues
   * @param TgtF
   *
   * @return
   */
  ParamVector<ParamT> getSpecValues(ParamVector<ParamT> &AllValues,
                                    Function *TgtF) {
    return SpecVals(AllValues.size());
  }

  /**
   * @brief Apply the parameter value specialization in the endpoint.
   *
   * It is necessary that SpecValues is already set. Next we align the
   * specialization values with the formal function arguments and substitute
   * all uses of this argument with a constant representing the specialization
   * value.
   *
   * @param TgtF The function we specialize.
   * @param SrcF Our source function.
   * @param VMap A value-to-value map that tracks cloned values/function args.
   */
  void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &VMap) {
    // Connect Entry block of TgtF with Cloned version of SrcF's entry block.
    LLVMContext &Context = TgtF->getContext();
    IRBuilder<> Builder(Context);
    BasicBlock *EntryBB = &TgtF->getEntryBlock();
    BasicBlock *SrcEntryBB = &SrcF->getEntryBlock();
    BasicBlock *ClonedEntryBB = cast<BasicBlock>(VMap[SrcEntryBB]);

    Builder.SetInsertPoint(EntryBB);
    Builder.CreateBr(ClonedEntryBB);

    for (unsigned i = 0; i < SpecValues.size(); ++i) {
      ParamT P = SpecValues[i];
      Function::arg_iterator Arg = getArgument(SrcF, P.Name);

      // Could not find the argument, should not happen.
      if (Arg == TgtF->arg_end())
        continue;

      // Get a constant value for P.
      if (Constant *Replacement = P.Val) {
        Value *NewArg = VMap[Arg];

        if (!isa<Constant>(NewArg))
          NewArg->replaceAllUsesWith(Replacement);
      }
    }

    /** FIXME: This requires the usage of MainCreator policy.
     *
     * We assume that we use the MainCreator policy, so we replace all
     * returns with return 0;
     *
     * @name MainCreator policy interface required.
     * @{ */
    Constant *Zero = ConstantInt::get(IntegerType::getInt32Ty(Context), 0);
    for (Function::iterator BB = TgtF->begin(), BE = TgtF->end(); BB != BE;
         ++BB)
      if (ReturnInst *Ret = dyn_cast<ReturnInst>(BB->getTerminator())) {
        ReplaceInstWithInst(Ret, ReturnInst::Create(Context, Zero));
      }
    /**  @} */
  }
};


/**
 * @brief Create a new variant of this function using the function key K.
 *
 * This creates a copy of the existing prototype function and substitutes
 * all uses of K's name with K's value.
 *
 * @param K the function key K we want to substitute in.
 *
 * @return a copy of the base function, with the values of K substituted.
 */
Function *VariantFunction::createVariant(const FunctionKey &K) {
  ValueToValueMapTy VMap;

  /* Copy properties of our source module */
  Module *M, *NewM;
  Console->warn("creating new variant for key: {:>s}", K.getShortName().str());

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
