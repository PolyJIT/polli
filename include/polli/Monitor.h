#ifndef POLLI_MONITOR_H
#define POLLI_MONITOR_H

#include <iostream>
#include <mutex>

namespace polli {
template <class F> struct FunctionType;

template <class R, class O, class... Args>
struct FunctionType<R (O::*)(Args...)> {
  using return_type = R;
};

template <class R, class O, class... Args>
struct FunctionType<R (O::*)(Args...) const> {
  using return_type = R;
};

template <class R, class... Args>
struct FunctionType<R (Args...)> {
  using return_type = R;
};

template <class R, class... Args>
struct FunctionType<R (Args...) const> {
  using return_type = R;
};

template <class O>
class Monitor {
public:
  using object_type = O;
  template <class Function, class... Args>
  typename FunctionType<Function>::return_type RunMethodInCS(const Function &F,
                                                             Args... args) {
    std::lock_guard<std::mutex> CS(M);
    return (Obj.*F)(args...);
  }

  template <class Function, class... Args>
  typename FunctionType<Function>::return_type
  RunMethodInCS(const Function &F, Args... args) const {
    std::lock_guard<std::mutex> CS(M);
    return (Obj.*F)(args...);
  }

  template <class Function, class... Args>
  typename FunctionType<Function>::return_type RunInCS(const Function &F,
                                                       Args... args) {
    std::lock_guard<std::mutex> CS(M);
    return F(args...);
  }

  template <class Function, class... Args>
  typename FunctionType<Function>::return_type RunInCS(const Function &F,
                                                       Args... args) const {
    std::lock_guard<std::mutex> CS(M);
    return F(args...);
  }

  ~Monitor() {}

  object_type &monitored() {
    return Obj;
  }

private:
  object_type Obj;
  mutable std::mutex M;
};
} // namespace polli

#endif // POLLI_MONITOR_H

