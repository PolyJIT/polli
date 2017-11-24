//===-- libpjit.cpp - PolyJIT Just in Time Compiler -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
// Copyright 2014 Andreas Simbürger <simbuerg@fim.uni-passau.de>
//
//===----------------------------------------------------------------------===//
//
// This tool implements a just-in-time compiler for LLVM, allowing direct
// execution of LLVM bitcode in an efficient manner.
//
//===----------------------------------------------------------------------===//
#include <likwid.h>

#include <atomic>
#include <cstdlib>
#include <deque>
#include <memory>
#include <thread>
#include <unordered_map>
#include <vector>

#include "absl/strings/string_view.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/ThreadPool.h"

#include "polli/Caching.h"
#include "polli/Compiler.h"
#include "polli/Jit.h"
#include "polli/RunValues.h"
#include "polli/RuntimeValues.h"
#include "polli/Stats.h"
#include "polli/VariantFunction.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#define DEBUG_TYPE "polyjit"

using llvm::ThreadPool;
using llvm::Function;
using llvm::ManagedStatic;
using llvm::Module;
using llvm::JITSymbol;
using llvm::llvm_shutdown;

using polli::PolyJIT;
using polli::SpecializingCompiler;

REGISTER_LOG(console, DEBUG_TYPE);

static ManagedStatic<PolyJIT> JitContext;
static ManagedStatic<SpecializingCompiler> Compiler;

static void wait_for_threads();
struct ThreadPoolCreator {
  static void *call() {
    std::atexit(&wait_for_threads);
    return new ThreadPool(1);
  }
};

static ManagedStatic<ThreadPool, ThreadPoolCreator> Pool;
static void wait_for_threads() {
  Pool->wait();
}

struct PolyjitShutdownObject {
  ~PolyjitShutdownObject() {
    Pool->wait();
    llvm_shutdown();
  }
};
static PolyjitShutdownObject Shutdown;

namespace polli {
using MainFnT = std::function<void(int, char **)>;

static void DoCreateVariant(const SpecializerRequest Request, CacheKey K) {
  if (JitContext->find(K) != JitContext->end()) {
    JitContext->increment(JitRegion::CACHE_HIT);
    return;
  }

  JitContext->increment(JitRegion::VARIANTS);

  auto PM = Request.prototypeModule();

  Function &Prototype = Request.prototype();
  RunValueList Values = runValues(Request);
  std::string FnName;

  std::shared_ptr<Module> Variant = createVariant(Prototype, Values, FnName);
  assert(Variant && "Failed to get a new variant.");
  auto OptimizedModule = Compiler->addModule(Variant);
  const bool IsOptimized = std::get<1>(OptimizedModule);
  if (!IsOptimized) {
    Compiler->block(PM);
  }


  JITSymbol FPtr = Compiler->findSymbol(FnName, PM->getDataLayout());
  auto Addr = FPtr.getAddress();
  console->error_if(!Addr, "Could not get the address of the JITSymbol.");
  assert((bool)Addr && "Could not get the address of the JITSymbol.");

  {
    auto InsertRes = JitContext->insert(std::make_pair(K, std::move(FPtr)));
    const bool Inserted = std::get<1>(InsertRes);
    if (Inserted) {
      llvm_unreachable("Key collision in function cace, abort.");
    }
  }
  DEBUG(printRunValues(Values));
}

static void
GetOrCreateVariantFunction(const SpecializerRequest Request,
                           uint64_t ID, CacheKey K) {
  auto &Ctx = Compiler->getContext();
  Ctx.RunInCS(DoCreateVariant, Request, K);
}

extern "C" {
void pjit_trace_fnstats_entry(uint64_t Id) {
  JitContext->enter(Id, papi::PAPI_get_real_usec());
}

void pjit_trace_fnstats_exit(uint64_t Id) {
  JitContext->exit(Id, papi::PAPI_get_real_usec());
}

/**
 * @brief Runtime callback for PolyJIT.
 *
 * All calls to the PolyJIT runtime will land here.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
void *pjit_main(const char *fName, void *ptr, uint64_t ID,
                unsigned paramc, char **params) {
  // 1. JitContext.
  pjit_trace_fnstats_entry(JitRegion::CODEGEN);
  std::hash<std::string> FnHash;

  // 2. Compiler.
  auto ModRes = Compiler->getModule(ID, fName);
  SharedModule M = std::get<0>(ModRes);
  const bool CacheHit = std::get<1>(ModRes);
  if (Compiler->isBlocked(M)) {
    return ptr;
  }

  SpecializerRequest Request(FnHash(fName), paramc, params, M);
  if (!CacheHit) {
    Function &F = Request.prototype();
    JitContext->addRegion(F.getName().str(), ID);
  }

  CacheKey K{ID, runValues(Request).hash()};
  // 3. ThreadPool
  auto FutureFn = Pool->async(GetOrCreateVariantFunction, Request, ID, K);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!CacheHit) {
    FutureFn.wait();
  }

  pjit_trace_fnstats_exit(JitRegion::CODEGEN);

  {
    auto FnIt = JitContext->find(K);
    if (FnIt != JitContext->end()) {
      auto &Symbol = FnIt->second;
      {
        auto Addr = Symbol.getAddress();
        if (Addr) {
          return reinterpret_cast<void *>(*Addr);
        }
      }
    }
  }
  return ptr;
}

/**
 * @brief Runtime callback for PolyJIT.
 *
 * This entry-point will just return false and invoke the non-optimized
 * version of the scop we want to jit.
 *
 * @param fName The function name we want to call.
 * @param paramc number of arguments of the function we want to call
 * @param params arugments of the function we want to call.
 */
void *pjit_main_no_recompile(const char *fName, void *ptr, uint64_t ID,
                             unsigned paramc, char **params) {
  pjit_trace_fnstats_entry(JitRegion::CODEGEN);
  std::hash<std::string> FnHash;

  auto ModRes = Compiler->getModule(ID, fName);
  SharedModule M = std::get<0>(ModRes);
  bool CacheHit = std::get<1>(ModRes);
  SpecializerRequest Request(FnHash(fName), paramc, params, M);

  if (!CacheHit) {
    Function &F = Request.prototype();
    JitContext->addRegion(F.getName().str(), ID);
  }
  pjit_trace_fnstats_exit(JitRegion::CODEGEN);
  return ptr;
}
} /* extern "C" */
} // namespace polli
