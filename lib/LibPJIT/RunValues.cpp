#include "polli/RunValues.h"
#include "polli/log.h"
#include "pprof/Tracing.h"

#include <boost/functional/hash.hpp>

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

namespace absl {
inline size_t hash_value(const polli::VarParam &V) {
  return absl::get<uint64_t>(V);
}
} // namespace absl

namespace polli {
JitRequest make_request(const absl::string_view FnName,
                        std::shared_ptr<const Module> M,
                        llvm::SmallVector<void *, 4> Params) {
  JitRequest Req;
  std::hash<const char *> FnHash;
  Req.Hash = FnHash(FnName.data());
  Req.M = M;
  Req.Params = Params;
  return Req;
}

VariantRequest make_variant_request(JitRequest JitReq) {
  VariantRequest VarReq;

  size_t Hash = JitReq.Hash;
  const Function *ProtoF;
  llvm::SmallVector<VarParam, 4> Params;

  for (const Function &F : *JitReq.M) {
    if (F.hasFnAttribute("polyjit-jit-candidate")) {
      ProtoF = &F;
      auto I = JitReq.Params.begin();

      for (const Argument &Arg : F.args()) {
        if (!canSpecialize(Arg)) {
          continue;
        }
        Type *Ty = Arg.getType();
        if (Ty->isIntegerTy()) {
          Params.push_back(*static_cast<uint64_t *>(*I));
        } else {
          Params.push_back(*I);
        }
      }
    }
  }

  if (!ProtoF)
    llvm_unreachable("No JIT candidate in prototype!");

  boost::hash_range(Hash, Params.begin(), Params.end());

  VarReq.F = ProtoF;
  VarReq.Params = Params;
  VarReq.Hash = Hash;

  for (auto P : Params) {
    auto Value = absl::get<uint64_t>(P);
  }

  return VarReq;
}

#if 0
#ifndef NDEBUG
void printArgs(const Function &F, size_t Argc,
               const std::vector<void *> &Params) {
  std::string Buf;
  raw_string_ostream S(Buf);

  size_t I = 0;
  for (auto &Arg : F.args()) {
    if (I < Argc) {
      RunValue<uint64_t *> V{static_cast<uint64_t *>(Params[I]), &Arg};
      if (canSpecialize(V)) {
        S << fmt::format("{:s} [{:d}] -> {} ", Arg.getName().str(), I,
                         *V.value);
      }
      Type *Ty = Arg.getType();
      if (Ty->isIntegerTy()) {
        console->debug("{:s} [{:d}] -> {} ", Arg.getName().str(), I,
                       *static_cast<int64_t *>(Params[I]));
      }
      if (Ty->isDoubleTy()) {
        console->debug("[{:d}] -> {:g} ", I,
                       (double)*(static_cast<double *>(Params[I])));
      }
      if (Ty->isPointerTy()) {
        console->debug("[{:d}] -> 0x{:x} ", I,
                       (int64_t)(static_cast<int64_t *>(Params[I])));
      }
      I++;
    }
  }
  dbgs() << "\n";
}
#endif
#endif
} // namespace polli
