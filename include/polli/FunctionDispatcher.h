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

/**
 * @brief Store parameter values for later use.
 *
 * Deprecated: Use variant functions and the Param struct instead.
 */
template <class StorageT, class TypeT> struct RTParam {

  /**
   * @brief Create a new RTParam with StorageT and Param value type
   *
   * @param val
   * @param type
   * @param name
   */
  explicit RTParam(StorageT val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  /**
   * @name lt/gt operators for RTParams
   * @{ */
  bool operator<(RTParam const &rhs) { return Value < rhs.Value; }
  bool operator<(RTParam const &rhs) const { return Value < rhs.Value; }

  bool operator>(RTParam const &rhs) { return Value > rhs.Value; }
  bool operator>(RTParam const &rhs) const { return Value > rhs.Value; }
  /**  @} */

  /**
   * @brief Print this parameter
   *
   * @param out the ostream we print into
   */
  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }

  /**
   * @brief Get this parameter as constant
   *
   * @return a constant representing this param
   */
  Constant *getAsConstant() const { return NULL; }

  /**
   * @brief Getter for this argument
   *
   * @return name of this argument
   */
  StringRef &getName() { return Name; }

private:
  StorageT Value;
  TypeT *Type;
  StringRef Name;
};

/**
 * @brief Print RTParams to a stream
 *
 * @param out raw_ostream to print into
 * @param p param to print
 *
 * @return raw_ostream we printed into
 */
template <class StorageT, class TypeT>
raw_ostream &operator<<(raw_ostream &out, const RTParam<StorageT, TypeT> &p) {
  p.print(out);
  return out;
}

/**
 * @brief Specialize to APInt. We need a special lt/gt operator there.
 */
template <class TypeT> struct RTParam<APInt, TypeT> {

  /**
   * @brief Create a new RTParam that stores APInts
   *
   * @param val the APInt we want to store.
   * @param type the type we store as APInt.
   * @param name the name we give this RTParam.
   */
  explicit RTParam(APInt val, TypeT *type, const StringRef name = "_") {
    Value = val;
    Type = type;
    Name = name;
  }

  /**
   * @name lt/gt operators for RTParams
   * @{ */
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
  /**  @} */

  /**
   * @brief Print this RTParam into an raw_ostream.
   *
   * @param out the raw_ostream we printed into.
   */
  void print(raw_ostream &out) const {
    Type->print(out);
    out << " " << Name << " = " << Value;
  }

  /**
   * @brief Get the stored value as constant.
   *
   * @return the stored value as constant.
   */
  Constant *getAsConstant() const { return ConstantInt::get(Type, Value); }

  /**
   * @brief Getter for the name property.
   *
   * @return
   */
  StringRef &getName() { return Name; }

private:
  /**
   * @brief The value we store.
   */
  APInt Value;

  /**
   * @brief The type of the argument we store.
   */
  TypeT *Type;

  /**
   * @brief The name of the param.
   */
  StringRef Name;
};

/**
 * @brief For now we only deal with APInt storage of IntegerType parameter
 * values.
 */
typedef RTParam<APInt, IntegerType> RuntimeParam;
typedef std::vector<RuntimeParam> RTParams;

/**
 * @brief The ParamVector is our key for indexing specialized functions at
 * runtime.
 */
typedef ParamVector<RuntimeParam> RTParValuesKey;

/**
 * @brief ValToFun Relation: { [Parameter values] -> [Specialized Function] }
 */
typedef std::map<RTParValuesKey, Function *> ValKeyToFunction;

/**
 * @brief Specialize Relation: { [SrcFun] -> [ValToFun] }
 */
typedef std::map<Function *, ValKeyToFunction> SpecializedFuncs;

/**
 * @brief Map instrumented function to original function.
 */
typedef std::map<std::string, Function *> FunctionNameToFunctionMapTy;

/**
 * @brief Print a set of parameters
 *
 * @param F Function, used for the name.
 * @param Params
 */
static inline void printParameters(const Function *F, RTParams &Params) {
  dbgs() << "[" << F->getName() << "] Argument-Value Table:\n";

  dbgs() << "{\n";
  for (RTParams::iterator P = Params.begin(), PE = Params.end(); P != PE; ++P) {
    dbgs() << *P << "\n";
  }
  dbgs() << "}\n";
}

/**
 * @brief Extract parameters suitable for specialization.
 *
 * Extract the set of parameter values suitable for specialization from the
 * params array. This works on functions that have been transformed into a
 * main-like structure before.
 *
 * For now this function only extracts Integer types for specialization.
 *
 * @param F The function we extract parameter values for.
 * @param paramc The number of parameters this function has.
 * @param params The array of parameters we got as input.
 * @param paramV A vector where we store the runtime parameters in.
 */
void getRuntimeParameters(Function *F, unsigned paramc, char **params,
                          std::vector<Param> &ParamV);

/**
 * @brief AliasCheckerEndpoint policy.
 *
 * Insert a run-time alias check into the extracted function. In the absence
 * of aliases we can generate more sophisticated code for this version.
 *
 * This may require to run polly with disabled alias checks just for these
 * endpoints.
 */
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

/**
 * @brief Reroute calls to a different version
 *
 * Implement a function dispatch to reroute calls to parametrized
 * functions to their possible - semintically equivalent - specializations.
 */
class FunctionDispatcher {
  FunctionDispatcher(const FunctionDispatcher &);
  const FunctionDispatcher &
  operator=(const FunctionDispatcher &);

  // Map instrumented functions to uninstrumented functions. Used to resolve
  // to the uninstrumented function when coming from the JIT callback function.
  FunctionNameToFunctionMapTy FMap;

  VariantFunctionMapTy VariantFunctions;

public:
  explicit FunctionDispatcher() {}

  /**
   * @brief Set up a mapping between an uninstrumented and an instrumented
   *        function.
   *
   * @param F Source function
   * @param MapTo Target function
   */
  void setPrototypeMapping(Function *F, Function *MapTo) {
    FMap.insert(std::make_pair(F->getName().str(), MapTo));
    //assert(Result.second && "Tried to overwrite mapping.");
  }

  /**
   * @brief Access variant functions
   *
   * @return A map of variant functions.
   */
  const VariantFunctionMapTy &functions() {
    return VariantFunctions;
  }

  /**
   * @brief Get or Create a new variant function for the given Function.
   *
   * @param F The function we get or create the variant function for.
   *
   * @return A variant function for function F
   */
  VariantFunctionTy getOrCreateVariantFunction(Function *F) {
    // We have already specialized this function at least once.
    if (VariantFunctions.count(F))
      return VariantFunctions.at(F);

    // Create a variant function & specialize a new variant, based on key.
    VariantFunctionTy VarFun =
        std::make_shared<VariantFunction>(*F, *(FMap[F->getName()]));

    VariantFunctions.insert(std::make_pair(F, VarFun));
    return VarFun;
  }
};
#endif
