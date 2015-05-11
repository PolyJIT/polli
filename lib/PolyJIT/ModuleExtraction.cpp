#include "polli/FunctionCloner.h"
#include "polli/ModuleExtractor.h"
#include "polli/ScopMapper.h"

#include "llvm/Pass.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"

using namespace llvm;
using namespace spdlog::details;

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
  AU.addRequired<DominatorTreeWrapperPass>();
}

void ModuleExtractor::releaseMemory() {}

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

static void setPointerOperand(Instruction &I, Value &V) {
  IRBuilder<> Builder = IRBuilder<>(&I);

  Value *NewV;
  if (isa<LoadInst>(&I)) {
    NewV = Builder.CreateLoad(&V);
  } else if (StoreInst *S = dyn_cast<StoreInst>(&I)) {
    NewV = Builder.CreateStore(S->getValueOperand(), &V);
  } else {
    return;
  }
  // else if (GetElementPtrInst *G = dyn_cast<GetElementPtrInst>(&I)) {
  //  NewV = Builder.CreateGEP
  //  G->setOperand(0, &V);
  //}

  I.replaceAllUsesWith(NewV);
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
      Inst->insertBefore(&I);
      setPointerOperand(I, *Inst);
      Converted.push_back(&I);
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
  static void MapArguments(ValueToValueMapTy &VMap, Function *From,
                           Function *To) {
    size_t FromArgCnt = From->arg_size() - getGlobalCount(From);
    Module &ToM = *To->getParent();
    Function::arg_iterator ToArg = From->arg_begin();

    size_t i = 0;
    for (auto &FromArg : From->args())
      if (i++ >= FromArgCnt) {
        if (GlobalValue *GV = ToM.getGlobalVariable(FromArg.getName(), true))
          VMap[&FromArg] = GV;
      } else {
        VMap[&FromArg] = ToArg++;
      }
  }

  static Function *Create(Function *SrcF, Module *TgtM) {
    ArgListT Args;
    size_t ArgCount = SrcF->arg_size() - getGlobalCount(SrcF);

    for (auto &Arg : SrcF->args())
      if (ArgCount-- > 0)
        Args.push_back(Arg.getType());

    return Function::Create(
        FunctionType::get(SrcF->getReturnType(), Args, false),
        SrcF->getLinkage(), SrcF->getName(), TgtM);
  }
};

static Function *extractPrototypeM(ValueToValueMapTy &VMap, Function &F,
                                   Module &M) {
  using ExtractFunction =
      FunctionCloner<AddGlobalsPolicy, IgnoreSource, IgnoreTarget>;

  outs() << fmt::format("Source to Prototype -> {:s}\n", F.getName().str());
  // Prepare the source function.
  // We need to substitute all instructions that use ConstantExpressions.
  InstrList Converted = apply<InstrList>(F, constantExprToInstruction);

  for (Instruction *I : Converted) {
    I->eraseFromParent();
  }

  // First create a new prototype function.
  ExtractFunction Cloner(VMap, &M);
  return Cloner.setSource(&F).start(true);
}

// @brief Instrument the endpoint after cloning.
//
// This endpoint is used to instrument a function as soon as cloning is
// complete. Usually this is used in the drain endpoint.
//
struct InstrumentEndpoint {
  void setPrototype(Value *Prototype) { PrototypeF = Prototype; }

  void Apply(Function *From, Function *To, ValueToValueMapTy &VMap) {
    assert(From && "No source function!");
    assert(To && "No target function!");

    if (To->isDeclaration())
      return;

    Module *M = To->getParent();
    assert(M && "TgtF has no parent module!");

    outs() << "pjit_main...\n";
    LLVMContext &Ctx = M->getContext();

    Function *PJITCB = cast<Function>(M->getOrInsertFunction(
        "pjit_main", Type::getVoidTy(Ctx), Type::getInt8PtrTy(Ctx),
        Type::getInt32Ty(Ctx), Type::getInt8PtrTy(Ctx), NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);

    outs() << "purge TgtF...\n";
    To->deleteBody();
    To->setLinkage(From->getLinkage());

    outs() << "new entry...\n";
    BasicBlock *BB = BasicBlock::Create(Ctx, "polyjit.entry", To);
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

    /* Store each parameter as pointer in the params array */
    int i = 0;
    Value *Size1 = ConstantInt::get(Type::getInt32Ty(Ctx), 1);
    Value *Idx0 = ConstantInt::get(Type::getInt32Ty(Ctx), 0);

    /* Prepare a stack array for the parameters. We will pass a pointer to
     * this array into our callback function. */
    int argc = To->arg_size() + getGlobalCount(From);
    Value *ParamC = ConstantInt::get(Type::getInt32Ty(Ctx), argc);
    ArrayType *StackArrayT = ArrayType::get(Type::getInt8PtrTy(Ctx), argc);
    Value *Params = Builder.CreateAlloca(StackArrayT, Size1, "params");

    outs() << "args...\n";
    for (Argument &Arg : To->args()) {
      /* Get the appropriate slot in the parameters array and store
       * the stack slot in form of a i8*. */
      Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i++);

      Value *Slot;
      if (Arg.getType()->isPointerTy()) {
        Slot = &Arg;
      } else {
        /* Allocate a slot on the stack for the i'th argument and store it */
        Slot = Builder.CreateAlloca(Arg.getType(), Size1);
        Builder.CreateStore(&Arg, Slot, "pjit.stack.param");
      }

      Value *Dest = Builder.CreateGEP(Params, {Idx0, ArrIdx});
      Builder.CreateStore(
          Builder.CreateBitCast(Slot, StackArrayT->getArrayElementType()),
          Dest);
    }

    outs() << "globals...\n";
    // Append required global variables.
    Function::arg_iterator GlobalArgs = From->arg_begin();
    for (int j = 0; j < i; j++)
      GlobalArgs++;
    for (; i < argc; i++) {
      StringRef Name = (GlobalArgs++)->getName();
      if (GlobalVariable *GV =
              M->getGlobalVariable(Name, /*AllowInternals*/ true)) {
        /* Get the appropriate slot in the parameters array and store
         * the stack slot in form of a i8*. */
        Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i++);
        Value *Dest = Builder.CreateGEP(Params, {Idx0, ArrIdx});

        Builder.CreateStore(
            Builder.CreateBitCast(GV, StackArrayT->getArrayElementType()),
            Dest);
      }
    }

    SmallVector<Value *, 3> Args;
    Args.push_back((PrototypeF) ? PrototypeF
                                : Builder.CreateGlobalStringPtr(To->getName()));
    Args.push_back(ParamC);
    Args.push_back(Builder.CreateBitCast(Params, Type::getInt8PtrTy(Ctx)));

    outs() << "jit callback...\n";
    Builder.CreateCall(PJITCB, Args);
    outs() << "return...\n";
    Builder.CreateRetVoid();
  }

private:
  Value *PrototypeF;
};

using InstrumentingFunctionCloner =
    FunctionCloner<RemoveGlobalsPolicy, IgnoreSource, InstrumentEndpoint>;

bool ModuleExtractor::runOnModule(Module &M) {
  SetVector<Function *> Functions;
  bool Changed = false;

  for (Function &F : M) {
    if (F.isDeclaration())
      continue;
    if (F.hasFnAttribute("polyjit-jit-candidate"))
      continue;

    DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
    ScopMapper &SM = getAnalysis<ScopMapper>(F);

    for (const Region *R : SM.regions()) {
      std::vector<BasicBlock *> Blocks;
      for (BasicBlock *BB : R->blocks())
        Blocks.push_back(BB);

      CodeExtractor Extractor(DT, *(R->getNode()), /*AggregateArgs*/ false);
      if (Extractor.isEligible()) {
        if (Function *ExtractedF = Extractor.extractCodeRegion()) {
          //ExtractedF->setLinkage(GlobalValue::InternalLinkage);
          ExtractedF->setName(ExtractedF->getName() + ".pjit.scop");
          ExtractedF->addFnAttr("polyjit-jit-candidate");
          Functions.insert(ExtractedF);
          Changed |= true;
        }
      }

      Blocks.clear();
    }
  }

  for (Function *F : Functions) {
    if (F->isDeclaration())
      continue;

    ValueToValueMapTy VMap;
    Module *M = F->getParent();
    StringRef ModuleName = F->getParent()->getModuleIdentifier();
    StringRef FromName = F->getName();
    ModulePtrT PrototypeM = copyModule(VMap, *M);

    PrototypeM->setModuleIdentifier((ModuleName + "." + FromName).str() +
                                    ".prototype");

    Function *ProtoF = extractPrototypeM(VMap, *F, *PrototypeM);

    // Make sure that we do not destroy the function before we're done
    // using the IRBuilder, otherwise this will end poorly.
    assert(F->begin() && "Body of function got destroyed too early!");
    IRBuilder<> Builder(F->begin());
    Value *Prototype = Builder.CreateGlobalStringPtr(
        moduleToString(*PrototypeM), FromName + ".prototype");

    outs() << fmt::format("\nInstrument prototype to source module -> {:s}\n",
                          ProtoF->getName().str());

    InstrumentingFunctionCloner InstCloner(VMap, M);
    InstCloner.setSource(ProtoF).setPrototype(Prototype);

    Function *InstF = InstCloner.start(/* RemapCalls */ true);
    outs() << fmt::format("\ninstrument prototpe completed\n");
    InstF->addFnAttr(Attribute::OptimizeNone);
    InstF->addFnAttr(Attribute::NoInline);

    F->replaceAllUsesWith(InstF);
    F->eraseFromParent();
    VMap.clear();
  }

  return Changed;
}

void ModuleExtractor::print(raw_ostream &, const Module *) const {}

static RegisterPass<ModuleExtractor>
    X("polli-extract-scops", "PolyJIT - Move extracted SCoPs into new modules");
} // end of polli namespace
