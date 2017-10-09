#include "llvm/IR/BasicBlock.h"
#include "polli/Options.h"
#include "polli/RegisterCompilationPasses.h"
#include "polly/Canonicalization.h"
#include "polly/LinkAllPasses.h"
#include "polly/RegisterPasses.h"
#include "polly/ScopInfo.h"
#include "spdlog/logger.h"
#include "spdlog/spdlog.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Pass.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

#include <algorithm>
#include <functional>
#include <map>
#include <sstream>

using namespace llvm;
using namespace std;
using namespace polly;
using namespace spdlog;

#define DEBUG_TYPE "profileScopsDetection"

namespace polli {

  struct RegionID{
    RegionID(){}
    RegionID(const Region *region, size_t measurementID,
        SetVector<BasicBlock*> EntrySplits,
        SetVector<BasicBlock*> ExitSplits){
      this->region = region;
      this->measurementID = measurementID;
      this->EntrySplits = EntrySplits;
      this->ExitSplits = ExitSplits;
    }
    const Region *region;
    size_t measurementID;
    SetVector<BasicBlock*> EntrySplits;
    SetVector<BasicBlock*> ExitSplits;
  };

  using BBRegionMap = unordered_map<BasicBlock*, const Region*>;
  using RegionIDMap = unordered_map<const Region*, RegionID>;
  using IDToNameMapTy = unordered_map<size_t, string>;

  class ProfileScopDetection : public FunctionPass {
    private:
      static bool CalledSetup;
      bool instrumentParents;
      int InstrumentedScopsCounter = 0;
      int NonInstrumentedScopsCounter = 0;
      int InstrumentedParentsCounter = 0;
      int NonInstrumentedParentsCounter = 0;
      int ScopDetectionIterated = 0;

      IDToNameMapTy IDToName;
      LoopInfo *LI = nullptr;
      DominatorTree *DT = nullptr;
    public:
      static char ID;
      //NOTE: Default constructor required
      explicit ProfileScopDetection(bool instrumentParents = false)
        : FunctionPass(ID) {
        this->instrumentParents = instrumentParents;
        getLogger()->debug("instrumentParents: {}", instrumentParents);
      }

    private:
      static size_t generateMeasurementID(StringRef Name);
      static shared_ptr<logger> getLogger();
      static void insertSetupTracingFunction(Function*);
      static void insertExitRegionFunction(Module*&, Instruction*, size_t);
      SetVector<BasicBlock*> splitPredecessors(
          const Region*, BasicBlock*, bool);
      static Instruction *getInsertPosition(BasicBlock*, bool);
      void insertEnterRegionFunction(Module*&, Instruction*, size_t);
      bool instrumentSplitBlocks(RegionID, size_t);
      bool instrumentRegion(const Region*, int ScopNum);
      string getUniqueName(const Function &F, const Module &M,
                                int ScopNum);

    public:
      void getAnalysisUsage(AnalysisUsage&) const override;
      bool doInitialization(Module&) override;
      bool runOnFunction(Function&) override;
      bool doFinalization(Module&) override;
  };

  char ProfileScopDetection::ID = 0;
  bool ProfileScopDetection::CalledSetup = false;

  void ProfileScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<ScopDetectionWrapperPass>();
    AU.addRequiredTransitive<LoopInfoWrapperPass>();
    AU.addRequiredTransitive<DominatorTreeWrapperPass>();
  }

  size_t ProfileScopDetection::generateMeasurementID(StringRef Name) {
    hash<string> StrHasher;
    return StrHasher(Name.str());
  }

  shared_ptr<logger> ProfileScopDetection::getLogger(){
    static auto Log = basic_logger_st(DEBUG_TYPE, "profileScops.log", true);
    Log->set_level(level::debug); //TODO Think about how to call it only once.
    return Log;
  }

  void ProfileScopDetection::insertSetupTracingFunction(Function *Main){
    Module *M = Main->getParent();
    LLVMContext &Context = M->getContext();
    IRBuilder<> Builder(Context);
    Instruction *InsertInstruction
      = Main->getEntryBlock().getFirstNonPHIOrDbgOrLifetime();
    Builder.SetInsertPoint(InsertInstruction);

    Type *Voidty = Type::getVoidTy(Context);

    //void setup_tracing()
    FunctionType *FType = FunctionType::get(Voidty, false);
    Constant *F = M->getOrInsertFunction("setup_tracing", FType);
    Builder.CreateCall(F, {});
  }

  void ProfileScopDetection::insertEnterRegionFunction(Module *&M,
      Instruction *InsertPosition, size_t measurementID){
    getLogger()->debug("Insert Region Enter:: {:d}", measurementID);
    LLVMContext &Context = M->getContext();
    Type *Voidty = Type::getVoidTy(Context);
    Type *Int64Ty = Type::getInt64Ty(Context);
    Type *CharPtrTy = Type::getInt8PtrTy(Context);
    IRBuilder<> Builder(Context);
    Builder.SetInsertPoint(InsertPosition);

    //void enter_region(uint64_t, const char*)
    SmallVector<Value*, 2> Arguments;
    Arguments.push_back(ConstantInt::get(Int64Ty, measurementID, false));
    string Name = IDToName[measurementID];
    Arguments.push_back(Builder.CreateGlobalStringPtr(Name));
    FunctionType *FType
      = FunctionType::get(Voidty, {Int64Ty, CharPtrTy}, false);
    Constant *F = M->getOrInsertFunction("enter_region", FType);
    Builder.CreateCall(F, Arguments);
  }

  void ProfileScopDetection::insertExitRegionFunction(
      Module *&M, Instruction *InsertPosition, size_t measurementID){
    getLogger()->debug("Insert Region Exit:: {:d}", measurementID);
    LLVMContext &Context = M->getContext();
    Type *Voidty = Type::getVoidTy(Context);
    Type *Int64Ty = Type::getInt64Ty(Context);
    IRBuilder<> Builder(Context);
    Builder.SetInsertPoint(InsertPosition);

    //void exit_region(uint64_t)
    SmallVector<Value*, 1> Arguments;
    Arguments.push_back(ConstantInt::get(Int64Ty, measurementID, false));
    FunctionType *FType = FunctionType::get(Voidty, {Int64Ty}, false);
    Constant *F = M->getOrInsertFunction("exit_region", FType);
    Builder.CreateCall(F, Arguments);
  }

  SetVector<BasicBlock*> ProfileScopDetection::splitPredecessors(
      const Region *R, BasicBlock *BB, bool IsEntry){
    SetVector<BasicBlock*> SplitBlocks;
    assert(BB && "Trying to split a BB that is null.");

    SmallVector<BasicBlock *, 2> SplitPreds;
    for (BasicBlock *PredBB : predecessors(BB)) {
      if (IsEntry != R->contains(PredBB)) {
        SplitPreds.push_back(PredBB);
      }
    }
    BasicBlock *NewBB = SplitBlockPredecessors(
        BB, SplitPreds, ".profile.exit.split", DT, LI);

    SplitBlocks.insert(NewBB);

    return SplitBlocks;
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

  bool ProfileScopDetection::instrumentSplitBlocks(
      RegionID regionID, size_t measurementID){
    Module *M = regionID.EntrySplits.front()->getModule();

    for(BasicBlock *BB : regionID.EntrySplits){
      Instruction *InsertPosition = getInsertPosition(BB, true);
      insertEnterRegionFunction(
          M, InsertPosition, regionID.measurementID);
    }

    for(BasicBlock *BB : regionID.ExitSplits){
      Instruction *InsertPosition = getInsertPosition(BB, false);
      insertExitRegionFunction(M, InsertPosition, regionID.measurementID);
    }

    //Check whether both loops iterated at least once
    return !(regionID.EntrySplits.empty() || regionID.ExitSplits.empty());
  }

  string ProfileScopDetection::getUniqueName(const Function &F,
                                                  const Module &M,
                                                  int ScopNum) {
    string Name = fmt::format("{:s}::{:s}::{:d}::{:s}", M.getName().str(),
                                   F.getName().str(), ScopNum,
                                   (instrumentParents ? "Parent" : "SCoP"));
    return Name;
  }

  bool ProfileScopDetection::instrumentRegion(const Region *R, int ScopNum){
    getLogger()->debug(
        "Instrumenting (Parent: {}) {}", instrumentParents, R->getNameStr());
    BasicBlock *EntryBB = R->getEntry();
    const Function &F = *EntryBB->getParent();

    string UniqueName = getUniqueName(F, *F.getParent(), ScopNum);
    size_t MeasurementId = generateMeasurementID(UniqueName);
    SetVector<BasicBlock*> EntrySplits = splitPredecessors(R, EntryBB, true);

    BasicBlock *ExitBB = R->getExit();
    SetVector<BasicBlock*> ExitSplits = splitPredecessors(R, ExitBB, false);

    IDToName[MeasurementId] = UniqueName;

    RegionID RegionId = RegionID(R, MeasurementId, EntrySplits, ExitSplits);
    return instrumentSplitBlocks(RegionId, MeasurementId);
  }

  bool ProfileScopDetection::doInitialization(Module &) {
    return false;
  }

  bool ProfileScopDetection::runOnFunction(Function &F) {
    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    int ScopNum = 0;

    bool AnyInstrumented = false;
    const ScopDetectionWrapperPass &SDWP
      = getAnalysis<ScopDetectionWrapperPass>();
    const ScopDetection &SD = SDWP.getSD();

    for(const Region *R : SD){
      ScopDetectionIterated++;
      if(instrumentParents){
        bool ParentGotInstrumented = false;
        const Region *Parent = R->getParent();
        if(Parent){
          stringstream Message;
          Message << Parent->getNameStr() << " is invalid because of: ";
          if(Parent->isTopLevelRegion()){
            Message << "Region is toplevel region.";
          } else {
            string InvalidReason = SD.regionIsInvalidBecause(Parent);
            if(InvalidReason.empty()){
              Message << "Polly returned no reason";
            } else {
              Message << InvalidReason;
            }
            ParentGotInstrumented = instrumentRegion(Parent, ScopNum);
          }
          getLogger()->info(Message.str());
        } else {
          getLogger()->warn("SCoP {} has no parent.", R->getNameStr());
        }

        if(ParentGotInstrumented){
          AnyInstrumented = true;
          InstrumentedParentsCounter++;
        } else {
          NonInstrumentedParentsCounter++;
        }
      } else {
        if(instrumentRegion(R, ScopNum)){
          AnyInstrumented = true;
          InstrumentedScopsCounter++;
        } else {
          getLogger()
            ->error("SCoP {} could not be instrumented.", R->getNameStr());
          NonInstrumentedScopsCounter++;
        }
      }

      ScopNum++;
    }

    string ModStr;
    raw_string_ostream Os(ModStr);
    AnalysisManager<Module> AM;
    ModulePassManager PM;
    PrintModulePass PrintModuleP(Os);

    PM.addPass(PrintModuleP);
    PM.run(*F.getParent(), AM);
    Os.flush();
    error_code Ec;
    tool_output_file Outf(
        fmt::format("{:s}-profile-scops-after.ll", F.getName().str()), Ec,
        sys::fs::OpenFlags::F_RW);
    Outf.os() << ModStr;
    Outf.keep();

    return AnyInstrumented;
  }

  bool ProfileScopDetection::doFinalization(Module &M) {
    getLogger()
      ->info("Instrumented SCoPs: {:d}", InstrumentedScopsCounter);
    getLogger()
      ->info("Not instrumented SCoPs: {:d}", NonInstrumentedScopsCounter);
    getLogger()
      ->info("Instrumented parents: {:d}", InstrumentedParentsCounter);
    getLogger()->info(
        "Not instrumented parents: {:d}", NonInstrumentedParentsCounter);
    getLogger()->debug(
        "ScopDetection iterated {:d} times", ScopDetectionIterated);

    bool InsertedSetupTracing = false;
    if(!CalledSetup && InstrumentedScopsCounter > 0){
      Function *Main = M.getFunction("main");
      if(Main){
        insertSetupTracingFunction(Main);
        InsertedSetupTracing = true;
        CalledSetup = true;
      }
    }

    return InsertedSetupTracing;
  }

  static RegisterPass<ProfileScopDetection>
    X("polli-profile-scop-detection",
        "PolyJIT - Profile runtime performance of rejected SCoPs");

  Pass *createProfileScopsPass(bool instrumentParents) {
    return new ProfileScopDetection(instrumentParents);
  }
} // namespace polli
