#include "polli/VariantFunction.h"
#include "polli/Utils.h"

#include <cxxabi.h>
#include <stdlib.h>

#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

#include "llvm/Support/raw_ostream.h"

namespace polli {
llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Param &P) {
  return OS << P.Val->getUniqueInteger();
}

void VariantFunction::printVariants(raw_ostream &OS) {
    for (VariantsT::iterator I = Variants.begin(), IE = Variants.end(); I != IE;
         ++I) {
      const FunctionKey K = I->first;
      Function *VarFun = I->second;
      Module *M = VarFun->getParent();
      OS.indent(4) << K << M->getModuleIdentifier() << "\n";
    }
    OS << "\n";
}

void VariantFunction::printHeader(llvm::raw_ostream &OS) {
  OS << "Source Function::Base Function:: Variants; Calls; MFLOPS [MFLOPs/s]; "
     << "FLOPs [#]; Real Time [us]; Virtual Time [us]\n\n";
}

void VariantFunction::print(llvm::raw_ostream &OS) {
  std::string Message;
  std::string Format = "%s :: %s :: %d; %d; %f; %ld; %f; %f\n";

  OS << demangle(SourceF->getName()) << " :: "
     << demangle(BaseF->getName()) << " :: "
     << S.ExecCount << "; "
     << S.MFLOPS << "; "
     << S.flpops << "; "
     << S.RealTime << "; "
     << S.ProcTime << "\n";

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
}
