//===------- RuntimeValues.h ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_RUNTIME_VALUES_H
#define POLLI_RUNTIME_VALUES_H

#include "llvm/Support/Casting.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Type.h"

#include <boost/functional/hash.hpp>
#include <memory>
#include <vector>
#include <iostream>
#include <algorithm>

namespace {
template <typename C, typename P> C filter(C const &container, P pred) {
  C filtered(container);
  filtered.erase(remove_if(filtered.begin(), filtered.end(), pred),
                 filtered.end());
  return filtered;
}
}

namespace polli {
template <typename T>
struct RunValue {
  T value;
  const llvm::Argument * Arg;
};

template<typename T>
inline bool canSpecialize(const RunValue<T> &V) {
  return llvm::isa<llvm::IntegerType>(V.Arg->getType());
}
} // end of polli namespace

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
  using reference = RunValueT&;

  explicit RunValueList(std::size_t Seed = 0)
      : List(new RunValueListT()), Seed(Seed){};

  RunValueList(const RunValueList & Other) = default;
  RunValueList &operator=(const RunValueList & Other) = default;
  RunValueList(RunValueList && Other) = default;
  RunValueList &operator=(RunValueList && Other) = default;

  bool operator==(const RunValueList &RHS) const {
    return List.get() == RHS.List.get();
  }

  void add(const RunValueT &NewVal) {
    List->push_back(NewVal);
  }

  iterator begin() { return List->begin(); }
  iterator end() { return List->end(); }
  const_iterator begin() const { return List->begin(); }
  const_iterator end() const { return List->end(); }
  size_t size() const { return List->size(); }

  size_t hash() const {
    size_t LocalSeed = Seed;
    RunValueListT Tmp = filter(*List, [](const RunValueT &V) {
      return !canSpecialize(V);
    });

    boost::hash_range(LocalSeed, Tmp.begin(), Tmp.end());
    return LocalSeed;
  }

  std::string str() const {
    RunValueListT Tmp = filter(*List, [](const RunValueT &V) {
      return !canSpecialize(V);
    });

    int i = 0;
    std::stringstream os;
    os << "[";
    for (auto &V : Tmp) {
      if (i > 0)
        os << ", ";
      if (canSpecialize(V))
        os << *V.value;
      else
        os << V.value;
      i++;
    }
    os << "]";
    return os.str();
  }

  reference operator[](size_t i) { return List->operator[](i); }

private:
  std::shared_ptr<RunValueListT> List;
  std::size_t Seed;
};
} // end of polli namespace

namespace std {
template <> struct hash<const polli::RunValueList> {
  std::size_t operator()(const polli::RunValueList &This) const {
    return This.hash();
  }
};
}
#endif //POLLI_RUNTIME_VALUES_H
