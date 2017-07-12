#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "polli/Options.h"
#include "polli/RegisterCompilationPasses.h"
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"
#include "polly/ScopInfo.h"

#include <algorithm>
#include <sstream>

using namespace llvm;
using namespace std;
using namespace polly;
using namespace polli;

namespace {

  struct PProfID{
    PProfID(ConstantInt *globalID, size_t MID){
      this->globalID = globalID;
      this->MID = MID;
    }
    ConstantInt *globalID;
    size_t MID;
  };

  class ProfileScopDetection : public FunctionPass {
    private:
      static int LoopID;
      static int instrumentedCounter;
      static int nonInstrumentedCounter;
      static bool calledSetup;
      size_t hashvalue;

    public:
      static char ID;
      explicit ProfileScopDetection() : FunctionPass(ID) {}

    private:
      static size_t generateHash(Module*&);
      static void insertSetupTracingFunction(Function*);
      static void insertEnterRegionFunction(Module*&, Instruction*, PProfID&);
      static void insertExitRegionFunction(Module*&, Instruction*, PProfID&);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, BasicBlock*, bool);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, SmallVector<BasicBlock*, 1>&, bool);
      static Instruction *getInsertPosition(BasicBlock*, bool);
      static PProfID generatePProfID(Module*&);
      static bool instrumentSplitBlocks(
          SmallVector<BasicBlock*, 1>&, SmallVector<BasicBlock*, 1>&);

    public:
      void getAnalysisUsage(AnalysisUsage&) const override;
      bool doInitialization(Module&) override;
      bool runOnFunction(Function&) override;
      bool doFinalization(Module&) override;
  };

  char ProfileScopDetection::ID = 0;
  int ProfileScopDetection::LoopID = 0;
  int ProfileScopDetection::instrumentedCounter = 0;
  int ProfileScopDetection::nonInstrumentedCounter = 0;
  bool ProfileScopDetection::calledSetup = false;

  void ProfileScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<ScopDetectionWrapperPass>();
  }

  size_t ProfileScopDetection::generateHash(Module *&M){
    LoopID++;
    hash<string> stringhashFn;
    string hashstring = M->getName().str() + "::SCoP" + to_string(LoopID);
    return stringhashFn(hashstring)/10000000000; //FIXME Avoid dividing hash
  }

  void ProfileScopDetection::insertSetupTracingFunction(Function *Main){
    Module *M = Main->getParent();
    LLVMContext &context = M->getContext();
    IRBuilder<> builder(context);
    Instruction *insertInstruction
      = Main->getEntryBlock().getFirstNonPHIOrDbgOrLifetime();
    builder.SetInsertPoint(insertInstruction);

    Type *voidty = Type::getVoidTy(context);

    //void setup_tracing()
    FunctionType *FType = FunctionType::get(voidty, false);
    Constant *F = M->getOrInsertFunction("setup_tracing", FType);
    builder.CreateCall(F, {});
  }

  void ProfileScopDetection::insertEnterRegionFunction(
      Module *&M, Instruction *InsertPosition, PProfID &pprofID){
    LLVMContext &context = M->getContext();
    Type *voidty = Type::getVoidTy(context);
    Type *int64Ty = Type::getInt64Ty(context);
    Type *charPtrTy = Type::getInt8PtrTy(context);
    IRBuilder<> builder(context);
    builder.SetInsertPoint(InsertPosition);

    //void enter_region(uint64_t, const char*)
    SmallVector<Value*, 2> arguments;
    arguments.push_back(pprofID.globalID);
    ostringstream name;
    name << M->getName().data() << "::"
      << InsertPosition->getFunction()->getName().data() << " " << pprofID.MID;
    //errs() << name.str() << '\n';
    arguments.push_back(builder.CreateGlobalStringPtr(name.str()));
    FunctionType *FType
      = FunctionType::get(voidty, {int64Ty, charPtrTy}, false);
    Constant *F = M->getOrInsertFunction("enter_region", FType);
    builder.CreateCall(F, arguments);
  }

  void ProfileScopDetection::insertExitRegionFunction(
      Module *&M, Instruction *InsertPosition, PProfID &pprofID){
    LLVMContext &context = M->getContext();
    Type *voidty = Type::getVoidTy(context);
    Type *int64Ty = Type::getInt64Ty(context);
    IRBuilder<> builder(context);
    builder.SetInsertPoint(InsertPosition);

    //void exit_region(uint64_t)
    SmallVector<Value*, 1> arguments;
    arguments.push_back(pprofID.globalID);
    FunctionType *FType = FunctionType::get(voidty, {int64Ty}, false);
    Constant *F = M->getOrInsertFunction("exit_region", FType);
    builder.CreateCall(F, arguments);
  }

  SmallVector<BasicBlock*, 1> ProfileScopDetection::splitPredecessors(
      const Region *R, BasicBlock *BB, bool IsEntry){
    SmallVector<BasicBlock*, 1> splitBlocks;
    if(BB){
      //TODO May insert warning for nullptr
      //TODO Why is there a comma instead of using it directly in condition?
      for(pred_iterator it = pred_begin(BB), end = pred_end(BB); it != end; it++){
        BasicBlock *predecessor = *it;
        if(IsEntry != R->contains(predecessor)){
          BasicBlock *splitBlock = SplitEdge(predecessor, BB);
          if(splitBlock != nullptr){
            splitBlocks.push_back(splitBlock);
          }
        }
      }
    }
    return splitBlocks;
  }

  SmallVector<BasicBlock*, 1> ProfileScopDetection::splitPredecessors(
      const Region *R, SmallVector<BasicBlock*, 1> &BBs, bool IsEntry){
    SmallVector<BasicBlock*, 1> Splits;
    for(BasicBlock *BB : BBs){
      SmallVector<BasicBlock*, 1> newSplits
        = splitPredecessors(R, BB, IsEntry);
      Splits.insert(Splits.end(), newSplits.begin(), newSplits.end());
    }
    return Splits;
  }

  Instruction *ProfileScopDetection::getInsertPosition(
      BasicBlock *BB, bool IsEntry){
    BasicBlock::iterator InsertPosition
      = BB->getFirstNonPHIOrDbgOrLifetime()->getIterator();
    if(BB->isLandingPad()){
      InsertPosition++;
    }
    while(isa<AllocaInst>(InsertPosition)){
      InsertPosition++;
    }
    if(IsEntry){
      //To be sure that the enter call is past a previous exit call.
      while(isa<CallInst>(InsertPosition)){
        InsertPosition++;
      }
    }
    return &*InsertPosition;
  }

  PProfID ProfileScopDetection::generatePProfID(Module *&M){
    Type *int64Ty = Type::getInt64Ty(M->getContext());
    //FIXME According to docs ConstantInt::get(...) returns a ConstantInt,
    //but clang complains...
    return PProfID((ConstantInt*) ConstantInt::get(
          int64Ty, generateHash(M), false), LoopID);;
  }

  bool ProfileScopDetection::instrumentSplitBlocks(
      SmallVector<BasicBlock*, 1> &EntrySplits,
      SmallVector<BasicBlock*, 1> &ExitSplits){
    if(EntrySplits.empty() || ExitSplits.empty()){
      errs() << "WARNING: Trying to instrument splits either without entries"
        << " or without exits.\n";
      return false;
    }

    Module *M = EntrySplits.front()->getModule();
    PProfID pprofID = generatePProfID(M);

    for(BasicBlock *BB : EntrySplits){
      Instruction *InsertPosition = getInsertPosition(BB, true);
      insertEnterRegionFunction(M, InsertPosition, pprofID);
    }

    for(BasicBlock *BB : ExitSplits){
      Instruction *InsertPosition = getInsertPosition(BB, false);
      insertExitRegionFunction(M, InsertPosition, pprofID);
    }

    return true;
  }

  bool ProfileScopDetection::doInitialization(Module &) {
    return false;
  }

  bool ProfileScopDetection::runOnFunction(Function &F) {
    bool gotAnyInstrumented = false;
    const ScopDetectionWrapperPass &SDWP
      = getAnalysis<ScopDetectionWrapperPass>();
    const ScopDetection &SD = SDWP.getSD();

    for(const Region *R : SD){
      bool gotInstrumented = false;
      if(const Region *Parent = R->getParent()){
          errs() << *Parent << " is invalid because of: ";
        if(Parent->isTopLevelRegion()){
            errs() << "Region is toplevel region.\n";
        } else {
            errs() << SD.regionIsInvalidBecause(Parent) << '\n';

          BasicBlock *EntryBB = Parent->getEntry();
          BasicBlock *ExitBB = Parent->getExit();

          //errs() << "EntryBB: " << EntryBB << '\n';
          SmallVector<BasicBlock*, 1> EntrySplits
            = splitPredecessors(Parent, EntryBB, true);
          //errs() << "EntrySplits.empty(): " << EntrySplits.empty() << '\n';

          //errs() << "ExitBB: " << ExitBB << '\n';
          SmallVector<BasicBlock*, 1> ExitSplits
            = splitPredecessors(Parent, ExitBB, false);
          //errs() << "ExitSplits.empty(): " << ExitSplits.empty() << '\n';

          gotInstrumented = instrumentSplitBlocks(EntrySplits, ExitSplits);
        }
      } else {
        errs() << "SCoP " << *R << " has no parent.\n";
      }

      if(gotInstrumented){
        gotAnyInstrumented = true;
        instrumentedCounter++;
      } else {
        nonInstrumentedCounter++;
      }
    }
    return gotAnyInstrumented;
  }

  bool ProfileScopDetection::doFinalization(Module &M) {
    errs() << "Instrumented SCoPs: " << instrumentedCounter << '\n';
    errs() << "Not instrumented SCoPs: " << nonInstrumentedCounter << '\n';

    bool insertedSetupTracing = false;
    if(!calledSetup && instrumentedCounter > 0){
      Function *Main = M.getFunction("main");
      if(Main != nullptr){
        insertSetupTracingFunction(Main);
        insertedSetupTracing = true;
        calledSetup = true;
      }
    }

    return insertedSetupTracing;
  }
}

//Register for opt
//static RegisterPass<ProfileScopDetection> ProfileScopDetectionRegister("profileScopDetection", "profile using ScopDetection");

//Register for clang
static void registerProfileScopDetection(
    const PassManagerBuilder &, legacy::PassManagerBase &PM){
  if(opt::compiletime::ProfileScops){
    registerCanonicalicationPasses(PM);
    PM.add(createScopDetectionWrapperPassPass());
    PM.add(new ProfileScopDetection());
  }
}

static RegisterStandardPasses registeredProfileScopDetectionPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerProfileScopDetection);

//Register for clang opt
static cl::opt<bool, true> ProfileScopDetectionEnabled(
    "profileScopDetection", cl::desc("profile using ScopDetection"),
    cl::ZeroOrMore, cl::location(opt::compiletime::Enabled),
    cl::init(false), cl::cat(PolliCategory));
