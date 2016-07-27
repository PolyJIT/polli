#include "pprof/Tracing.h"
#include "polli/RunValues.h"
#include "polli/log.h"

#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

using spdlog::details::fmt::format;

namespace polli {
RunValueList runValues(const SpecializerRequest &Request) {
  POLLI_TRACING_REGION_START(PJIT_REGION_SELECT_PARAMS,
                             "polyjit.params.select");
  int i = 0;
  RunValueList RunValues(boost::hash_value(Request.F->getName().str()));
  assert(Request.F && "Request malformed! Need an llvm function.");

  DEBUG(printArgs(*Request.F, Request.ParamC, Request.Params));
  for (const llvm::Argument &Arg : Request.F->args()) {
    RunValues.add({reinterpret_cast<uint64_t **>(Request.Params)[i], &Arg});
    i++;
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_SELECT_PARAMS, "polyjit.params.select");
  return RunValues;
}

#ifndef NDEBUG
void printArgs(const llvm::Function &F, size_t argc, void *params) {
  std::string buf;
  llvm::raw_string_ostream s(buf);

  size_t i = 0;
  for (auto &Arg : F.args()) {
    if (i < argc) {
      RunValue<uint64_t *> V{reinterpret_cast<uint64_t **>(params)[i], &Arg};
      if (polli::canSpecialize(V)) {
        llvm::dbgs() << format("[{:d}] -> {} ", i, *V.value);
      }
      llvm::Type *Ty = Arg.getType();
      if (Ty->isIntegerTy())
        llvm::dbgs() << format("[{:d}] -> {} ", i, (int)*((uint64_t**)params)[i]);
      if (Ty->isDoubleTy())
        llvm::dbgs() << format("[{:d}] -> {:g} ", i, (double)*((double**)params)[i]);
      if (Ty->isPointerTy())
        llvm::dbgs() << format("[{:d}] -> 0x{:x} ", i, (uint64_t)((uint64_t**)params)[i]);
      i++;
    }
  }
  llvm::dbgs() << "\n";
}

void printRunValues(const RunValueList &Values) {
  for (auto &RV : Values) {
    llvm::dbgs() << format(
        "{:d} matched against {}\n", *RV.value,
        reinterpret_cast<void *>(const_cast<llvm::Argument *>(RV.Arg)));
  }
}
#endif
}
