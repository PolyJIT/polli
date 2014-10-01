//===-- FunctionDispatcher.h ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_FUNCTION_DISPATCHER_H
#define POLLI_FUNCTION_DISPATCHER_H

#define DEBUG_TYPE "polyjit"

#include "polli/FunctionCloner.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/Utils.h"
#include "polli/VariantFunction.h"

#include "llvm/Analysis/RegionInfo.h"
#include "llvm/LinkAllPasses.h"

#include "llvm/Support/Debug.h"
#include <memory>

using namespace polli;

template <class StorageT, class TypeT> struct RTParam {
  explicit RTParam(StorageT val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  bool operator<(RTParam const &rhs) { return Value < rhs.Value; }
  bool operator<(RTParam const &rhs) const { return Value < rhs.Value; }

  bool operator>(RTParam const &rhs) { return Value > rhs.Value; }
  bool operator>(RTParam const &rhs) const { return Value > rhs.Value; }

  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }

  // Not implemented. Specialize me.
  Constant *getAsConstant() const { return NULL; }

  // Get the name of this argument.
  StringRef &getName() { return Name; }

private:
  StorageT Value;
  TypeT *Type;
  StringRef Name;
};

template <class StorageT, class TypeT>
raw_ostream &operator<<(raw_ostream &out, const RTParam<StorageT, TypeT> &p) {
  p.print(out);
  return out;
};

/* Specialize to APInt. We do not have a proper lt operator there. */
template <class TypeT> struct RTParam<APInt, TypeT> {
  explicit RTParam(APInt val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  bool operator<(RTParam<APInt, TypeT> const &rhs) {
    return Value.ult(rhs.Value);
  }

  bool operator<(RTParam<APInt, TypeT> const &rhs) const {
    return Value.ult(rhs.Value);
  }

  bool operator>(RTParam<APInt, TypeT> const &rhs) {
    return Value.ugt(rhs.Value);
  }

  bool operator>(RTParam<APInt, TypeT> const &rhs) const {
    return Value.ugt(rhs.Value);
  }

  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }

  Constant *getAsConstant() const { return ConstantInt::get(Type, Value); }

  // Get the name of this argument.
  StringRef &getName() { return Name; }

private:
  APInt Value;
  TypeT *Type;
  StringRef Name;
};

/* For now we only deal with APInt storage of IntegerType parameter values. */
typedef RTParam<APInt, IntegerType> RuntimeParam;
typedef std::vector<RuntimeParam> RTParams;

/* The ParamVector is our key for indexing specialized functions at runtime. */
typedef ParamVector<RuntimeParam> RTParValuesKey;

/* ValToFun Relation: { [Parameter values] -> [Specialized Function] } */
typedef std::map<RTParValuesKey, Function *> ValKeyToFunction;
/* Specialize Relation: { [SrcFun] -> [ValToFun] } */
typedef std::map<Function *, ValKeyToFunction> SpecializedFuncs;

/* Map instrumented function to original function. */
typedef std::map<std::string, Function *> FunctionNameToFunctionMapTy;

static inline void printParameters(const Function *F, RTParams &Params) {
  dbgs() << "[" << F->getName() << "] Argument-Value Table:\n";

  dbgs() << "{\n";
  for (RTParams::iterator P = Params.begin(), PE = Params.end(); P != PE; ++P) {
    dbgs() << *P << "\n";
  }
  dbgs() << "}\n";
}

// @brief Extract parameters suitable for specialization.
//
// Extract the set of parameter values suitable for specialization from the
// params array. This works on functions that have been transformed into a
// main-like structure before.
//
// For now this function only extracts Integer types for specialization.
//
// @param F The function we extract parameter values for.
// @param paramc The number of parameters this function has.
// @param params The array of parameters we got as input.
// @param paramv A vector where we store the runtime parameters in.
void getRuntimeParameters(Function *F, unsigned paramc, char **params,
                          std::vector<Param> &ParamV);

//===----------------------------------------------------------------------===//
// AliasCheckerEndpoint policy.
//
// Insert a run-time alias check into the extracted function. In the absence
// of aliases we can generate more sophisticated code for this version.
//
// This may require to run polly with disabled alias checks just for these
// endpoints.
//
template <class ParamT> class AliasCheckerEndpoint {
private:
  AliasSet &AS;

public:
  // @brief Set the alias set for which we need to generate alias checks.
  //
  // @param Aliases The alias set to generate alias checks for.
  void setAliasSet(AliasSet &Aliases);

  void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &VMap);
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

  ParamVector<ParamT> getSpecValues(ParamVector<ParamT> &AllValues,
                                    Function *TgtF) {
    ParamVector<ParamT> SpecVals(AllValues.size());
    Module *M = TgtF->getParent();
    FunctionPassManager *FPM = new FunctionPassManager(M);
    FunctionPass *RI = llvm::createRegionInfoPass();

    FPM->add(RI);
    FPM->run(*TgtF);

    delete FPM;
    delete RI;

    return SpecVals;
  }

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

    // We assume that we use the MainCreator policy, so we replace all
    // returns with return 0;
    Constant *Zero = ConstantInt::get(IntegerType::getInt32Ty(Context), 0);
    for (Function::iterator BB = TgtF->begin(), BE = TgtF->end(); BB != BE;
         ++BB)
      if (ReturnInst *Ret = dyn_cast<ReturnInst>(BB->getTerminator())) {
        ReplaceInstWithInst(Ret, ReturnInst::Create(Context, Zero));
      }
  }
};

// Convert srcF signature into a 'main' function format,
// i.e. f(int argc, char** argv). This way the parameters can be passed by
// the MCJIT while it does not support real parameter passing at run time.
//
// The parameters are unpacked inside the function again, maybe it does not
// get too inefficient ;-).
struct MainCreator {
  static void CreateUnpackParamsO2(IRBuilder<> &Builder,
                                   ValueToValueMapTy &VMap, Function *SrcF,
                                   Function *TgtF) {
    // 2nd argument is our array, 1st is argc
    Function::const_arg_iterator Arg = SrcF->arg_begin();
    Function::arg_iterator TgtArg = TgtF->arg_begin();
    Argument *ArgC = TgtArg;
    Value *ArgV = ++TgtArg;

    ArgC->setName("argc");
    ArgV->setName("argv");

    // Unpack params. Allocate space on the stack and store the pointers.
    // This is very inefficient, because some parameters are not required
    // anymore.
    for (unsigned i = 0; i < SrcF->arg_size(); ++i) {
      Type *ArgTy = Arg->getType();
      Value *ArrIdx =
          Builder.CreateConstInBoundsGEP2_64(ArgV, 0, i, "arrayidx");
      Value *LoadArr = Builder.CreateLoad(ArrIdx);
      Value *CastVal = Builder.CreateBitCast(LoadArr, ArgTy->getPointerTo());

      CastVal = Builder.CreateLoad(CastVal);

      VMap[Arg++] = CastVal;
    }
  }

  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    LLVMContext &Context = TgtF->getContext();
    IRBuilder<> Builder(Context);

    BasicBlock *EntryBB = BasicBlock::Create(Context, "entry.param", TgtF);
    Builder.SetInsertPoint(EntryBB);

    CreateUnpackParamsO2(Builder, VMap, SrcF, TgtF);
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    LLVMContext &Context = TgtM->getContext();
    Type *RetType = IntegerType::getInt32Ty(Context);
    ArrayType *PtoArr =
        ArrayType::get(Type::getInt8PtrTy(Context), SrcF->arg_size());

    Constant *C = TgtM->getOrInsertFunction(SrcF->getName(), RetType,
                                            Type::getInt32Ty(Context),
                                            PointerType::get(PtoArr, 0), NULL);

    Function *F = cast<Function>(C);
    F->setLinkage(SrcF->getLinkage());
    return F;
  }
};

//===----------------------------------------------------------------------===//
/// @brief Implement a function dispatch to reroute calls to parametrized
/// functions to their possible specializations.
class FunctionDispatcher {
  FunctionDispatcher(const FunctionDispatcher &) LLVM_DELETED_FUNCTION;
  const FunctionDispatcher &
  operator=(const FunctionDispatcher &) LLVM_DELETED_FUNCTION;

  // FIXME: OLD STUFF ->
  /// @brief Maps source Functions to specialized functions,
  //         based on the input parameters.
  SpecializedFuncs SpecFuns;

  /// @brief Store all specialized modules.
  //         We want to store each specialized functions in a separate module.
  //         TODO: Maybe we will need a mapping from Source Function
  //               to all modules of it's specializations.
  std::vector<Module *> SpecializedModules;

  // Map instrumented functions to uninstrumented functions. Used to resolve
  // to the uninstrumented function when coming from the JIT callback function.
  FunctionNameToFunctionMapTy FMap;
  // FIXME: OLD STUFF <-

  VariantFunctionMapTy VariantFunctions;

public:
  explicit FunctionDispatcher() {}

  template <class ParamT>
  Function *replaceParamValues(Function *F, ValueToValueMapTy &VMap, Module *M,
                               ParamVector<ParamT> const &Values) {
    FunctionCloner<MainCreator, IgnoreSource, SpecializeEndpoint<ParamT>>
        Specializer(VMap, M);

    // Fetch the uninstrumented function for specialization.
    Function *OrigF = nullptr;

    OrigF = FMap[F->getName()];

    assert(OrigF && "No uninstrumented function found in function map.");
    assert(!OrigF->isDeclaration() &&
           "Uninstrumented function is a declaration");

    Specializer.setParameters(Values);
    Specializer.setSource(OrigF);

    return Specializer.start();
  }

  template <class ParamT>
  Function *specialize(Function *F, ParamVector<ParamT> const &Values) {
    ValueToValueMapTy VMap;

    /* Copy properties of our source module */
    Module *M, *NewM;

    // Prepare a new module to hold our new functions.
    M = F->getParent();
    NewM = new Module(M->getModuleIdentifier(), M->getContext());
    NewM->setTargetTriple(M->getTargetTriple());
    NewM->setDataLayout(M->getDataLayout());
    NewM->setMaterializer(M->getMaterializer());
    NewM->setModuleIdentifier(
        (M->getModuleIdentifier() + "." + F->getName()).str() +
        Values.getShortName().str() + ".ll");

    // Perform parameter value substitution.
    Function *NewF = replaceParamValues(F, VMap, NewM, Values);

    SpecializedModules.push_back(NewM);

    return NewF;
  }

  /// @brief Set up a mapping between an uninstrumented and an instrumented
  //         function.
  void setPrototypeMapping(Function *F, Function *MapTo) {
    auto Result = FMap.insert(std::make_pair(F->getName().str(), MapTo));
    assert(Result.second && "Tried to overwrite mapping.");
  }

  const VariantFunctionMapTy &functions() {
    return VariantFunctions;
  }

  /// @brief Get or Create a new variant function for the given Function.
  VariantFunctionTy getOrCreateVariantFunction(Function *F) {
    // We have already specialized this function at least once.
    if (VariantFunctions.count(F))
      return VariantFunctions.at(F);

    // Create a variant function & specialize a new variant, based on key.
    VariantFunctionTy VarFun =
        std::make_shared<VariantFunction>(F, FMap[F->getName()]);

    VariantFunctions.insert(std::make_pair(F, VarFun));
    return VarFun;
  }
};
#endif
