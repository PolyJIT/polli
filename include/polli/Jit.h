#ifndef POLLI_JIT_H
#define POLLI_JIT_H

#include "polli/Caching.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"

#include "llvm/ExecutionEngine/JITSymbol.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ThreadPool.h"

#include <mutex>
#include <unordered_map>
#include <utility>

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
  std::recursive_mutex CacheMutex;

  std::unordered_map<uint64_t, uint64_t> Events;
  std::unordered_map<uint64_t, uint64_t> Entries;
  std::unordered_map<uint64_t, std::string> Regions;

public:
  explicit PolyJIT() { setup(); }

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
  using value_type = std::pair<const CacheKey, llvm::JITSymbol>;
  using iterator = CodeCacheT::iterator;
  using const_iterator = CodeCacheT::const_iterator;

  std::pair<iterator, bool> insert(value_type &&value) {
    std::lock_guard<std::recursive_mutex> CS(CacheMutex);
    return CodeCache.insert(std::forward<value_type>(value));
  }

  iterator find(const CacheKey &key) {
    std::lock_guard<std::recursive_mutex> CS(CacheMutex);
    return CodeCache.find(key);
  }

  iterator end() {
    std::lock_guard<std::recursive_mutex> CS(CacheMutex);
    return CodeCache.end();
  }

  iterator begin() {
    std::lock_guard<std::recursive_mutex> CS(CacheMutex);
    return CodeCache.begin();
  }

  /**  @} */

private:
  CodeCacheT CodeCache;
};
}
#endif /* end of include guard: POLLI_JIT_H */
