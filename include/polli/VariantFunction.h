#ifndef POLLI_VARIANTFUNCTION_H
#define POLLI_VARIANTFUNCTION_H

#include "llvm/IR/Function.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include "polli/RuntimeValues.h"

#include <unordered_map>
#include <vector>
#include <memory>

namespace polli {

template <class P> class ParamVector {
private:
  std::vector<P> Params;

public:
  ParamVector(std::vector<P> const &&ParamVector)
      : Params(std::move(ParamVector)) {}

  // @brief Default empty constructor
  ParamVector() {}

  // @brief Copy ctor
  ParamVector(const ParamVector &Other) : Params(Other.Params) {}

  // @brief Copy assignment
  ParamVector &operator=(const ParamVector &Other) {
    if (this != &Other)
      Params = Other.Params;
    return *this;
  }

  // @brief Destructor
  ~ParamVector() { Params.clear(); }

  typedef typename std::vector<P>::iterator iterator;
  typedef typename std::vector<P>::const_iterator const_iterator;

  iterator begin() { return Params.begin(); }
  iterator end() { return Params.end(); }

  const_iterator begin() const { return Params.cbegin(); }
  const_iterator end() const { return Params.cend(); }

  inline size_t size() const { return Params.size(); }

  P &operator[](unsigned const &index) { return Params[index]; }
  const P &operator[](unsigned const &index) const { return Params[index]; }

  bool operator<(ParamVector<P> const &rhs) {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();

    if (n == 0)
      return false;

    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }

  bool operator<(ParamVector<P> const &rhs) const {
    bool isLess = false;
    bool isGrtr = false;
    unsigned i = 0;
    unsigned n = Params.size();

    if (n == 0)
      return false;

    do {
      isLess = Params[i] < rhs[i];
      isGrtr = Params[i] > rhs[i];
      ++i;
    } while ((isLess || !isGrtr) && (i < n));

    return isLess;
  }

  llvm::StringRef getShortName() const {
    std::string res = "";

    for (unsigned i = 0; i < Params.size(); ++i)
      if (llvm::Constant *c = Params[i].Val) {
        const llvm::APInt &val = c->getUniqueInteger();
        llvm::SmallVector<char, 2> str;
        val.toStringUnsigned(str);
        res = res + "." + llvm::StringRef(str.data(), str.size()).str();
      }
    return res;
  }
};

struct Param {
  /// @brief The type of this runtime param
  llvm::Type *Ty;

  /// @brief The runtime value assigned to this param.
  llvm::Constant *Val;

  /// @brief The argument name we are assigned to
  llvm::StringRef Name;

  bool operator<(const Param &RHS) const { return Val < RHS.Val; }

  bool operator>(const Param &RHS) const { return Val > RHS.Val; }
};

typedef ParamVector<Param> FunctionKey;

struct Stats {
  // PAPI_flops(...)
  float RealTime;
  float ProcTime;
  float MFLOPS;

  long long flpops;
  // PAPI_flops(...)

  // libpprof
  long long ExecCount;

  explicit Stats()
      : RealTime(0.0f), ProcTime(0.0f), MFLOPS(0.0f), flpops(0), ExecCount(0) {}

  Stats(const Stats &Other)
      : RealTime(Other.RealTime), ProcTime(Other.ProcTime),
        MFLOPS(Other.MFLOPS), flpops(Other.flpops), ExecCount(Other.ExecCount) {
  }
  Stats &operator=(const Stats &Other) {
    if (this != &Other) {
      RealTime = Other.RealTime;
      ProcTime = Other.ProcTime;
      MFLOPS = Other.MFLOPS;
      flpops = Other.flpops;
      ExecCount = Other.ExecCount;
    }
    return *this;
  }
};

class VariantFunction {
private:
  using VariantsT = std::unordered_map<size_t, llvm::Function *>;

  // @brief Track various stats about this function;
  Stats S;

  // @brief Our base function to create new variants from.
  llvm::Function &BaseF;

  // @brief Our source function. This is the function that contained
  // the call to our JIT environment.
  llvm::Function &SourceF;

  // @brief All variants of our base function, indexed by key.
  //
  // We index the variants with the key we form from our specialzed param
  // vector.
  VariantsT Variants;

  // @brief Create a new function variant with they values included in the
  // key replaced.
  llvm::Function *createVariant(const RunValueList &K);

protected:
  llvm::Function &getBaseFunction() const { return BaseF; }
  llvm::Function &getSourceFunction() const { return SourceF; }

  VariantsT getVariants() const {
    return Variants;
  }

public:
  /**
   * @brief Create a new variant function.
   *
   * Variant functions have a base function and a source function.
   * The source function signals from which function it derives (the function
   * that is called and rerouted to this variant).
   * The base function represents the function code without instrumentation.
   *
   * @param BaseF
   * @param SourceF
   */
  explicit VariantFunction(llvm::Function &BaseF, llvm::Function &SourceF)
      : BaseF(BaseF), SourceF(SourceF) {}

  /**
   * @brief Print header for variant functions.
   *
   * @param OS
   */
  static void printHeader(llvm::raw_ostream &OS);

  /**
   * @brief Print statistics about this variant function.
   *
   * @param OS
   */
  void print(llvm::raw_ostream &OS);

  /**
   * @brief Return a reference to our statistics.
   *
   * @return
   */
  Stats &stats() { return S; }

  /**
   * @brief Return or create a new variant for this function with a given key
   *
   * @param K
   *
   * @return
   */
  llvm::Function *getOrCreateVariant(const RunValueList &K);

  ~VariantFunction() { Variants.clear(); }
  /**  @} */
private:
  void printVariants(llvm::raw_ostream &OS);

};

using VariantFunctionTy = std::shared_ptr<VariantFunction>;
using VariantFunctionMapTy =
    std::unordered_map<llvm::Function *, std::shared_ptr<VariantFunction>>;

llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Param &P);
llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const ParamVector<Param> &Params);
llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const RunValueList &Params);
}
#endif // POLLI_VARIANTFUNCTION_H
