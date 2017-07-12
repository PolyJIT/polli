#include "llvm/Pass.h"

namespace polli {
Pass *createProfileScopsPass();
}

namespace llvm {
class PassRegistry;
void initializeProfileScopsPass(llvm::PassRegistry &);
}