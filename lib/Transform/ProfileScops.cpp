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
#include "spdlog/logger.h"
#include "spdlog/spdlog.h"

#include <algorithm>
#include <sstream>

using namespace llvm;
using namespace std;
using namespace polly;
using namespace spdlog;

#define DEBUG_TYPE "profileScopsDetection"

STATISTIC(InstrumentedScopsCounter, "Number of instrumented scops");
STATISTIC(NonInstrumentedScopsCounter, "Number of not instrumented scops");
STATISTIC(InstrumentedParentsCounter, "Number of instrumented parents");
STATISTIC(NonInstrumentedParentsCounter, "Number of not instrumented parents");

namespace polli {

  struct PProfID{
    PProfID(ConstantInt *globalID, int LocalID){
      this->globalID = globalID;
      this->LocalID = LocalID;
    }
    ConstantInt *globalID;
    int LocalID;
  };

  class ProfileScopDetection : public FunctionPass {
    private:
      static int LocalCounter;
      static bool calledSetup;
      static shared_ptr<logger> Log;

    public:
      static char ID;
      explicit ProfileScopDetection() : FunctionPass(ID) {}

    private:
      static size_t generateHash(Module*&, bool);
      static shared_ptr<logger> getLogger();
      static void insertSetupTracingFunction(Function*);
      static void insertEnterRegionFunction(Module*&, Instruction*, PProfID&);
      static void insertExitRegionFunction(Module*&, Instruction*, PProfID&);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, BasicBlock*, bool);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, SmallVector<BasicBlock*, 1>&, bool);
      static Instruction *getInsertPosition(BasicBlock*, bool);
      static PProfID generatePProfID(Module*&, bool);
      static bool instrumentSplitBlocks(
          SmallVector<BasicBlock*, 1>&, SmallVector<BasicBlock*, 1>&, bool);
      static bool instrumentRegion(const Region*, bool);

    public:
      void getAnalysisUsage(AnalysisUsage&) const override;
      bool doInitialization(Module&) override;
      bool runOnFunction(Function&) override;
      bool doFinalization(Module&) override;
  };

  char ProfileScopDetection::ID = 0;
  int ProfileScopDetection::LocalCounter = 0;
  bool ProfileScopDetection::calledSetup = false;
  shared_ptr<logger> ProfileScopDetection::Log = nullptr;

  void ProfileScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<ScopDetectionWrapperPass>();
  }

  size_t ProfileScopDetection::generateHash(Module *&M, bool isParent){
    LocalCounter++;
    hash<string> stringhashFn;
    string suffix = isParent ? "Parent" : "SCoP";
    string hashstring
      = M->getName().str() + "::" + suffix + to_string(LocalCounter);
    return stringhashFn(hashstring)/10000000000; //FIXME Avoid dividing hash
  }

  shared_ptr<logger> ProfileScopDetection::getLogger(){
    if(!Log){
      Log = basic_logger_mt("profileScopsLogger", "profileScops.log");
    }
    return Log;
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
      << InsertPosition->getFunction()->getName().data()
      << " " << pprofID.LocalID;
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

  PProfID ProfileScopDetection::generatePProfID(Module *&M, bool isParent){
    Type *int64Ty = Type::getInt64Ty(M->getContext());
    //FIXME According to docs ConstantInt::get(...) returns a ConstantInt,
    //but clang complains...
    return PProfID((ConstantInt*) ConstantInt::get(
          int64Ty, generateHash(M, isParent), false), LocalCounter);;
  }

  bool ProfileScopDetection::instrumentSplitBlocks(
      SmallVector<BasicBlock*, 1> &EntrySplits,
      SmallVector<BasicBlock*, 1> &ExitSplits,
      bool isParent){
    if(EntrySplits.empty() || ExitSplits.empty()){
      getLogger()->warn("WARNING: Trying to instrument splits either without "
        "entries or without exits.\n");
      return false;
    }

    Module *M = EntrySplits.front()->getModule();
    PProfID pprofID = generatePProfID(M, isParent);

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

  bool ProfileScopDetection::instrumentRegion(const Region *R, bool isParent){
    BasicBlock *EntryBB = R->getEntry();
    BasicBlock *ExitBB = R->getExit();
    SmallVector<BasicBlock*, 1> EntrySplits
      = splitPredecessors(R, EntryBB, true);
    SmallVector<BasicBlock*, 1> ExitSplits
      = splitPredecessors(R, ExitBB, false);

    return instrumentSplitBlocks(EntrySplits, ExitSplits, true);
  }

  bool ProfileScopDetection::doInitialization(Module &) {
    return false;
  }

  bool ProfileScopDetection::runOnFunction(Function &F) {
    bool anyInstrumented = false;
    const ScopDetectionWrapperPass &SDWP
      = getAnalysis<ScopDetectionWrapperPass>();
    const ScopDetection &SD = SDWP.getSD();

    Region *TopLevelRegion = SD.getRI()->getTopLevelRegion();

    for(const Region *R : SD){
      bool scopGotInstrumented = instrumentRegion(R, false);
      if(scopGotInstrumented){
        InstrumentedScopsCounter++;
        bool parentGotInstrumented = false;
        const Region *Parent = R->getParent();
        if(Parent){
          stringstream message;
          message << Parent->getNameStr() << " is invalid because of: ";
          if(Parent->isTopLevelRegion()){
            message << "Region is toplevel region.\n";
          } else {
            message << SD.regionIsInvalidBecause(Parent) << '\n';
            parentGotInstrumented = instrumentRegion(Parent, true);
          }
          getLogger()->info(message.str());
        } else {
          getLogger()->info("SCoP {} has no parent.\n", R->getNameStr());
        }

        if(parentGotInstrumented){
          InstrumentedParentsCounter++;
        } else {
          NonInstrumentedParentsCounter++;
          instrumentRegion(R, true);
        }
      } else {
        getLogger()
          ->error("SCoP {} could not be instrumented.\n", R->getNameStr());
        NonInstrumentedScopsCounter++;
      }
    }
    return anyInstrumented;
  }

  bool ProfileScopDetection::doFinalization(Module &M) {
    getLogger()
      ->info("Instrumented SCoPs: {:d}\n", InstrumentedScopsCounter);
    getLogger()
      ->info("Not instrumented SCoPs: {:d}\n", NonInstrumentedScopsCounter);
    getLogger()
      ->info("Instrumented Parents: {:d}\n", InstrumentedParentsCounter);
    getLogger()->info(
        "Not instrumented Parents: {:d}\n", NonInstrumentedParentsCounter);

    bool insertedSetupTracing = false;
    if(!calledSetup && InstrumentedScopsCounter > 0){
      Function *Main = M.getFunction("main");
      if(Main != nullptr){
        insertSetupTracingFunction(Main);
        insertedSetupTracing = true;
        calledSetup = true;
      }
    }

    return insertedSetupTracing;
  }

  static llvm::RegisterPass<ProfileScopDetection>
    X("polli-profile-scop-detection",
      "PolyJIT - Profile runtime performance of rejected SCoPs");

  Pass *createProfileScopsPass() {
    return new ProfileScopDetection();
  }
}
