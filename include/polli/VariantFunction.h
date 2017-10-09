#ifndef POLLI_VARIANTFUNCTION_H
#define POLLI_VARIANTFUNCTION_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "polli/RuntimeValues.h"

#include <memory>
#include <unordered_map>
#include <vector>

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
    bool IsLess = false;
    bool IsGrtr = false;
    unsigned I = 0;
    unsigned N = Params.size();

    if (N == 0)
      return false;

    do {
      IsLess = Params[I] < rhs[I];
      IsGrtr = Params[I] > rhs[I];
      ++I;
    } while ((IsLess || !IsGrtr) && (I < N));

    return IsLess;
  }

  bool operator<(ParamVector<P> const &rhs) const {
    bool IsLess = false;
    bool IsGrtr = false;
    unsigned I = 0;
    unsigned N = Params.size();

    if (N == 0)
      return false;

    do {
      IsLess = Params[I] < rhs[I];
      IsGrtr = Params[I] > rhs[I];
      ++I;
    } while ((IsLess || !IsGrtr) && (I < N));

    return IsLess;
  }

  llvm::StringRef getShortName() const {
    std::string Res = "";

    for (unsigned I = 0; I < Params.size(); ++I)
      if (llvm::Constant *C = Params[I].Val) {
        const llvm::APInt &Val = C->getUniqueInteger();
        llvm::SmallVector<char, 2> Str;
        Val.toStringUnsigned(Str);
        Res = Res + "." + llvm::StringRef(Str.data(), Str.size()).str();
      }
    return Res;
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


// @brief Create a new function variant with they values included in the
// key replaced.
std::unique_ptr<llvm::Module> createVariant(llvm::Function &BaseF,
                                            const RunValueList &K,
                                            std::string &FnName);

llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Param &P);
llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const ParamVector<Param> &Params);
llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const RunValueList &Params);
} // namespace polli
#endif // POLLI_VARIANTFUNCTION_H
