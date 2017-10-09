//===-- CodeGen.h ---------------------------------------------------------===//
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
#ifndef POLLI_CODEGEN_H
#define POLLI_CODEGEN_H

#include <deque>
#include <mutex>

template <typename T> class CodeGenQueue {
private:
  std::deque<T> Work;
  mutable std::mutex M;

public:
  using value_type = T;
  using reference = const T &;

  reference front() const { return Work.front(); }
  reference back() const { return Work.front(); }

  void pop_front() {
    std::unique_lock<std::mutex> L(M);
    Work.pop_front();
  }

  void pop_back() {
    std::unique_lock<std::mutex> L(M);
    Work.pop_back();
  }

  bool empty() const {
    std::unique_lock<std::mutex> L(M);
    return Work.empty();
  }

  void push_back(const value_type &x) {
    std::unique_lock<std::mutex> L(M);
    Work.push_back(x);
  }

  void push_back(value_type &&x) {
    std::unique_lock<std::mutex> L(M);
    Work.push_back(x);
  }

  void clear() {
    std::unique_lock<std::mutex> L(M);
    Work.clear();
  }
};


#endif // POLLI_CODEGEN_H
