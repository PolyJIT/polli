#include "polli/Jit.h"
#include "polli/Db.h"
#include "polli/log.h"
#include "pprof/pprof.h"

#include "llvm/IR/Function.h"

using namespace llvm;

REGISTER_LOG(console, "jit");

namespace polli {

VariantFunctionTy PolyJIT::getOrCreateVariantFunction(Function *F) {
  // We have already specialized this function at least once.
  if (VariantFunctions.count(F))
    return VariantFunctions.at(F);

  // Create a variant function & specialize a new variant, based on key.
  VariantFunctionTy VarFun = std::make_shared<VariantFunction>(*F);

  VariantFunctions.insert(std::make_pair(F, VarFun));
  return VarFun;
}

void PolyJIT::setup() {
  enter(0, PAPI_get_real_usec());

  /* CACHE_HIT */
  enter(3, 0);

  Regions[0] = "START";
  Regions[1] = "CODEGEN";
  Regions[2] = "VARIANTS";
  Regions[3] = "CACHE_HIT";
}

void PolyJIT::tearDown() {
  exit(0, PAPI_get_real_usec());
  polli::StoreRun(Events, Entries, Regions);
}

void PolyJIT::UpdatePrefixMap(uint64_t Prefix, const llvm::Function *F) {
  PrefixToFnMap[Prefix] = F;
}
}
