#include "polli/RunValues.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

#include "cppformat/format.h"
#include <string>

namespace polli {
RunValueList runValues(const SpecializerRequest &Request) {
  POLLI_TRACING_REGION_START(PJIT_REGION_SELECT_PARAMS,
                             "polyjit.params.select");
  int i = 0;
  RunValueList RunValues;
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
        llvm::dbgs() << fmt::format("[{:d}] -> {} ", i, *V.value);
      }
      i++;
    }
  }
  llvm::dbgs() << "\n";
}

void printRunValues(const RunValueList &Values) {
  for (auto &RV : Values) {
    llvm::dbgs() << fmt::format(
        "{:d} matched against {}\n", *RV.value,
        reinterpret_cast<void *>(const_cast<llvm::Argument *>(RV.Arg)));
  }
}
#endif
}

