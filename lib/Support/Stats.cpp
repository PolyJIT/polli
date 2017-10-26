#include "polli/Stats.h"
#include "polli/log.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/TypeBuilder.h"

#include "polli/Jit.h"
#include "pprof/pprof.h"

using namespace llvm;

REGISTER_LOG(console, "stats");

namespace llvm {
template <bool xcompile> class TypeBuilder<polli::Stats, xcompile> {
public:
  static StructType *get(LLVMContext &Context) {
    return StructType::get(TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<1>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context));
  }

  enum Fields {
    NUM_CALLS,
    LOOKUP_TIME,
    LAST_RUNTIME,
    JUMP_INTO_JIT,
    REGION_ENTER,
    REGION_EXIT
  };
};
} // namespace llvm

namespace polli {
Value *registerStatStruct(Function &F, const Twine &NameSuffix) {
  Type *Ty = TypeBuilder<polli::Stats, true>::get(F.getContext());
  Constant *Init = Constant::getNullValue(Ty);
  GlobalVariable *GV = new GlobalVariable(*(F.getParent()), Ty, false,
                                          GlobalValue::PrivateLinkage, Init,
                                          "polyjit.stats." + NameSuffix);
  F.setPrefixData(GV);
  return GV;
}

uint64_t GetCandidateId(const Function &F) {
  uint64_t N = 0;
  std::string NameTag = "polyjit-id";
  if (F.hasFnAttribute(NameTag)) {
    auto FnAttr = F.getFnAttribute(NameTag);
    N = FnAttr.getValueAsString().getAsInteger(10, N);
  }

  assert(N && "Could not find the polyjit-id!");
  if (N == 0)
    console->critical("Could not find the polyjit-id!");
  return N;
}

#if 0
static inline void printStats(const llvm::Function &F, const Stats &S) {
  SPDLOG_DEBUG("stats",
               "F: {:s} ID: {:x} N: {:d} LT: {:d} RT: {:d} Overhead: {:3.2f}%",
               F.getName().str(), (uint64_t)(&S), S.NumCalls, S.LookupTime,
               S.LastRuntime, (S.LookupTime * 100 / (double)S.LastRuntime));
}
#endif
} // namespace polli
