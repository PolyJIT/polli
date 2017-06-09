#ifndef POLLI_FUNCTOOLS_H
#define POLLI_FUNCTOOLS_H

#include "llvm/IR/GlobalValue.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/IR/Function.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

namespace polli {
using GlobalList = llvm::SetVector<llvm::GlobalValue *>;

/**
 * @brief Collect all global variables used within this Instruction.
 *
 * We need to keep track of global vars, when extracting prototypes.
 * This is used in conjunction with the apply function.
 *
 * @param I The Instruction we collect globals from.
 * @param Globals A list of globals we collected so far.
 * @return void
 */
void selectGV(llvm::Instruction &I, GlobalList &Globals);

using InstrList = llvm::SmallVector<llvm::Instruction *, 4>;
/**
 * @brief Convert a ConstantExpr pointer operand to an Instruction Value.
 *
 * This is used in conjunction with the apply function.
 *
 * @param I The Instruction we want to convert the operand in.
 * @param Converted A list of Instructions where we keep track of all found
 *                  Instructions so far.
 * @return void
 */
void constantExprToInstruction(llvm::Instruction &I, InstrList &Converted,
                               llvm::ValueToValueMapTy &VMap);

/**
 * @brief Apply a selector function on the function body.
 *
 * This is a little helper function that allows us to scan over all instructions
 * within a function, collecting arbitrary stuff on the way.
 *
 * @param T The type we track our state in.
 * @param F The Function we operate on.
 * @param I The Instruction the selector operates on next.
 * @param L The state the SelectorF operates with.
 * @param SelectorF The selector function we apply to all instructions in the
 *                  function.
 * @return T
 */
template <typename T>
static T apply(llvm::Function &F,
               std::function<void(llvm::Instruction &I, T &L)> SelectorF) {
  T L;
  for (llvm::BasicBlock &BB : F)
    for (llvm::Instruction &I : BB)
      SelectorF(I, L);

  return L;
}
}


#endif /* end of include guard: POLLI_FUNCTOOLS_H */
