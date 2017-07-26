#ifndef POLLI_JIT_H
#define POLLI_JIT_H

#define BOOST_THREAD_PROVIDES_FUTURE
#include <boost/thread/future.hpp>

#include <unordered_map>

#include "polli/Caching.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"

#include "llvm/ExecutionEngine/JITSymbol.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ThreadPool.h"

#include <mutex>

namespace polli {
enum JitRegion : int {
  START = 0,
  CODEGEN = 1,
  VARIANTS = 2,
  CACHE_HIT = 3
};

class PolyJIT {
  void setup();
  void tearDown();

  std::recursive_mutex TracingMutex;
  std::unordered_map<uint64_t, uint64_t> Events;
  std::unordered_map<uint64_t, uint64_t> Entries;
  std::unordered_map<uint64_t, std::string> Regions;

public:
  explicit PolyJIT() : CodeCache(), Pool(1) { setup(); }
  ~PolyJIT() {
    tearDown();
  }

  void enter(uint64_t id, uint64_t time) {
    std::lock_guard<std::recursive_mutex> CS(TracingMutex);

    if (!Events.count(id))
      Events[id] = 0;
    if (!Entries.count(id))
      Entries[id] = 0;
    Events[id] -= time;
    Entries[id] += 1;
  }

  void exit(uint64_t id, uint64_t time) {
    std::lock_guard<std::recursive_mutex> CS(TracingMutex);
    Events[id] += time;
  }

  void increment(uint64_t id, uint64_t step) {
    std::lock_guard<std::recursive_mutex> CS(TracingMutex);
    enter(id, 0);
    exit(id, step);
  }

  void addRegion(const std::string Name, uint64_t id) {
    std::lock_guard<std::recursive_mutex> CS(TracingMutex);
    Regions[id] = Name;
  }

  /**
   * @name CodeCache interface.
   * @{ */
  using CodeCacheT =
      std::unordered_map<CacheKey, llvm::JITSymbol>;
  using fn_type = llvm::Function;

  CodeCacheT &cache() { return CodeCache; }
  /**  @} */

  /**
   * @name Asynchronous task scheduling interface.
   * @{ */
  struct deref_functor {
    template <typename Pointer> void operator()(Pointer const &p) const {
      (*p)();
    }
  };

  template <typename Function, typename... Args>
  auto async(Function &&F, Args &&... ArgList) {
    return Pool.async(F, ArgList...);
  }

  void UpdatePrefixMap(uint64_t Prefix, const llvm::Function *F);
  const fn_type *FromPrefix(uint64_t K) { return PrefixToFnMap[K]; }

  void wait() { Pool.wait(); }

private:
  CodeCacheT CodeCache;
  llvm::ThreadPool Pool;

  std::unordered_map<uint64_t, const llvm::Function *> PrefixToFnMap;
};
}
#endif /* end of include guard: POLLI_JIT_H */
