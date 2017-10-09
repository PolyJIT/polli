#include "polli/RunValues.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

REGISTER_LOG(console, "runvals");

namespace polli {
llvm::Function *
SpecializerRequest::init(std::shared_ptr<llvm::Module> PrototypeM) {
  for (llvm::Function &ProtoF : *PrototypeM) {
    if (ProtoF.hasFnAttribute("polyjit-jit-candidate")) {
      return &ProtoF;
    }
  }

  llvm_unreachable("No JIT candidate in prototype!");
  return nullptr;
}

RunValueList runValues(const SpecializerRequest &Request) {
  POLLI_TRACING_REGION_START(PJIT_REGION_SELECT_PARAMS,
                             "polyjit.params.select");
  int I = 0;
  RunValueList RunValues(boost::hash_value(Request.key()));

  const llvm::Function &F = Request.prototype();
  DEBUG(printArgs(F, Request.paramSize(), Request.params()));
  for (const llvm::Argument &Arg : F.args()) {
    RunValues.add({reinterpret_cast<uint64_t *>(Request.params()[I]), &Arg});
    I++;
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_SELECT_PARAMS, "polyjit.params.select");
  return RunValues;
}

#ifndef NDEBUG
void printArgs(const llvm::Function &F, size_t argc, const std::vector<void *> &Params) {
  std::string buf;
  llvm::raw_string_ostream s(buf);

  size_t i = 0;
  for (auto &Arg : F.args()) {
    if (i < argc) {
      RunValue<uint64_t *> V{reinterpret_cast<uint64_t *>(Params[i]), &Arg};
      if (polli::canSpecialize(V)) {
        s << fmt::format("{:s} [{:d}] -> {} ", Arg.getName().str(), i,
                         *V.value);
      }
      llvm::Type *Ty = Arg.getType();
      if (Ty->isIntegerTy())
        console->debug("{:s} [{:d}] -> {} ", Arg.getName().str(), i,
                       *reinterpret_cast<int64_t *>(Params[i]));
      if (Ty->isDoubleTy())
        console->debug("[{:d}] -> {:g} ", i,
                       (double)*(reinterpret_cast<double *>(Params[i])));
      if (Ty->isPointerTy())
        console->debug("[{:d}] -> 0x{:x} ", i,
                       (int64_t)(reinterpret_cast<int64_t *>(Params[i])));
      i++;
    }
  }
  llvm::dbgs() << "\n";
}
#endif

void printRunValues(const RunValueList &Values) {
  for (auto &RV : Values) {
    llvm::Constant *Cst = nullptr;
    llvm::Type *Ty = RV.Arg->getType();
    if (Ty->isIntegerTy()) {
      Cst = llvm::ConstantInt::get(Ty, *RV.value);
    } else if (Ty->isFloatTy()) {
      Cst = llvm::ConstantFP::get(Ty, (double)(*RV.value));
    }

    std::string Buf;
    llvm::raw_string_ostream Os(Buf);
    if (Cst) {
      Cst->print(Os, true);
    } else {
      fmt::MemoryWriter W;
      W << "U 0x" << fmt::hex(*RV.value);
      Os << W.c_str();
    }
    console->info("{} => {:s}", reinterpret_cast<void *>(
                                    const_cast<llvm::Argument *>(RV.Arg)),
                  Os.str());
    Os.flush();
  }
}
} // namespace polli
