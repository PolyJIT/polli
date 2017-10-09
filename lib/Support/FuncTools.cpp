#include "polli/FuncTools.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using ExprList = SetVector<Instruction *>;

namespace polli {

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
void selectGV(Instruction &I, GlobalList &Globals) {
  if (isa<llvm::IntrinsicInst>(&I))
    return;

  for (unsigned i = 0; i < I.getNumOperands(); i++) {
    Value *V = I.getOperand(i);

    if (V) {
      // RemapCalls can take care of this.
      if (!isa<Function>(V))
        if (GlobalValue *GV = dyn_cast<GlobalValue>(V)) {
          Globals.insert(GV);
        }

      if (ConstantExpr *C = dyn_cast<ConstantExpr>(V)) {
        Instruction *Inst = C->getAsInstruction();
        selectGV(*Inst, Globals);
      }
    }
  }
}

using InstrList = SmallVector<Instruction *, 4>;
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
void constantExprToInstruction(Instruction &I, InstrList &Converted,
                               ValueToValueMapTy &VMap) {
  ValueToValueMapTy OperandMap;
  for (auto &Op : I.operands()) {
    Value *V = Op.get();
    if (ConstantExpr *C = dyn_cast<ConstantExpr>(V)) {
      Instruction *Inst = C->getAsInstruction();
      Inst->insertBefore(&I);
      OperandMap[V] = Inst;
      constantExprToInstruction(*Inst, Converted, VMap);
      Converted.push_back(&I);
    }
  }

  for (unsigned i = 0; i < I.getNumOperands(); ++i) {
    Value *OldOp = I.getOperand(i);
    if (OperandMap.count(OldOp)) {
      I.setOperand(i, OperandMap[OldOp]);
    }
  }
}
} // namespace polli // namespace polli
