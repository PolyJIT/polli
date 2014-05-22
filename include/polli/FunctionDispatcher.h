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

#include "polli/FunctionCloner.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/Utils.h"

#include "llvm/Analysis/RegionInfo.h"
#include "llvm/LinkAllPasses.h"

#include "llvm/Support/Debug.h"

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
  Constant *getAsConstant() { return NULL; }

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
}
;

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

  Constant *getAsConstant() { return ConstantInt::get(Type, Value); }

  // Get the name of this argument.
  StringRef &getName() { return Name; }

private:
  APInt Value;
  TypeT *Type;
  StringRef Name;
};

template <class RTParam> struct ParamVector {
  /* Convert a std::vector of RTParams to a ParamArray. */
  ParamVector(std::vector<RTParam> const &ParamVector) { Params = ParamVector; }
  ;

  typedef typename std::vector<RTParam>::iterator iterator;
  typedef typename std::vector<RTParam>::const_iterator const_iterator;

  iterator begin() { return Params.begin(); }
  iterator end() { return Params.end(); }

  const_iterator begin() const { return Params.cbegin(); }
  const_iterator end() const { return Params.cend(); }

  inline size_t size() const { return Params.size(); }

  RTParam &operator[](unsigned const &index) { return Params[index]; }
  ;

  const RTParam &operator[](unsigned const &index) const {
    return Params[index];
  }
  ;

  bool operator<(ParamVector<RTParam> const &rhs) {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();

    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }

  bool operator<(ParamVector<RTParam> const &rhs) const {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();

    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }

  StringRef getShortName() {
    std::string res = "";

    for (unsigned i = 0; i < Params.size(); ++i)
      if (Constant *c = Params[i].getAsConstant()) {
        const APInt &val = c->getUniqueInteger();
        SmallVector<char, 2> str;
        val.toStringUnsigned(str);
        res = res + "." + StringRef(str.data(), str.size()).str();
      }
    return res;
  }

private:
  std::vector<RTParam> Params;
};

template <class RTParam>
raw_ostream &operator<<(raw_ostream &out, const ParamVector<RTParam> &Params) {
  out << "[";
  for (size_t i = 0; i < Params.size(); ++i) {
    out << Params[i] << " ";
  }

  out << "]";
  return out;
}
;

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
typedef std::map<StringRef, Function *> FunctionNameToFunctionMapTy;

static inline void printParameters(const Function *F, RTParams &Params) {
  dbgs() << "[" << F->getName() << "] Argument-Value Table:\n";

  dbgs() << "{\n";
  for (RTParams::iterator P = Params.begin(), PE = Params.end(); P != PE; ++P) {
    dbgs() << *P << "\n";
  }
  dbgs() << "}\n";
}
;

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

template <class ParamT> class SpecializeEndpoint {
private:
  ParamVector<ParamT> *SpecValues;

public:
  void setParameters(ParamVector<ParamT> *Values) { SpecValues = Values; }

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

    for (unsigned i = 0; i < SpecValues->size(); ++i) {
      ParamT P = (*SpecValues)[i];
      Function::arg_iterator Arg = getArgument(SrcF, P.getName());

      // Could not find the argument, should not happen.
      if (Arg == TgtF->arg_end()) {
        DEBUG(dbgs() << P.getName() << " was not in the argument list of "
               << TgtF->getName() << "\n");
        continue;
      }

      // Get a constant value for P.
      Constant *replacement = P.getAsConstant();
      if (replacement) {
        Value *NewArg = VMap[Arg];
        NewArg->replaceAllUsesWith(replacement);
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
    //    PointerType *PtoArr = PointerType::get(Type::getInt8PtrTy(Context),
    // 0);

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
  FunctionDispatcher(const FunctionDispatcher &)
  LLVM_DELETED_FUNCTION;
  const FunctionDispatcher &operator=(
      const FunctionDispatcher &) LLVM_DELETED_FUNCTION;

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

public:
  explicit FunctionDispatcher() {}

  template <class ParamT>
  Function *specialize(Function *F, ParamVector<ParamT> &Values) {
    ValueToValueMapTy VMap;

    /* Copy properties of our source module */
    Module *M, *NewM;

    M = F->getParent();
    NewM = new Module(M->getModuleIdentifier(), M->getContext());
    NewM->setTargetTriple(M->getTargetTriple());
    NewM->setDataLayout(M->getDataLayout());
    NewM->setMaterializer(M->getMaterializer());
    NewM->setModuleIdentifier(
        (M->getModuleIdentifier() + "." + F->getName()).str() +
        Values.getShortName().str() + ".ll");

    FunctionCloner<MainCreator, IgnoreSource, SpecializeEndpoint<ParamT> >
    Specializer(VMap, NewM);

    // Fetch the uninstrumented function for specialization.
    Function *OrigF = NULL;
    Function *NewF = NULL;

    OrigF = FMap[F->getName()];
    if (OrigF && !OrigF->isDeclaration()) {
      Specializer.setParameters(&Values);
      Specializer.setSource(OrigF);

      NewF = Specializer.start();
      SpecializedModules.push_back(NewM);
    }

    return NewF;
  }
  ;

  /// @brief Set up a mapping between an uninstrumented and an instrumented
  //         function.
  void setPrototypeMapping(Function *F, Function *MapTo) {
    FMap[F->getName()] = MapTo;
  }

  /// @brief Get the appropriate function for the given input parameters.
  //  If it is beneficial, a specialized version for the given set
  //  of input parameters is generated.
  //
  //  Apply all necessary optimization steps here.
  template <class ParamT>
  Function *getFunctionForValues(Function *F, ParamVector<ParamT> &Values) {
    ValKeyToFunction ValToFun =
        (!SpecFuns.count(F)) ? ValKeyToFunction() : SpecFuns[F];

    /* TODO: We need to be a bit smarter than: Specialize everything. */
    if (!ValToFun.count(Values)) {
      Function *NewF = specialize(F, Values);
      RuntimeOptimizer RTOpt;

      RTOpt.Optimize(*NewF);

      ValToFun[Values] = NewF;
      SpecFuns[F] = ValToFun;
    }

    Function *SpecF = ValToFun[Values];
    DEBUG(dbgs() << "[polli] " << SpecF->getName() << " (" << Values << ")\n");
    return SpecF;
  }
};
#endif
