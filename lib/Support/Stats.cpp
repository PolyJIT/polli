#include "polli/Stats.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/TypeBuilder.h"

#include "polli/Jit.h"
#include "pprof/pprof.h"

using namespace llvm;

namespace llvm {
template <bool xcompile> class TypeBuilder<polli::Stats, xcompile> {
public:
  static StructType *get(LLVMContext &Context) {
    return StructType::get(TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<1>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           TypeBuilder<types::i<64>, xcompile>::get(Context),
                           nullptr);
  }

  enum Fields {
    NUM_CALLS,
    LOOKUP_TIME,
    LAST_RUNTIME,
    JUMP_INTO_JIT,
    REGION_ENTER,
    REGION_EXIT };
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

static inline unsigned int getCandidateId(const Function *F) {
  uint64_t n = 0;
  std::string name_tag = "polyjit_id";
  if (F->hasFnAttribute(name_tag))
    if (!(std::stringstream(
              F->getFnAttribute(name_tag).getValueAsString()) >>
          n))
      n = 0;
  return n;
}

static void printStats(const llvm::Function *F, const Stats &S) {
  log()->notice(
      "F: {:s} ID: {:x} N: {:d} LT: {:d} RT: {:d} Overhead: {:3.2f}%",
      F->getName().str(), (uint64_t)(&S), S.NumCalls, S.LookupTime,
      S.LastRuntime, (S.LookupTime * 100 / (double)S.LastRuntime));
}

uint64_t TrackStatsChange(const llvm::Function *F, Stats &S) {
  S.LastRuntime = S.RegionExit - S.RegionEnter;
  printStats(F, S);

  uint64_t id = GetCandidateId(F);
  log()->notice("Candidate ID: {:d}", id);
  record_stats(id, F->getName().str().c_str(), S.RegionEnter, S.RegionExit);
  return id;
}
} // namespace polli
