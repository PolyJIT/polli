//===------- RuntimeValues.h ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_RUNTIMEVALUES_H
#define POLLI_RUNTIMEVALUES_H

#include "polli/log.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Casting.h"

#include <algorithm>
#include <boost/functional/hash.hpp>
#include <iostream>
#include <memory>
#include <vector>

namespace {
template <typename C, typename P> C filterOut(C const &container, P pred) {
  C Filtered(container);
  Filtered.erase(remove_if(Filtered.begin(), Filtered.end(), pred),
                 Filtered.end());
  return Filtered;
}
} // namespace

namespace polli {
template <typename T> struct RunValue {
  T value;
  const llvm::Argument *Arg;
};

template <typename T> inline bool canSpecialize(const RunValue<T> &V) {
  const llvm::Function *F = V.Arg->getParent();
  unsigned I = V.Arg->getArgNo();
  llvm::Attribute Attr = F->getAttribute(I + 1, "polli.specialize");
  return Attr.getAsString() == "\"polli.specialize\"";
}

inline bool canSpecialize(const llvm::Argument &Arg) {
  const llvm::Function *F = Arg.getParent();
  llvm::Attribute Attr =
      F->getAttribute(Arg.getArgNo() + 1, "polli.specialize");
  return Attr.getAsString() == "\"polli.specialize\"";
}
} // namespace polli

namespace polli {
inline size_t hash_value(const polli::RunValue<uint64_t *> &V) {
  return *(V.value);
}

class RunValueList {
public:
  using RunValueT = RunValue<uint64_t *>;
  using RunValueListT = std::vector<RunValueT>;
  using iterator = RunValueListT::iterator;
  using const_iterator = RunValueListT::const_iterator;
  using reference = RunValueT &;

  explicit RunValueList(std::size_t Seed = 0) : Seed(Seed){};

  bool operator==(const RunValueList &RHS) const {
    return hash() == RHS.hash();
  }

  void add(const RunValueT &NewVal) { List.push_back(NewVal); }

  iterator begin() { return List.begin(); }
  iterator end() { return List.end(); }
  const_iterator begin() const { return List.begin(); }
  const_iterator end() const { return List.end(); }

  size_t size() const { return List.size(); }
  size_t hash() const {
    size_t LocalSeed = Seed;
    RunValueListT Tmp =
        filterOut(List, [](const RunValueT &V) { return !canSpecialize(V); });

    boost::hash_range(LocalSeed, Tmp.begin(), Tmp.end());
    return LocalSeed;
  }

  std::string str() const {
    RunValueListT Tmp =
        filterOut(List, [](const RunValueT &V) { return !canSpecialize(V); });

    int I = 0;
    std::stringstream Os;
    Os << "[";
    for (auto &V : Tmp) {
      if (I > 0)
        Os << ", ";
      if (canSpecialize(V))
        Os << *V.value;
      else
        Os << V.value;
      I++;
    }
    Os << "]";
    return Os.str();
  }

  reference operator[](size_t i) { return List[i]; }

private:
  RunValueListT List;
  std::size_t Seed;
};
} // namespace polli

namespace std {
template <> struct hash<const polli::RunValueList> {
  std::size_t operator()(const polli::RunValueList &This) const {
    return This.hash();
  }
};
} // namespace std
#endif // POLLI_RUNTIMEVALUES_H
