#include "polli/RunValues.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

using llvm::Argument;
using llvm::Constant;
using llvm::ConstantFP;
using llvm::ConstantInt;
using llvm::dbgs;
using llvm::Function;
using llvm::Module;
using llvm::raw_string_ostream;
using llvm::Type;

using polli::canSpecialize;

REGISTER_LOG(console, "runvals");

namespace polli {
Function *SpecializerRequest::init(std::shared_ptr<Module> PrototypeM) {
  for (Function &ProtoF : *PrototypeM) {
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

  const Function &F = Request.prototype();
  DEBUG(printArgs(F, Request.paramSize(), Request.params()));
  for (const Argument &Arg : F.args()) {
    RunValues.add({reinterpret_cast<uint64_t *>(Request.params()[I]), &Arg});
    I++;
  }
  POLLI_TRACING_REGION_STOP(PJIT_REGION_SELECT_PARAMS, "polyjit.params.select");
  return RunValues;
}

#ifndef NDEBUG
void printArgs(const Function &F, size_t Argc,
               const std::vector<void *> &Params) {
  std::string Buf;
  raw_string_ostream S(Buf);

  size_t I = 0;
  for (auto &Arg : F.args()) {
    if (I < Argc) {
      RunValue<uint64_t *> V{reinterpret_cast<uint64_t *>(Params[I]), &Arg};
      if (canSpecialize(V)) {
        S << fmt::format("{:s} [{:d}] -> {} ", Arg.getName().str(), I,
                         *V.value);
      }
      Type *Ty = Arg.getType();
      if (Ty->isIntegerTy()) {
        console->debug("{:s} [{:d}] -> {} ", Arg.getName().str(), I,
                       *reinterpret_cast<int64_t *>(Params[I]));
      }
      if (Ty->isDoubleTy()) {
        console->debug("[{:d}] -> {:g} ", I,
                       (double)*(reinterpret_cast<double *>(Params[I])));
      }
      if (Ty->isPointerTy()) {
        console->debug("[{:d}] -> 0x{:x} ", I,
                       (int64_t)(reinterpret_cast<int64_t *>(Params[I])));
      }
      I++;
    }
  }
  dbgs() << "\n";
}
#endif

void printRunValues(const RunValueList &Values) {
  for (auto &RV : Values) {
    Constant *Cst = nullptr;
    Type *Ty = RV.Arg->getType();
    if (Ty->isIntegerTy()) {
      Cst = ConstantInt::get(Ty, *RV.value);
    } else if (Ty->isFloatTy()) {
      Cst = ConstantFP::get(Ty, (double)(*RV.value));
    }

    std::string Buf;
    raw_string_ostream Os(Buf);
    if (Cst) {
      Cst->print(Os, true);
    } else {
      fmt::MemoryWriter W;
      W << "U 0x" << fmt::hex(*RV.value);
      Os << W.c_str();
    }
    console->info("{} => {:s}",
                  reinterpret_cast<void *>(const_cast<Argument *>(RV.Arg)),
                  Os.str());
    Os.flush();
  }
}
} // namespace polli
