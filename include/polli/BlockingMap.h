//===-- BlockingMap.h -----------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2015 - Andreas Simbürger <simbuerg@lairosiel.de>
//
//===----------------------------------------------------------------------===//
//
//
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_BLOCKING_MAP_H
#define POLLI_BLOCKING_MAP_H

#include <unordered_map>
#include <condition_variable>
#include <mutex>

template <typename K, typename V> class BlockingMap {
private:
  std::unordered_map<K, V> Cache;

  mutable std::mutex WriteMutex;
  std::condition_variable NewElement;

public:
  using size_type = size_t;
  using iterator = typename std::unordered_map<K, V>::iterator;
  using value_type = std::pair<K, V>;
  using iterator_pair = std::pair<iterator, bool>;

  size_type count(const K &X) { return Cache.count(X); }

  iterator_pair insert(const value_type &Value) {
    iterator_pair Ret;
    {
      std::lock_guard<std::mutex> WL(WriteMutex);
      Ret = Cache.insert(Value);
    }
    NewElement.notify_one();
    return Ret;
  }

  V &blocking_at(const K &X) {
    {
      std::unique_lock<std::mutex> WL(WriteMutex);
      NewElement.wait(WL, [&]() { return Cache.count(X); });
    }
    return Cache[X];
  }

  V &operator[](const K &X) { return Cache[X]; }
  V &operator[](K &&X) { return Cache[X]; }
};

#endif /* ifndef POLLI_BLOCKING_MAP_H */
