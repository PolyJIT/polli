//===-- JitScopDetection.h --------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#include "llvm/Pass.h"

namespace polli {
llvm::ModulePass *createLikwidMarkerPass();
llvm::ModulePass *createTraceMarkerPass();
llvm::ModulePass *createOpenMPTracerPass();
}

extern "C" {
  void pjit_trace_openmp_entry(uint64_t Id, const char *Name);
  void pjit_trace_openmp_exit(uint64_t Id, const char *Name);
}
