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
#include "polli/Stats.h"
#include "polli/VariantFunction.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#define DEBUG_TYPE "polyjit"

using llvm::Function;
using llvm::JITSymbol;
using llvm::llvm_shutdown;
using llvm::ManagedStatic;
using llvm::Module;
using llvm::ThreadPool;

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
static void wait_for_threads() { Pool->wait(); }

struct PolyjitShutdownObject {
  ~PolyjitShutdownObject() {
    Pool->wait();
    llvm_shutdown();
  }
};
static PolyjitShutdownObject Shutdown;

namespace polli {
using MainFnT = std::function<void(int, char **)>;

static void DoCreateVariant(const JitRequest JR, const VariantRequest R, CacheKey K) {
  if (JitContext->find(K) != JitContext->end()) {
    return;
  }
  JitContext->increment(JitRegion::VARIANTS);

  std::string FnName;
  std::shared_ptr<Module> Variant = createVariant(R, FnName);

  assert(Variant && "Failed to get a new variant.");
  auto OptimizedModule = Compiler->addModule(Variant);
  auto &ExpectedModule = std::get<0>(OptimizedModule);
  if(!ExpectedModule)
    console->error("Error in compiled module!");
  const bool IsOptimized = std::get<1>(OptimizedModule);
  if (!IsOptimized) {
    JitContext->increment(JitRegion::BLOCKED);
    Compiler->block(JR.M);
  }

  JITSymbol FPtr = Compiler->findSymbol(FnName, JR.M->getDataLayout());
  auto Addr = FPtr.getAddress();
  if (!Addr)
    console->error("Could not get the address of the JITSymbol.");
  assert((bool)Addr && "Could not get the address of the JITSymbol.");

  {
    auto InsertRes = JitContext->insert(std::make_pair(K, std::move(FPtr)));
    const bool Inserted = std::get<1>(InsertRes);
    if (!Inserted) {
      console->error("Key collision in function cache: {:d}", K.ValueHash);
      llvm_unreachable("Key collision in function cace, abort.");
    }
  }
  #if 0
  DEBUG(printRunValues(Values));
  #endif
}

static void GetOrCreateVariantFunction(const JitRequest JitReq, const VariantRequest Request,
                                       CacheKey K) {
  auto &Ctx = Compiler->getContext();
  Ctx.RunInCS(DoCreateVariant, JitReq, Request, K);
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
void *pjit_main(const char *FName, void *Ptr, uint64_t ID, unsigned Paramc,
                char **Params) {
  // 1. JitContext.
  pjit_trace_fnstats_entry(JitRegion::CODEGEN);

  // 2. Compiler.
  auto ModRes = Compiler->getModule(ID, FName);
  SharedModule M = std::get<0>(ModRes);
  const bool CacheHit = std::get<1>(ModRes);
  if (Compiler->isBlocked(M)) {
    pjit_trace_fnstats_exit(JitRegion::CODEGEN);
    return Ptr;
  }

  llvm::SmallVector<void *, 4> JitParams;
  for (int i = 0; i < Paramc; i++) {
    JitParams.push_back(static_cast<void *>(Params[i]));
  }
  auto Req = make_request(FName, M, JitParams);
  auto VarReq = make_variant_request(Req);

  if (!CacheHit) {
    JitContext->addRegion(FName, ID);
  }

  CacheKey K{ID, VarReq.Hash};
  // 3. ThreadPool
  auto FutureFn = Pool->async(GetOrCreateVariantFunction, Req, VarReq, K);

  // If it was not a cache-hit, wait until the first variant is ready.
  if (!CacheHit) {
    FutureFn.wait();
  }

  pjit_trace_fnstats_exit(JitRegion::CODEGEN);
  if (Compiler->isBlocked(M)) {
    return Ptr;
  }

  {
    auto FnIt = JitContext->find(K);
    if (FnIt != JitContext->end()) {
      auto &Symbol = FnIt->second;
      {
        auto Addr = Symbol.getAddress();
        if (Addr) {
          JitContext->increment(JitRegion::CACHE_HIT);
          return reinterpret_cast<void *>(*Addr);
        }
      }
    }
  }
  return Ptr;
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
void *pjit_main_no_recompile(const char *FName, void *Ptr, uint64_t ID,
                             unsigned Paramc, char **Params) {
  pjit_trace_fnstats_entry(JitRegion::CODEGEN);

  auto ModRes = Compiler->getModule(ID, FName);
  SharedModule M = std::get<0>(ModRes);
  bool CacheHit = std::get<1>(ModRes);
  llvm::SmallVector<void *, 4> JitParams;
  for (int i = 0; i < Paramc; i++) {
    JitParams.push_back(static_cast<void *>(Params[i]));
  }
  auto JitReq = make_request(FName, M, JitParams);

  if (!CacheHit) {
    JitContext->addRegion(FName, ID);
  }
  pjit_trace_fnstats_exit(JitRegion::CODEGEN);
  return Ptr;
}
} /* extern "C" */
} // namespace polli
