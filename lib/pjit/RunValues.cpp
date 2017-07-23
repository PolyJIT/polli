#include "polli/RunValues.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

REGISTER_LOG(console, "runvals");

namespace polli {
llvm::Function &
SpecializerRequest::init(std::shared_ptr<llvm::Module> PrototypeM) {
  for (llvm::Function &ProtoF : *PrototypeM) {
    if (ProtoF.hasFnAttribute("polyjit-jit-candidate"))
      return ProtoF;
  }

  console->error("No JIT candidate in prototype!\n");
  llvm_unreachable("No JIT candidate found in prototype!");
}

RunValueList runValues(const SpecializerRequest &Request) {
  assert(Request.F && "Request malformed! Need an llvm function.");
  POLLI_TRACING_REGION_START(PJIT_REGION_SELECT_PARAMS,
                             "polyjit.params.select");
  int i = 0;
  RunValueList RunValues(boost::hash_value(Request.key()));

  const llvm::Function &F = Request.prototype();
  DEBUG(printArgs(F, Request.paramSize(), Request.params()));
  for (const llvm::Argument &Arg : F.args()) {
    RunValues.add({reinterpret_cast<uint64_t **>(Request.params())[i], &Arg});
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
        s << fmt::format("{:s} [{:d}] -> {} ", Arg.getName().str(), i,
                         *V.value);
      }
      llvm::Type *Ty = Arg.getType();
      if (Ty->isIntegerTy())
        console->debug("{:s} [{:d}] -> {} ", Arg.getName().str(), i,
                       (int)*((uint64_t **)params)[i]);
      if (Ty->isDoubleTy())
        console->debug("[{:d}] -> {:g} ", i, (double)*((double **)params)[i]);
      if (Ty->isPointerTy())
        console->debug("[{:d}] -> 0x{:x} ", i,
                       (uint64_t)((uint64_t **)params)[i]);
      i++;
    }
  }
  llvm::dbgs() << "\n";
}

void printRunValues(const RunValueList &Values) {
  for (auto &RV : Values) {
    console->debug(
        "{:d} matched against {}\n", *RV.value,
        reinterpret_cast<void *>(const_cast<llvm::Argument *>(RV.Arg)));
  }
}
#endif
}
