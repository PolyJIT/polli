#include "polli/VariantFunction.h"
#include "polli/Utils.h"

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
void VariantFunction::print(llvm::raw_ostream &OS) {
  OS << "SourceF: " << SourceF->getName() << "\n";
  OS.indent(2) << " BaseF: " << BaseF->getName() << "\n";
  OS.indent(2) << " Variants: " << getVariants().size() << "\n";
  OS << "\n";

  DEBUG(printVariants(OS));

  OS.indent(4) << "Calls [#]: " << S.ExecCount << "\n";
  OS.indent(4) << "MFLOPS [MFLOPs/s]: " << S.MFLOPS << "\n";
  OS.indent(4) << "FLOPs [#]: " << S.flpops << "\n";
  OS.indent(4) << "Real Time []: " << S.RealTime << "\n";
  OS.indent(4) << "Virtual Time []: " << S.ProcTime << "\n";
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
