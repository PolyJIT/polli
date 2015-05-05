#include "polli/ModuleExtractor.h"
#include "polli/ScopMapper.h"
#include "polli/FunctionCloner.h"

#include "llvm/ADT/SetVector.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"

#include "llvm/IR/Function.h"
#include "llvm/Pass.h"

#define FMT_HEADER_ONLY
#include "cppformat/format.h"

using namespace llvm;

namespace polli {
char ModuleExtractor::ID = 0;

using ModulePtrT = Module *;

static ModulePtrT copyModule(ValueToValueMapTy &VMap, Module &M) {
  ModulePtrT NewM = new Module(M.getModuleIdentifier(), M.getContext());
  NewM->setDataLayout(M.getDataLayout());
  NewM->setTargetTriple(M.getTargetTriple());
  NewM->setMaterializer(M.getMaterializer());
  NewM->setModuleInlineAsm(M.getModuleInlineAsm());

  return NewM;
}

void ModuleExtractor::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopMapper>();
}

void ModuleExtractor::releaseMemory() {
}

/**
 * @brief Convert a module to a string.
 *
 * @param M the module to convert
 *
 * @return a string containing the LLVM IR
 */
static std::string moduleToString(Module &M) {
  std::string ModStr;
  llvm::raw_string_ostream os(ModStr);
  ModulePassManager PM;
  PrintModulePass PrintModuleP(os);

  PM.addPass(PrintModuleP);
  PM.run(M);

  os.flush();
  return ModStr;
}

using ExprList = SetVector<Instruction *>;
using GlobalList = SetVector<const GlobalValue *>;

/**
 * @brief Get the pointer operand to this Instruction, if possible
 *
 * @param I
 *
 * @return the pointer operand, if it exists.
 */
static Value *getPointerOperand(Instruction &I) {
  Value *V = nullptr;

  if (LoadInst *L = dyn_cast<LoadInst>(&I))
    V = L->getPointerOperand();

  if (StoreInst *S = dyn_cast<StoreInst>(&I))
    V = S->getPointerOperand();

  if (GetElementPtrInst *G = dyn_cast<GetElementPtrInst>(&I))
    V = G->getPointerOperand();

  return V;
}

static inline Instruction *getInsertPoint(Instruction &I) {
  Function *F = I.getParent()->getParent();
  return F->getEntryBlock().begin();
}

static inline size_t getGlobalCount(Function *F) {
  size_t n = 0;
  if (F->hasFnAttribute("polyjit-global-count"))
    if (!(std::stringstream(
              F->getFnAttribute("polyjit-global-count").getValueAsString()) >>
          n))
      n = 0;
  return n;
}

using InstrList = SmallVector<Instruction *, 4>;
static inline void constantExprToInstruction(Instruction &I,
                                             InstrList &Converted) {
  Value *V = getPointerOperand(I);
  if (V) {
    if (ConstantExpr *C = dyn_cast<ConstantExpr>(V)) {
      Instruction *Inst = C->getAsInstruction();
      Inst->insertBefore(getInsertPoint(I));
      C->replaceAllUsesWith(Inst);
    }
  }
}

static inline void selectGV(Instruction &I, GlobalList &Globals) {
  Value *V = getPointerOperand(I);

  if (V) {
    if (GlobalValue *GV = dyn_cast<GlobalValue>(V))
      Globals.insert(GV);

    if (ConstantExpr *C = dyn_cast<ConstantExpr>(V)) {
      Instruction *Inst = C->getAsInstruction();
      selectGV(*Inst, Globals);
    }
  }
}

template <typename T>
static T apply(Function &F,
               std::function<void(Instruction &I, T &L)> SelectorF) {
  T L;
  for (BasicBlock &BB : F)
    for (Instruction &I : BB)
      SelectorF(I, L);

  return L;
}

static GlobalList getGVsUsedInFunction(Function &SrcF) {
  return apply<GlobalList>(SrcF, selectGV);
}

using ArgListT = SmallVector<Type *, 4>;
/**
 * @brief Collect referenced globals as pointer arguments.
 *
 * This adds global variables referenced in the function body to the
 * function signature via pointer arguments.
 */
struct AddGlobalsPolicy {
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    Function::arg_iterator NewArg = TgtF->arg_begin();
    for (Argument &Arg : SrcF->args()) {
      NewArg->setName(Arg.getName());
      VMap[&Arg] = NewArg++;
    }

    GlobalList ReqGlobals = getGVsUsedInFunction(*SrcF);
    for (const GlobalValue *GV : ReqGlobals) {
      AttrBuilder Builder;
      Builder.addAttribute(Attribute::NonNull);
      Builder.addAttribute(Attribute::Dereferenceable);

      NewArg->addAttr(AttributeSet::get(TgtF->getContext(), 1, Builder));
      NewArg->setName(GV->getName());
      VMap[GV] = NewArg++;
    }
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    GlobalList ReqGlobals = getGVsUsedInFunction(*SrcF);
    ArgListT Args;

    for (auto &Arg : SrcF->args())
      Args.push_back(Arg.getType());

    for (const GlobalValue *GV : ReqGlobals)
      Args.push_back(GV->getType());

    FunctionType *FType = FunctionType::get(SrcF->getReturnType(), Args, false);
    Function *F =
        Function::Create(FType, SrcF->getLinkage(), SrcF->getName(), TgtM);

    // Set the global count attribute in the _source_ function, because
    // the function cloner will copy over all attributes from SrcF to
    // TgtF afterwards.
    SrcF->addFnAttr("polyjit-global-count",
                    fmt::format("{:d}", ReqGlobals.size()));
    return F;
  }
};

/**
 * @brief Remove global variables from argument signature.
 *
 * This is used in conjunction with AddGlobalsPolicy. The number of global
 * variables we need to remove is determined by the 'polyjit-global-count'
 * function attribute.
 */
struct RemoveGlobalsPolicy {
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    size_t ArgCount = SrcF->arg_size() - getGlobalCount(SrcF);
    Module &M = *TgtF->getParent();

    size_t i = 0;
    for (auto &Arg : TgtF->args())
      if (i++ >= ArgCount) {
        if (GlobalValue *GV = M.getGlobalVariable(Arg.getName()))
          VMap[&Arg] = GV;
      }
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    ArgListT Args;
    size_t ArgCount = SrcF->arg_size() - getGlobalCount(SrcF);

    for (auto &Arg : SrcF->args())
      if (ArgCount-- > 0)
        Args.push_back(Arg.getType());

    FunctionType *FType = FunctionType::get(SrcF->getReturnType(), Args, false);
    return Function::Create(FType, SrcF->getLinkage(), SrcF->getName(), TgtM);
  }
};


static Function *extractPrototypeM(ValueToValueMapTy &VMap, Function &F,
                                   Module &M) {
  using MoveFunction =
      FunctionCloner<AddGlobalsPolicy, IgnoreSource, IgnoreTarget>;

  // Prepare the source function.
  // We need to substitute all instructions that use ConstantExpressions.
  apply<InstrList>(F, constantExprToInstruction);

  // First create a new prototype function.
  MoveFunction Cloner(VMap, &M);
  return Cloner.setSource(&F).start();
}

struct InstrumentEndpoint {
  void setPass(Pass *HostPass) { P = HostPass; }
  void setPrototype(Value *Prototype) {
    PrototypeF = Prototype;
  }

  Pass *getPass() { return P; }

  void Apply(Function *TgtF, Function *SrcF, ValueToValueMapTy &) {
    if (TgtF->isDeclaration())
      return;

    Module *M = TgtF->getParent();
    LLVMContext &Ctx = M->getContext();

    StringRef cbName = StringRef("pjit_main");
    PointerType *PtoArr = PointerType::get(Type::getInt8PtrTy(Ctx), 0);
    Function *PJITCB = cast<Function>(M->getOrInsertFunction(
        cbName, Type::getVoidTy(Ctx), Type::getInt8PtrTy(Ctx),
        Type::getInt32Ty(Ctx), PtoArr, NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);

    std::vector<Value *> Args(3);

    TgtF->deleteBody();
    TgtF->setLinkage(GlobalValue::InternalLinkage);

    BasicBlock *BB = BasicBlock::Create(Ctx, "polyjit.entry", TgtF);
    IRBuilder<> Builder(BB);
    Builder.SetInsertPoint(BB);

    /* Create a generic IR sequence of this example C-code:
     *
     * void foo(int n, int A[42]) {
     *  void *params[2];
     *  params[0] = &n;
     *  params[1] = A;
     *
     *  pjit_callback("foo", 2, params);
     * }
     */

    /* Prepare a stack array for the parameters. We will pass a pointer to
     * this array into our callback function. */
    int argc = TgtF->arg_size() + getGlobalCount(SrcF);
    Value *ParamC = ConstantInt::get(Type::getInt32Ty(Ctx), argc);
    Value *Params =
        Builder.CreateAlloca(Type::getInt8PtrTy(Ctx), ParamC, "params");

    /* Store each parameter as pointer in the params array */
    int i = 0;
    Value *Size1 = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
    for (Argument &Arg : TgtF->args()) {
      /* Get the appropriate slot in the parameters array and store
       * the stack slot in form of a i8*. */
      Value *IdxI = ConstantInt::get(Type::getInt32Ty(Ctx), i++);

      Value *Slot;
      if (Arg.getType()->isPointerTy()) {
        Slot = &Arg;
      } else {
        /* Allocate a slot on the stack for the i'th argument and store it */
        Slot = Builder.CreateAlloca(Arg.getType(), Size1);
        Builder.CreateStore(&Arg, Slot, "pjit.stack.param");

      }

      Value *Dest = Builder.CreateGEP(Params, IdxI);
      Value *Cast = Builder.CreateBitCast(Slot, Arg.getType()->getPointerTo());
      Builder.CreateStore(Cast, Dest);
    }

    // Append required global variables.
    Function::arg_iterator GlobalArgs = SrcF->arg_begin();
    for (int j = 0; j < i; j++)
      GlobalArgs++;
    for (; i < argc; i++) {
      StringRef Name = (GlobalArgs++)->getName();
      if (GlobalVariable *GV = M->getGlobalVariable(Name)) {
        /* Allocate a slot on the stack for the i'th argument and store it */
        Value *GlobalPtr =
            Builder.CreateConstGEP1_64(GV, 0, "polyjit.global.gep." + Name);

        /* Get the appropriate slot in the parameters array and store
         * the stack slot in form of a i8*. */
        Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i++);
        Value *Dest = Builder.CreateGEP(Params, ArrIdx);

        Builder.CreateStore(
            Builder.CreateBitCast(GlobalPtr, Type::getInt8PtrTy(Ctx)), Dest);
      }
    }

    Args[0] = (PrototypeF) ? PrototypeF
                           : Builder.CreateGlobalStringPtr(TgtF->getName());
    Args[1] = ParamC;
    Args[2] = Params;

    Builder.CreateCall(PJITCB, Args);
    Builder.CreateRetVoid();

    SrcF->getType()->print(outs() << "\nSrcF:");
    TgtF->print(outs() << "\nTgtF:");
  }

static Function *extractPrototypeM(ValueToValueMapTy &VMap, Function &F,
                                   Module &M) {
  using MoveFunction =
      FunctionCloner<AddGlobalsPolicy, IgnoreSource, IgnoreTarget>;

  // Prepare the source function.
  // We need to substitute all instructions that use ConstantExpressions.
  apply<InstrList>(F, constantExprToInstruction);

  // First create a new prototype function.
  MoveFunction Cloner(VMap, &M);
  return Cloner.setSource(&F).start();
}

private:
  Pass *P;
  Value *PrototypeF;
};



using InstrumentingFunctionCloner =
    FunctionCloner<RemoveGlobalsPolicy, IgnoreSource, InstrumentEndpoint>;

bool ModuleExtractor::runOnFunction(Function &F) {
  ScopMapper &SM = getAnalysis<ScopMapper>();

  Module &M = *(F.getParent());
  StringRef ModuleName = F.getParent()->getModuleIdentifier();
  ValueToValueMapTy VMap;
  IRBuilder<> Builder(F.begin());

  std::for_each(SM.begin(), SM.end(), [&](Function *F) {
    StringRef FunctionName = F->getName();

    ModulePtrT PrototypeM = copyModule(VMap, M);
    PrototypeM->setModuleIdentifier((ModuleName + "." + FunctionName).str() +
                                    ".prototype");

    Function *ProtoF = extractPrototypeM(VMap, *F, *PrototypeM);

    std::string PrototypeModStr = moduleToString(*PrototypeM);
    Value *Prototype = Builder.CreateGlobalStringPtr(
        PrototypeModStr, F->getName() + ".prototype");

    InstrumentingFunctionCloner InstCloner(VMap, &M);
    InstCloner.setSource(ProtoF);
    InstCloner.setSinkHostPass(&SM);
    InstCloner.setPrototype(Prototype);

    Function *InstF = InstCloner.start();
    InstF->addFnAttr(Attribute::OptimizeNone);

    F->replaceAllUsesWith(InstF);
    ProtoF->setName("prototype");
  });

  return true;
}

void ModuleExtractor::print(raw_ostream &, const Module *) const {
}

static RegisterPass<ModuleExtractor>
    X("polli-extract-scops", "PolyJIT - Move extracted SCoPs into new modules");
} // end of polli namespace
