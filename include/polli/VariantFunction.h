#ifndef POLLI_VARIANTFUNCTION_H
#define POLLI_VARIANTFUNCTION_H

#include "llvm/IR/Module.h"
#include "polli/RunValues.h"

using llvm::Module;

namespace polli {
// @brief Create a new function variant with they values included in the
// key replaced.
std::unique_ptr<Module> createVariant(const VariantRequest R, std::string &FnName);
} // namespace polli
#endif // POLLI_VARIANTFUNCTION_H
