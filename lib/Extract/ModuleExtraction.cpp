#include "polli/FunctionCloner.h"
#include "polli/ScopDetection.h"
#include "polli/ModuleExtractor.h"
#include "polli/Schema.h"
#include "polli/Stats.h"
#include "polli/log.h"

#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"
#include "llvm/Transforms/IPO.h"

using namespace llvm;
#define DEBUG_TYPE "polyjit"

STATISTIC(Instrumented, "Number of instrumented functions");
STATISTIC(MappedGlobals, "Number of global to argument redirections");
STATISTIC(UnmappedGlobals, "Number of argument to global redirections");
STATISTIC(DuplicatePredsInPHI, "Number of functions that contain duplicate "
                               "predecessor lists in some PHI nodes.");
REGISTER_LOG(console, "extract");

namespace polli {
char ModuleExtractor::ID = 0;

using ModulePtrT = std::unique_ptr<Module>;

static ModulePtrT copyModule(ValueToValueMapTy &VMap, Module &M) {
  auto NewM = ModulePtrT(new Module(M.getModuleIdentifier(), M.getContext()));
  NewM->setDataLayout(M.getDataLayout());
  NewM->setTargetTriple(M.getTargetTriple());
  NewM->setMaterializer(M.getMaterializer());
  NewM->setModuleInlineAsm(M.getModuleInlineAsm());

  return NewM;
}

void ModuleExtractor::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<JITScopDetection>();
  AU.addRequired<CallGraphWrapperPass>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<ScalarEvolutionWrapperPass>();
}

void ModuleExtractor::releaseMemory() { InstrumentedFunctions.clear(); }

/**
 * @brief Convert a module to a string.
 *
 * @param M the module to convert
 *
 * @return a string containing the LLVM IR
 */
static std::string moduleToString(Module &M) {
  std::string ModStr;
  raw_string_ostream os(ModStr);
  AnalysisManager<Module> AM;
  ModulePassManager PM;
  PrintModulePass PrintModuleP(os);

  PM.addPass(PrintModuleP);
  PM.run(M, AM);

  os.flush();
  return ModStr;
}

using ExprList = SetVector<Instruction *>;
using GlobalList = SetVector<const GlobalValue *>;

/**
 * @brief Get the pointer operand to this Instruction, if possible
 *
 * @param I the Instruction we fetch the pointer operand from, if it has one.
 *
 * @return the pointer operand, if it exists.
 */

/**
 * @brief Get the pointer operand to this Instruction, if possible.
 *
 * @param I The Instruction we fetch the pointer operand from, if it has one.
 * @return llvm::Value* The pointer operand we found.
 */
static Value *getPointerOperand(Instruction &I) {
  Value *V = nullptr;

  if (BitCastInst *B = dyn_cast<BitCastInst>(&I))
    V = B->getOperand(0);

  if (LoadInst *L = dyn_cast<LoadInst>(&I))
    V = L->getPointerOperand();

  if (StoreInst *S = dyn_cast<StoreInst>(&I))
    V = S->getPointerOperand();

  if (GetElementPtrInst *G = dyn_cast<GetElementPtrInst>(&I))
    V = G->getPointerOperand();

  return V;
}

/**
 * @brief Set the pointer operand for this instruction to a new value.
 *
 * This is done by creating a new (almost identical) instruction that replaces
 * the new one.
 *
 * @param I The instruction we set a new pointer operand for.
 * @param V The value we set as new pointer operand.
 * @return void
 */
static void setPointerOperand(Instruction &I, Value &V,
                              ValueToValueMapTy &VMap) {
  if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
    LI->llvm::User::setOperand(0, &V);
  } else if (StoreInst *S = dyn_cast<StoreInst>(&I)) {
    S->setOperand(/*Address operand=*/1, &V);
  } else if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(&I)) {
    GEP->setOperand(0, &V);
  } else if (BitCastInst *Cast = dyn_cast<BitCastInst>(&I)) {
    Cast->setOperand(0, &V);
  }
}

/**
 * @brief Get the number of globals we carry within this function signature.
 *
 * @param F The Function we want to cound the globals on.
 * @return size_t The number of globals we carry with this function signature.
 */
static inline size_t getGlobalCount(Function *F) {
  size_t n = 0;
  if (F->hasFnAttribute("polyjit-global-count"))
    if (!(std::stringstream(
              F->getFnAttribute("polyjit-global-count").getValueAsString()) >>
          n))
      n = 0;
  return n;
}

#ifdef DEBUG
static void dumpUsers(Value &V) {
  for (const auto &U : V.users()) {
    U->print(outs().indent(2));
    outs() << "\n";
  }
  llvm::outs() << "====\n";
}
#endif

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
static inline void constantExprToInstruction(Instruction &I,
                                             InstrList &Converted,
                                             ValueToValueMapTy &VMap) {
  Value *V = getPointerOperand(I);
  if (V) {
    if (ConstantExpr *C = dyn_cast<ConstantExpr>(V)) {
      Instruction *Inst = C->getAsInstruction();
      Inst->insertBefore(&I);
      DEBUG({
        llvm::outs() << "I: " << I << "\nInst: " << *Inst << "\n";
        llvm::outs() << "Users:\n";
        dumpUsers(*C);
      });
      setPointerOperand(I, *Inst, VMap);
      constantExprToInstruction(*Inst, Converted, VMap);
      Converted.push_back(&I);
    }
  }
}

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
static T apply(Function &F,
               std::function<void(Instruction &I, T &L)> SelectorF) {
  T L;
  for (BasicBlock &BB : F)
    for (Instruction &I : BB)
      SelectorF(I, L);

  return L;
}

/**
 * @brief Get all globals variable used in this function.
 *
 * @param SrcF The function we collect globals from.
 * @return polli::GlobalList
 */
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
  /**
   * @brief Map the arguments from the source function to the target function.
   *
   * In the presence of global variables a correct mapping needs to make sure
   * that we keep track of the mapping between global variables and function
   * arguments.
   *
   * We do this by appending all referenced global variables of the source
   * function to the function signature of the target function.
   *
   * The ValueToValueMap provides the mechanism to actually change the
   * references in the target function during cloning.
   *
   * @param VMap Keeps track of the Argument/GlobalValue mappings.
   * @param From Mapping source Function.
   * @param To Mapping target Function.
   * @return void
   */
  void MapArguments(ValueToValueMapTy &VMap, Function *From,
                           Function *To) {
    Function::arg_iterator NewArg = To->arg_begin();
    for (Argument &Arg : From->args()) {
      NewArg->setName(Arg.getName());
      VMap[&Arg] = &*(NewArg++);
    }

    LLVMContext &Ctx = To->getContext();
    Attribute ParamAttr =
        llvm::Attribute::get(Ctx, "polli.gv");
    AttrBuilder Builder;
    Builder.addAttribute(Attribute::NonNull);
    Builder.addAttribute(ParamAttr);

    GlobalList ReqGlobals = getGVsUsedInFunction(*From);
    for (const GlobalValue *GV : ReqGlobals) {
      // It's actually a global variable, so we guarantee that this pointer
      // is not null.
      NewArg->addAttr(AttributeSet::get(Ctx, 0, Builder));
      NewArg->addAttr(AttributeSet::get(Ctx, 1, Builder));

      /* FIXME: We rely heavily on the name later on.
       * The problem is that we do not keep track of mappings between
       * different invocations of the FunctionCloner.
       */
      NewArg->setName(GV->getName());
      VMap[GV] = &*(NewArg++);
      MappedGlobals++;
    }
  }

  /**
   * @brief Create a new Function that is able to keep track of GlobalValues.
   *
   * The Function remaps all references to GlobalValues in the body to function
   * arguments.
   * The number of GlobalValues we keep track of is annotated as function
   * attribute: "polyjit-global-count".
   *
   * @param From Source function.
   * @param To Target function.
   * @return llvm::Function*
   */
  Function *Create(Function *From, Module *To) {
    GlobalList ReqGlobals = getGVsUsedInFunction(*From);
    ArgListT Args;

    for (auto &Arg : From->args())
      Args.push_back(Arg.getType());

    for (const GlobalValue *GV : ReqGlobals)
      Args.push_back(GV->getType());

    FunctionType *FType = FunctionType::get(From->getReturnType(), Args, false);
    Function *F =
        Function::Create(FType, From->getLinkage(), From->getName(), To);

    // Set the global count attribute in the _source_ function, because
    // the function cloner will copy over all attributes from SrcF to
    // TgtF afterwards.
    From->addFnAttr("polyjit-global-count",
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
  /**
   * @brief Remove function arguments that are available as globals.
   *
   * This is the inverse policy to the AddGlobalsPolicy. It takes n function
   * arguments from the back of the signature, where n is the number of tracked
   * GlobalValues in the source, and remaps them to GlobalValues of the same
   * name in the target module.
   * The mapping is recorded in a ValueToValueMap which is used during cloning
   * later on.
   *
   * @param VMap Keeps track of the Argument/GlobalValue mappings.
   * @param From Mapping source Function.
   * @param To Mapping target Function.
   * @return void
   */
  void MapArguments(ValueToValueMapTy &VMap, Function *From,
                           Function *To) {
    size_t FromArgCnt = From->arg_size() - getGlobalCount(From);
    Module &ToM = *To->getParent();
    Function::arg_iterator ToArg = From->arg_begin();

    size_t i = 0;
    for (auto &FromArg : From->args())
      if (i++ >= FromArgCnt) {
        if (GlobalValue *GV = ToM.getGlobalVariable(FromArg.getName(), true)) {
          VMap[&FromArg] = GV;
          UnmappedGlobals++;
        }
      } else {
        VMap[&FromArg] = &*(ToArg++);
      }
  }

  /**
   * @brief Create a new Function that does not track GlobalValues anymore.
   *
   * @param From Source function.
   * @param To Target function.
   * @return llvm::Function*
   */
  Function *Create(Function *From, Module *ToM) {
    ArgListT Args;
    size_t ArgCount = From->arg_size() - getGlobalCount(From);

    size_t i = 0;
    for (auto &Arg : From->args())
      if (i++ < ArgCount) {
        Args.push_back(Arg.getType());
      }

    return Function::Create(
        FunctionType::get(From->getReturnType(), Args, false),
        From->getLinkage(), From->getName(), ToM);
  }
};

/**
 * @brief Extract a module containing a single function as a prototype.
 *
 * The function is copied into a new module using the AddGlobalsPolicy.
 * It is important to avoid using the DestroySource policy here as long as
 * the module extraction is done within a FunctionPass.
 *
 * @param VMap ValueToValue mappings collected from previous FunctionCloner runs
 * @param F The Function we extract as prototype.
 * @param M The Module we copy the function to.
 * @return llvm::Function* The prototype Function in the new Module.
 */
static Function *extractPrototypeM(ValueToValueMapTy &VMap, Function &F,
                                   Module &M) {
  static unsigned int i = 65536;
  using ExtractFunction =
      FunctionCloner<AddGlobalsPolicy, IgnoreSource, IgnoreTarget>;
  using namespace std::placeholders;

  DEBUG(dbgs() << fmt::format("Source to Prototype -> {:s}\n",
                              F.getName().str()));
  // Prepare the source function.
  // We need to substitute all instructions that use ConstantExpressions.
  InstrList Converted = apply<InstrList>(
      F, std::bind(constantExprToInstruction, _1, _2, std::ref(VMap)));


  // First create a new prototype function.
  ExtractFunction Cloner(VMap, &M);
  Function *Proto = Cloner.setSource(&F).start(true);
  Proto->addFnAttr("polyjit-id", fmt::format("{:d}", i++));
  return Proto;
}

/**
 * @brief Endpoint policy that instruments the target Function for PolyJIT
 *
 * Instrumentation in the sense of PolyJIT means that the function is replaced
 * with an indirection that calls the JIT with a pointer to a prototype Function
 * string and the parameters in the form of an array of pointers.
 *
 */
struct InstrumentEndpoint {

  /**
   * @brief The prototype function we pass into the JIT callback.
   *
   * @param Prototype A prototype value that gets passed to the JIT as string.
   * @return void
   */
  void setPrototype(Value *Prototype) { PrototypeF = Prototype; }

  /**
   * @brief Setter for a fallback function that will be called.
   *
   * The fallback function is the function that will be called when the JIT
   * reports that it cannot fullfill a request in time.
   *
   * This automatically forces the client to execute the fallback in parallel
   * to the JIT' request.
   *
   * @param F The function we use as fallback when the JIT is not ready.
   */
  void setFallback(Function *F) { FallbackF = F; }

  /**
   * @brief Apply the JIT indirection to the target Function.
   *
   * 1. Create a JIT callback function signature, in the form of:
   *    void pjit_main(char *Prototype, int argc, char *argv)
   * 2. Empty the target function.
   * 3. Allocate an array with length equal to the number of arguments in the
   *    source Function.
   * 4. Place pointer to the source Functions arguments in the array.
   * 5. Call pjit_main with the prototype and the source functions arguments.
   *
   * @param From Source Function.
   * @param To Target Function.
   * @param VMap ValueToValueMap that carries all previous mappings.
   * @return void
   */
  void Apply(Function *From, Function *To, ValueToValueMapTy &VMap) {
    assert(From && "No source function!");
    assert(To && "No target function!");
    assert(FallbackF && "No fallback function!");

    if (To->isDeclaration())
      return;

    Module *M = To->getParent();
    assert(M && "TgtF has no parent module!");

    LLVMContext &Ctx = M->getContext();

    Function *PJITCB = cast<Function>(M->getOrInsertFunction(
        "pjit_main", Type::getInt1Ty(Ctx), Type::getInt8PtrTy(Ctx),
        Type::getInt64PtrTy(Ctx), Type::getInt32Ty(Ctx),
        Type::getInt8PtrTy(Ctx), NULL));
    PJITCB->setLinkage(GlobalValue::ExternalLinkage);

    Function *TraceFnStatsEntry = cast<Function>(M->getOrInsertFunction(
        "pjit_trace_fnstats_entry", Type::getVoidTy(Ctx),
        Type::getInt64PtrTy(Ctx), Type::getInt1Ty(Ctx), NULL));
    Function *TraceFnStatsExit = cast<Function>(M->getOrInsertFunction(
        "pjit_trace_fnstats_exit", Type::getVoidTy(Ctx),
        Type::getInt64PtrTy(Ctx), Type::getInt1Ty(Ctx), NULL));

    To->deleteBody();
    To->setLinkage(GlobalValue::WeakAnyLinkage);

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
        Value *ArrIdx = ConstantInt::get(Type::getInt32Ty(Ctx), i);
        Value *Dest = Builder.CreateInBoundsGEP(Params, {Idx0, ArrIdx});

        Builder.CreateStore(
            Builder.CreateBitCast(GV, StackArrayT->getArrayElementType()),
            Dest);
      }
    }

    Value *PrefixData = polli::registerStatStruct(*To, To->getName());
    PrefixData = Builder.CreateBitCast(PrefixData, Type::getInt64PtrTy(Ctx));
    Value *CastParams = Builder.CreateBitCast(Params, Type::getInt8PtrTy(Ctx));

    SmallVector<Value *, 4> Args;
    Args.push_back((PrototypeF) ? PrototypeF
                                : Builder.CreateGlobalStringPtr(To->getName()));
    Args.push_back(PrefixData);
    Args.push_back(ParamC);
    Args.push_back(CastParams);

    BasicBlock *JitReady = BasicBlock::Create(Ctx, "polyjit.ready", To);
    BasicBlock *JitNotReady = BasicBlock::Create(Ctx, "polyjit.not.ready", To);
    BasicBlock *Exit = BasicBlock::Create(Ctx, "polyjit.exit", To);
    CallInst *ReadyCheck = Builder.CreateCall(PJITCB, Args);

    Builder.CreateCondBr(ReadyCheck, JitReady, JitNotReady);
    Builder.SetInsertPoint(JitReady);
    Builder.CreateBr(Exit);
    Builder.SetInsertPoint(JitNotReady);

    // Just hand the args from the function down to the source function.
    SmallVector<Value *, 3> ToArgs;
    for (auto &Arg: To->args()) {
      ToArgs.push_back(&Arg);
    }

    // We need to replace all uses of our fallback function with the new
    // instrumented version _before_ we create the call to the fallback
    // function, otherwise we would call ourselves until the jit is ready.
    FallbackF->replaceAllUsesWith(To);

    Value *False = ConstantInt::getFalse(Ctx);

    Builder.CreateCall(TraceFnStatsEntry, {PrefixData, False});
    Builder.CreateCall(FallbackF, ToArgs);
    Builder.CreateCall(TraceFnStatsExit, {PrefixData, False});
    Builder.CreateBr(Exit);
    Builder.SetInsertPoint(Exit);
    Builder.CreateRetVoid();
  }

private:
  Value *PrototypeF;
  Function *FallbackF;
};

static inline void collectRegressionTest(const std::string Name,
                                         const std::string &ModStr) {
  if (!opt::CollectRegressionTests) {
    return;
  }
  using namespace db;

  auto T = std::shared_ptr<Tuple>(new RegressionTest(Name, ModStr));
  db::Session S;
  S.add(T);
  S.commit();
}

static void clearFunctionLocalMetadata(Function *F) {
  if (!F)
    return;

  SmallVector<Instruction *, 4> DeleteInsts;
  for (auto &I : instructions(F)) {
    if (DbgInfoIntrinsic *DI = dyn_cast_or_null<DbgInfoIntrinsic>(&I)) {
      DeleteInsts.push_back(DI);
    }
  }

  for (auto *I : DeleteInsts) {
      I->removeFromParent();
  }
}

struct SCEVParamValueExtractor
    : public SCEVVisitor<SCEVParamValueExtractor, const SCEV *> {
  SetVector<Value *> ParamValues;
  ScalarEvolution &SE;

  SCEVParamValueExtractor(ScalarEvolution &SE) : SE(SE) {}

  static SetVector<Value *> extract(const SCEV *P, ScalarEvolution &SE) {
    SCEVParamValueExtractor SPVE(SE);
    SPVE.visit(P);
    return SPVE.ParamValues;
  }

  const SCEV *visitConstant(const SCEVConstant *S) {
    return S;
  }

  const SCEV *visitTruncateExpr(const SCEVTruncateExpr *S) {
    visit(S->getOperand());
    return S;
  }

  const SCEV *visitZeroExtendExpr(const SCEVZeroExtendExpr *S) {
    visit(S->getOperand());
    return S;
  }

  const SCEV *visitSignExtendExpr(const SCEVSignExtendExpr *S) {
    visit(S->getOperand());
    return S;
  }

  const SCEV *visitAddExpr(const SCEVAddExpr *S) {
    for (auto *Op : S->operands()) {
      visit(Op);
    }
    return S;
  }

  const SCEV *visitMulExpr(const SCEVMulExpr *S) {
    for (auto *Op : S->operands()) {
      visit(Op);
    }
    return S;
  }

  const SCEV *visitSMaxExpr(const SCEVSMaxExpr *S) {
    for (auto *Op : S->operands()) {
      visit(Op);
    }
    return S;
  }

  const SCEV *visitUMaxExpr(const SCEVUMaxExpr *S) {
    for (auto *Op : S->operands()) {
      visit(Op);
    }
    return S;
  }

  const SCEV *visitUDivExpr(const SCEVUDivExpr *S) {
    visit(S->getLHS());
    visit(S->getRHS());
    return S;
  }

  const SCEV *visitAddRecExpr(const SCEVAddRecExpr *S) {
    visit(S->getStart());
    visit(S->getStepRecurrence(SE));
    return S;
  }

  const SCEV *visitUnknown(const SCEVUnknown *S) {
    ParamValues.insert(S->getValue());
    return S;
  }
};

using InstrumentingFunctionCloner =
    FunctionCloner<RemoveGlobalsPolicy, IgnoreSource, InstrumentEndpoint>;

static CallSite findExtractedCallSite(Function &F, Function &SrcF) {
  for (auto &Inst : instructions(&SrcF)) {
    CallSite CS(&Inst);
    if (CS.isCall() || CS.isInvoke()) {
      Function *CalledF = CS.getCalledFunction();
      if (CalledF == &F)
        return CS;
    }
  }
  return CallSite();
}

static bool hasDuplicatePredsInPHI(BasicBlock *BB) {
  for (Instruction &I : *BB) {
    if (PHINode *PHI = dyn_cast<PHINode>(&I)) {
      DenseMap<Value *, BasicBlock *> NewValues;
      SetVector<std::pair<Value *, BasicBlock *>> IncomingValues;
      unsigned n = PHI->getNumIncomingValues();

      for (unsigned i = 0; i < n; i++) {
        Value *V = PHI->getIncomingValue(i);
        BasicBlock *BB = PHI->getIncomingBlock(i);
        if (BB && !IncomingValues.insert(std::make_pair(V, BB)))
          return true;
      }
    }
  }
  return false;
}

static bool hasDuplicatePredsInPHI(Function &F) {
  for (BasicBlock &BB : F)
    if (hasDuplicatePredsInPHI(&BB))
      return true;
  return false;
}


static void fixSuccessorPHI(BasicBlock *BB) {
  if (!BB)
    return;

  for (BasicBlock *Succ : llvm::successors(BB)) {
    for (Instruction &I : *Succ) {
      if (PHINode *PHI = dyn_cast<PHINode>(&I)) {
        unsigned n = PHI->getNumIncomingValues();
        SetVector<BasicBlock *> IncomingEdges;
        SmallVector<int, 2> MarkedIndices;
        for (unsigned i = 0; i < n; i++) {
          BasicBlock *Pred = PHI->getIncomingBlock(n-(i+1));
          if (!IncomingEdges.insert(Pred))
            MarkedIndices.push_back(n-(i+1));
        }
        for (int j : MarkedIndices) {
          PHI->removeIncomingValue(j);
        }
      }
    }
  }
}

/**
 * @brief Extract all regions marked for extraction into an own function and
 * mark it * as 'polyjit-jit-candidate'.
 */
static SetVector<Function *> extractCandidates(Function &F,
                                               JITScopDetection &SD,
                                               ScalarEvolution &SE,
                                               DominatorTree &DT) {
  SetVector<Function *> Functions;
  std::set<Value *> TrackedParams;
  LLVMContext &Ctx = F.getContext();
  Attribute ParamAttr = llvm::Attribute::get(Ctx, "polli.specialize");
  AttrBuilder Builder(ParamAttr);
  if (hasDuplicatePredsInPHI(F)) {
    DuplicatePredsInPHI++;
    return Functions;
  }

  for (const Region *R : SD) {
    CodeExtractor Extractor(DT, *(R->getNode()), /*AggregateArgs*/ false);
    console->info("Extracting region: {:s}", R->getNameStr());
    if (Extractor.isEligible()) {
      JITScopDetection::ParamVec Params = SD.RequiredParams[R];
      SetVector<Value *> In, Out;
      Extractor.findInputsOutputs(In, Out);
      for (auto *P : Params) {
        SetVector<Value *> Values = SCEVParamValueExtractor::extract(P, SE);
        std::set_intersection(
            In.begin(), In.end(), Values.begin(), Values.end(),
            std::inserter(TrackedParams, TrackedParams.end()));
      }

      if (Function *ExtractedF = Extractor.extractCodeRegion()) {
        CallSite FunctionCall = findExtractedCallSite(*ExtractedF, F);
        if (FunctionCall.isCall() || FunctionCall.isInvoke()) {
          Instruction *I = FunctionCall.getInstruction();
          BasicBlock *BB = I->getParent();
          auto Arg = ExtractedF->arg_begin();
          for (Use &U : I->operands()) {
            Value *Operand = U.get();
            if (TrackedParams.count(Operand))
              Arg->addAttr(AttributeSet::get(Ctx, 0, Builder));
            Arg++;
          }
          fixSuccessorPHI(BB);
        }

        ExtractedF->setLinkage(GlobalValue::WeakAnyLinkage);
        ExtractedF->setName(F.getName() + ".pjit.scop");
        ExtractedF->addFnAttr("polyjit-jit-candidate");

        Functions.insert(ExtractedF);
      }
    }
  }
  return Functions;
}

/**
 * @brief Extract all SCoP regions in a function into a new Module.
 *
 * This extracts all SCoP regions that are marked for extraction by
 * the ScopDetection pass into a new Module that gets stored as a prototype in
 * the original module. The original function is then replaced with a
 * new version that calls an indirection called 'pjit_main' with the
 * prototype function and original function's arguments as parameters.
 *
 * From there, the PolyJIT can begin working.
 *
 * @param F The Function we extract all SCoPs from.
 * @return bool
 */
bool ModuleExtractor::runOnFunction(Function &F) {
  SetVector<Function *> Functions;
  bool Changed = false;

  if (F.isDeclaration())
    return false;
  if (F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  JITScopDetection &SD = getAnalysis<JITScopDetection>();
  ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();

  Functions = extractCandidates(F, SD, SE, DT);
  if (Functions.size() > 0)
    Changed |= true;

  // Instrument all extracted functions.
  for (Function *F : Functions) {
    if (F->isDeclaration())
      continue;
    console->info("Extracting: {:s}", F->getName().str());

    ValueToValueMapTy VMap;
    Module *M = F->getParent();
    StringRef ModuleName = F->getParent()->getModuleIdentifier();
    StringRef FromName = F->getName();
    ModulePtrT PrototypeM = copyModule(VMap, *M);

    PrototypeM->setModuleIdentifier((ModuleName + "." + FromName).str() +
                                    ".prototype");
    Function *ProtoF = extractPrototypeM(VMap, *F, *PrototypeM);

    llvm::legacy::PassManager MPM;
    MPM.add(llvm::createStripSymbolsPass(true));
    MPM.run(*PrototypeM);

    clearFunctionLocalMetadata(F);

    // Make sure that we do not destroy the function before we're done
    // using the IRBuilder, otherwise this will end poorly.
    IRBuilder<> Builder(&*(F->begin()));
    const std::string ModStr = moduleToString(*PrototypeM);
    Value *Prototype =
        Builder.CreateGlobalStringPtr(ModStr, FromName + ".prototype");

    // Persist the resulting prototype for later reuse.
    // A separate tool should then try to generate a LLVM-lit test that
    // tries to detect that again.
    collectRegressionTest(FromName, ModStr);

    InstrumentingFunctionCloner InstCloner(VMap, M);
    InstCloner.setSource(ProtoF);
    InstCloner.setPrototype(Prototype);
    InstCloner.setFallback(F);

    Function *InstF = InstCloner.start(/* RemapCalls */ true);
    InstF->addFnAttr(Attribute::OptimizeNone);
    InstF->addFnAttr(Attribute::NoInline);

    InstrumentedFunctions.insert(InstF);
    VMap.clear();
    Instrumented++;
  }

  return Changed;
}

void ModuleExtractor::print(raw_ostream &os, const Module *M) const {
  int i = 0;
  for (const Function *F : InstrumentedFunctions) {
    os << fmt::format("{:d} {:s} ", i++, F->getName().str());
    F->print(os);
    os << "\n";
  }
}

static RegisterPass<ModuleExtractor>
    X("polli-extract-scops", "PolyJIT - Move extracted SCoPs into new modules");
} // namespace polli
