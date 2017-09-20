#include "llvm/Pass.h"

namespace polli {
Pass *createProfileScopsPass(bool);
}

namespace llvm {
class PassRegistry;
void initializeProfileScopsPass(llvm::PassRegistry &);
}
