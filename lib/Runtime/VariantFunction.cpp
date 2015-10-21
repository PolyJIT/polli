#define DEBUG_TYPE "polyjit"
#include "likwid.h"

#include "polli/VariantFunction.h"
#include "polli/Utils.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#define FMT_HEADER_ONLY
#include "cppformat/format.h"

using namespace llvm;

namespace polli {
llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Param &P) {
  return OS << P.Val->getUniqueInteger();
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const RunValueList &Params) {
  out << "[";

  for(auto &Val : Params) {
    out << Val.value;
    out << " ";
  }
  out << "]";
  return out;
}

void VariantFunction::printVariants(raw_ostream &OS) {
  for (auto &I : Variants) {
    const size_t hash = I.first;
    Function *VarFun = I.second;
    Module *M = VarFun->getParent();
    OS.indent(4) << hash << ": " << M->getModuleIdentifier() << "\n";
  }
  OS << "\n";
}

void VariantFunction::printHeader(llvm::raw_ostream &OS) {
  OS << "Source Function::Base Function:: Variants; Calls; MFLOPS [MFLOPs/s]; "
     << "FLOPs [#]; Real Time [s]; Virtual Time [s]\n\n";
}

void VariantFunction::print(llvm::raw_ostream &OS) {
  std::string Message;

  OS << fmt::format("{:<s} is mapped to {:>s} and carries {:d} variants.",
                    SourceF.getName().str(), BaseF.getName().str(),
                    Variants.size());
  DEBUG(printVariants(OS));
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const ParamVector<Param> &Params) {
  out << "[";
  for (size_t i = 0; i < Params.size(); ++i) {
    out << Params[i];
    if (!(i == Params.size() - 1))
      out << " ";
  }

  out << "]";
  return out;
}

Function *VariantFunction::getOrCreateVariant(const RunValueList &K) {
  LIKWID_MARKER_START("polyjit.variant.get");
  size_t hash = K.hash();
  if (Variants.count(hash)) {
    DEBUG(
    dbgs() << fmt::format("Cache hit for {}", K.str())
    );

    return Variants[hash];
  } else {
    DEBUG(
    dbgs() << fmt::format("New Variant {}", K.str())
    );
  }

  Function *Variant = createVariant(K);
  Variants[hash] = Variant;

  LIKWID_MARKER_STOP("polyjit.variant.get");
  return Variant;
}

} // namespace polli
