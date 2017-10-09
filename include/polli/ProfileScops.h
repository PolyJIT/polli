#ifndef POLLI_PROFILESCOPS_H
#define POLLI_PROFILESCOPS_H

#include "llvm/Pass.h"

namespace polli {
Pass *createProfileScopsPass(bool);
} // namespace polli

namespace llvm {
class PassRegistry;
void initializeProfileScopsPass(llvm::PassRegistry &);
} // namespace llvm

#endif
