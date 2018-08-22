#ifndef POLLI_JIT_H
#define POLLI_JIT_H

#include <mutex>
#include <unordered_map>
#include <utility>

#include "llvm/ExecutionEngine/JITSymbol.h"

#include "polli/Caching.h"
#include "polli/ExportMetrics.h"

using llvm::JITSymbol;

namespace polli {
enum JitRegion : int {
  START = 0,
  CODEGEN = 1,
  VARIANTS = 2,
  CACHE_HIT = 3,
  REQUESTS = 4,
  BLOCKED = 5
};

class PolyJIT {
  void setup();
  void tearDown();

  mutable std::recursive_mutex TracingMutex;
  mutable std::recursive_mutex CacheMutex;

  JitEventData EventData;

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

  void increment(uint64_t id, uint64_t step = 1) {
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
      std::unordered_map<CacheKey, JITSymbol>;
  using value_type = std::pair<const CacheKey, JITSymbol>;
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
} // namespace polli
#endif // POLLI_JIT_H
