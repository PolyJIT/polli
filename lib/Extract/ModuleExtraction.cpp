#include "polli/FuncTools.h"
#include "polli/FunctionCloner.h"
#include "polli/ModuleExtractor.h"
#include "polli/Options.h"
#include "polli/Schema.h"
#include "polli/ScopDetection.h"
#include "polli/Stats.h"
#include "polli/Utils.h"
#include "polli/log.h"

#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"

using namespace llvm;
#define DEBUG_TYPE "polyjit"

STATISTIC(Instrumented, "Number of instrumented functions");
STATISTIC(Extracted, "Number of extracted SCoP functions");
STATISTIC(NotEligible,
          "Number of SCoP candidates that are not eligible for extraction.");
STATISTIC(DuplicatePredsInPHI, "Number of functions that contain duplicate "
                               "predecessor lists in some PHI nodes.");
REGISTER_LOG(console, "extract");

namespace polli {
char ModuleExtractor::ID = 0;
char ModuleInstrumentation::ID = 0;

using UniqueModule = std::unique_ptr<Module>;

static inline UniqueModule copyModule(const Module &M) {
  auto NewM = UniqueModule(new Module(M.getModuleIdentifier(), M.getContext()));
  NewM->setDataLayout(M.getDataLayout());
  NewM->setTargetTriple(M.getTargetTriple());
  NewM->setMaterializer(M.getMaterializer());
  NewM->setModuleInlineAsm(M.getModuleInlineAsm());

  return NewM;
}

void ModuleExtractor::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<JITScopDetection>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.addRequired<ScalarEvolutionWrapperPass>();
  AU.addRequired<RegionInfoPass>();
}

void ModuleExtractor::releaseMemory() { ExtractedFunctions.clear(); }

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

using ArgListT = SmallVector<Type *, 4>;

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
      FunctionCloner<CopyCreator, IgnoreSource, IgnoreTarget>;

  DEBUG(dbgs() << fmt::format("Source to Prototype -> {:s}\n",
                              F.getName().str()));
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
    std::string CallbackName = "pjit_main";
    if (polli::opt::DisableRecompile)
      CallbackName = "pjit_main_no_recompile";

    Function *PJITCB = cast<Function>(M->getOrInsertFunction(
        CallbackName, Type::getInt1Ty(Ctx), Type::getInt8PtrTy(Ctx),
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
    int argc = To->arg_size();
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
    for (auto &Arg : To->args()) {
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

  const SCEV *visitConstant(const SCEVConstant *S) { return S; }

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
    FunctionCloner<CopyCreator, IgnoreSource, InstrumentEndpoint>;

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
          BasicBlock *Pred = PHI->getIncomingBlock(n - (i + 1));
          if (!IncomingEdges.insert(Pred))
            MarkedIndices.push_back(n - (i + 1));
        }
        for (int j : MarkedIndices) {
          PHI->removeIncomingValue(j);
        }
      }
    }
  }
}

static void PrepareRegionForExtraction(const Region *R, RegionInfo &RI,
                                       DominatorTree &DT) {
  // This region lacks a single-exit edge.
  if (!R->getExitingBlock()) {
    BasicBlock *Exit = R->getExit();
    SmallVector<BasicBlock *, 4> ExitPreds;
    for (auto *PredBB : predecessors(Exit)) {
      if (R->contains(PredBB))
        ExitPreds.push_back(PredBB);
    }
    BasicBlock *NewBB =
        SplitBlockPredecessors(Exit, ExitPreds, ".polyjit.ext.split", &DT);
    RI.setRegionFor(NewBB, const_cast<Region *>(R));
  }

  for (auto *BB : R->blocks()) {
    if (isa<PHINode>(BB->begin())) {
      unsigned NumSuccessors = std::distance(succ_begin(BB), succ_end(BB));

      if (NumSuccessors > 1) {
        auto *AfterPHI = BB->getFirstNonPHI();
        BasicBlock *NewBB = SplitBlock(BB, AfterPHI, &DT);
        RI.setRegionFor(NewBB, const_cast<Region *>(R));
      }
    }
  }
}

static void printOperands(Value *V, raw_ostream &os, int level = 0) {
  if (Instruction *I = dyn_cast<Instruction>(V)) {
    I->print((os << "\n").indent(level) << "> ");

    if (!isa<PHINode>(I)) {
      for (auto &Op : I->operands()) {
        printOperands(Op.get(), os, level + 2);
      }
    }
  } else {
    V->print((os << "\n").indent(level) << "|= ");
  }
}

/**
 * @brief Extract all regions marked for extraction into an own function and
 * mark it * as 'polyjit-jit-candidate'.
 */
static SetVector<Function *>
extractCandidates(Function &F, JITScopDetection &SD, ScalarEvolution &SE,
                  DominatorTree &DT, RegionInfo &RI) {
  SetVector<Function *> Functions;
  std::set<Value *> TrackedParams;
  LLVMContext &Ctx = F.getContext();
  Attribute ParamAttr = llvm::Attribute::get(Ctx, "polli.specialize");
  AttrBuilder Builder(ParamAttr);
  if (hasDuplicatePredsInPHI(F)) {
    DuplicatePredsInPHI++;
    return Functions;
  }

  unsigned Cnt = 0;
  for (const Region *R : SD) {
    PrepareRegionForExtraction(R, RI, DT);
    CodeExtractor Extractor(DT, *(R->getNode()), /*AggregateArgs*/ false);

    if (Extractor.isEligible()) {
      JITScopDetection::ParamVec Params = SD.RequiredParams[R];

      SetVector<Value *> In, Out;
      Extractor.findInputsOutputs(In, Out);
      std::string buf;
      raw_string_ostream os(buf);
      DEBUG({
        os << "\n===========================================================";
        os << "\nExtract Region: " << R->getNameStr();
        os << "\n===========================================================";
        os << "\n Required Params:\n";
        for (auto *SCEV : Params)
          SCEV->print((os << "\n").indent(2) << ": ");
        os << "\n-----------------------------------------------------------";
        os << "\n In Values:\n";
        for (auto *Val : In)
          printOperands(Val, os);
        os << "\n-----------------------------------------------------------";
        os << "\n SCEV to Params:\n";
      });

      SetVector<Value *> ParamValues;
      for (auto *P : Params) {
        SetVector<Value *> Values = SCEVParamValueExtractor::extract(P, SE);
        ParamValues.insert(Values.begin(), Values.end());
        DEBUG({
          for (auto *Val : Values)
            printOperands(Val, os);
        });
      }

      for (auto *V : ParamValues)
        if (In.count(V))
          TrackedParams.insert(V);

      DEBUG({
        os << "\n---------------------------------------------------------";
        os << "\n Tracking:\n";
        for (Value *P : TrackedParams) {
          P->print((os << "\n").indent(2) << "TP: ");
        }
        os << "\n=========================================================";
        console->debug(os.str());
        os.flush();
      });

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
        ExtractedF->setLinkage(GlobalValue::LinkageTypes::WeakODRLinkage);
        ExtractedF->setName(F.getName() + "_" + fmt::format("{:d}", Cnt++) +
                            ".pjit.scop");
        ExtractedF->addFnAttr("polyjit-jit-candidate");

        Functions.insert(ExtractedF);
        Extracted++;
      }
    } else {
      NotEligible++;
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

static const std::set<std::string> Avoid{
    "BZ2_hbMakeCodeLengths", "BZ2_hbCreateDecodeTables",
};

bool ModuleExtractor::runOnFunction(Function &F) {
  RegionInfo &RI = getAnalysis<RegionInfoPass>().getRegionInfo();

  if (Avoid.count(F.getName()))
    return false;
  if (F.isDeclaration())
    return false;
  if (F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  JITScopDetection &SD = getAnalysis<JITScopDetection>();
  ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();

  ExtractedFunctions = extractCandidates(F, SD, SE, DT, RI);
  return (ExtractedFunctions.size() > 0);
}

void ModuleExtractor::print(raw_ostream &os, const Module *M) const {
  int i = 0;
  for (const Function *F : ExtractedFunctions) {
    os << fmt::format("{:d} {:s} ", i++, F->getName().str());
    F->print(os);
    os << "\n";
  }
}

void ModuleInstrumentation::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ModuleExtractor>();
  AU.addRequired<DominatorTreeWrapperPass>();
}

void ModuleInstrumentation::releaseMemory() { InstrumentedFunctions.clear(); }

void ModuleInstrumentation::print(raw_ostream &os, const Module *M) const {
  int i = 0;
  for (const Function *F : InstrumentedFunctions) {
    os << fmt::format("{:d} {:s} ", i++, F->getName().str());
    F->print(os);
    os << "\n";
  }
}

bool ModuleInstrumentation::runOnFunction(Function &F) {
  ModuleExtractor &ME = getAnalysis<ModuleExtractor>();
  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();

  if (F.isDeclaration())
    return false;
  if (F.hasFnAttribute("polyjit-jit-candidate"))
    return false;

  for (auto *F : ME) {
    if (F->isDeclaration())
      continue;
    console->info("Instrumenting: {:s}", F->getName().str());

    ValueToValueMapTy VMap;
    Module *M = F->getParent();
    StringRef ModuleName = F->getParent()->getModuleIdentifier();
    StringRef FromName = F->getName();
    UniqueModule PrototypeM = copyModule(*M);

    PrototypeM->setModuleIdentifier((ModuleName + "." + FromName).str() +
                                    ".prototype");
    Function *ProtoF = extractPrototypeM(VMap, *F, *PrototypeM);

    llvm::legacy::PassManager MPM;
    MPM.add(llvm::createStripSymbolsPass(true));
    MPM.run(*PrototypeM);

    bool BrokenDbg;
    if (verifyModule(*PrototypeM, &errs(), &BrokenDbg)) {
      // We failed verification, skip this region.
      PrototypeM->dump();
      errs() << "Prototype: " << PrototypeM->getModuleIdentifier()
             << " failed verification. Skipping.\n";
      continue;
    }

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
    InstCloner.setDominatorTree(&DT);

    Function *InstF = InstCloner.start(/* RemapCalls */ true);
    InstrumentedFunctions.insert(InstF);
    Instrumented++;
  }

  return true;
}

static RegisterPass<ModuleExtractor>
    X("polli-extract-scops", "PolyJIT - Move extracted SCoPs into new modules");
static RegisterPass<ModuleInstrumentation>
    Y("polli-instrument-scops", "PolyJIT - Instrument extracted SCoPs");
} // namespace polli
