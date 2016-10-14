#ifndef POLLI_JIT_H
#define POLLI_JIT_H

#define BOOST_THREAD_PROVIDES_FUTURE
#include <boost/thread/future.hpp>

#include <unordered_map>

#include "polli/Caching.h"
#include "polli/Tasks.h"
#include "polli/VariantFunction.h"

#include "llvm/IR/Function.h"

namespace polli {

class PolyJIT {
  void setup();
  void tearDown();

public:
  explicit PolyJIT() : VariantFunctions(), CodeCache() { setup(); }
  ~PolyJIT() {
    System.cancel_pending_jobs();
    tearDown();
  }

  //@brief Shutdown the task system.
  void shutdown() {
    System.cancel_pending_jobs();
    System.wait_for_running_jobs();
  }

  /**
   * @name CodeCache interface.
   * @{ */
  using CodeCacheT =
      std::unordered_map<CacheKey, std::function<void(int, char **)>>;
  using iterator = CodeCacheT::iterator;
  using const_iterator = CodeCacheT::const_iterator;
  using value_type = CodeCacheT::mapped_type;
  using fn_type = llvm::Function;

  const_iterator find(const CacheKey &K) const { return CodeCache.find(K); }

  iterator begin() { return CodeCache.begin(); }

  const_iterator begin() const { return CodeCache.begin(); }

  iterator end() { return CodeCache.end(); }

  const_iterator end() const { return CodeCache.end(); }

  value_type operator[](CacheKey &K) { return CodeCache[K]; }

  const value_type operator[](const CacheKey &K) { return CodeCache[K]; }

  std::pair<iterator, bool> insert(const CodeCacheT::value_type &el) {
    return CodeCache.insert(el);
  }
  /**  @} */

  /**
   * @name Asynchronous task scheduling interface.
   * @{ */
  struct deref_functor {
    template <typename Pointer> void operator()(Pointer const &p) const {
      (*p)();
    }
  };

  template <typename F, typename... Args>
  auto async(F &&f, Args &&... args)
      -> boost::future<typename std::result_of<F(Args...)>::type> {
    using result_type = typename std::result_of<F(Args...)>::type;
    using task_type = boost::packaged_task<result_type>;

    auto Task = std::make_shared<task_type>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));

    boost::future<result_type> ft = Task->get_future();

    System.async(std::move(std::bind(deref_functor(), Task)));
    return std::move(ft);
  }
  /**  @} */

  /**
   * @brief Get or Create a new variant function for the given Function.
   *
   * @param F The function we get or create the variant function for.
   *
   * @return A variant function for function F
   */
  VariantFunctionTy getOrCreateVariantFunction(llvm::Function *F);

  void UpdatePrefixMap(uint64_t Prefix, const llvm::Function *);
  const fn_type *FromPrefix(uint64_t K) { return PrefixToFnMap[K]; }
private:
  VariantFunctionMapTy VariantFunctions;
  CodeCacheT CodeCache;
  TaskSystem System;

  std::unordered_map<uint64_t, const llvm::Function *> PrefixToFnMap;
};
}
#endif /* end of include guard: POLLI_JIT_H */
