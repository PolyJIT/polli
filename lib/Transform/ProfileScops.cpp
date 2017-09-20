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
        SmallVector<BasicBlock*, 1> EntrySplits,
        SmallVector<BasicBlock*, 1> ExitSplits){
      this->region = region;
      this->measurementID = measurementID;
      this->EntrySplits = EntrySplits;
      this->ExitSplits = ExitSplits;
    }
    const Region *region;
    size_t measurementID;
    SmallVector<BasicBlock*, 1> EntrySplits;
    SmallVector<BasicBlock*, 1> ExitSplits;
  };

  typedef map<BasicBlock*, const Region*> BBRegionMap;
  typedef map<const Region*, RegionID> RegionIDMap;

  class ProfileScopDetection : public FunctionPass {
    private:
      static bool calledSetup;
      static shared_ptr<logger> Log;
      static BBRegionMap entryExitToRegionMap;
      static RegionIDMap regionToIDMap;
      bool instrumentParents;
      int InstrumentedScopsCounter = 0;
      int NonInstrumentedScopsCounter = 0;
      int InstrumentedParentsCounter = 0;
      int NonInstrumentedParentsCounter = 0;

    public:
      static char ID;
      //NOTE: Default constructor required
      explicit ProfileScopDetection(bool instrumentParents = false)
        : FunctionPass(ID) {
        this->instrumentParents = instrumentParents;
        getLogger()->debug("instrumentParents: {}", instrumentParents);
      }

    private:
      static size_t generateMeasurementID();
      static shared_ptr<logger> getLogger();
      static void insertSetupTracingFunction(Function*);
      static void insertExitRegionFunction(Module*&, Instruction*, size_t);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, BasicBlock*, bool);
      static SmallVector<BasicBlock*, 1> splitPredecessors(
          const Region*, SmallVector<BasicBlock*, 1>&, bool);
      static Instruction *getInsertPosition(BasicBlock*, bool);
      void insertEnterRegionFunction(Module*&, Instruction*, size_t);
      bool instrumentSplitBlocks(RegionID, size_t);
      bool instrumentRegion(const Region*);

    public:
      void getAnalysisUsage(AnalysisUsage&) const override;
      bool doInitialization(Module&) override;
      bool runOnFunction(Function&) override;
      bool doFinalization(Module&) override;
  };

  char ProfileScopDetection::ID = 0;
  bool ProfileScopDetection::calledSetup = false;
  shared_ptr<logger> ProfileScopDetection::Log = nullptr;
  BBRegionMap ProfileScopDetection::entryExitToRegionMap = {};
  RegionIDMap ProfileScopDetection::regionToIDMap = {};

  void ProfileScopDetection::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<ScopDetectionWrapperPass>();
  }

  size_t ProfileScopDetection::generateMeasurementID(){
    size_t newID;
    bool newIDAlreadyExists;
    do {
      newID = rand() % 1000000000;
      newIDAlreadyExists = false;
      for(RegionIDMap::iterator it = regionToIDMap.begin();
          it != regionToIDMap.end() && !newIDAlreadyExists; it++){
        /*NOTE: = may be sufficient (instead of |=) because of the additional
         * condition.
         */
        newIDAlreadyExists |= it->second.measurementID == newID;
      }
    } while(newIDAlreadyExists);

    return newID;
  }

  shared_ptr<logger> ProfileScopDetection::getLogger(){
    if(!Log){
      Log = basic_logger_mt("profileScopsLogger", "profileScops.log");
      Log->set_level(level::debug);
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

  void ProfileScopDetection::insertEnterRegionFunction(Module *&M,
      Instruction *InsertPosition, size_t measurementID){
    LLVMContext &context = M->getContext();
    Type *voidty = Type::getVoidTy(context);
    Type *int64Ty = Type::getInt64Ty(context);
    Type *charPtrTy = Type::getInt8PtrTy(context);
    IRBuilder<> builder(context);
    builder.SetInsertPoint(InsertPosition);

    //void enter_region(uint64_t, const char*)
    SmallVector<Value*, 2> arguments;
    arguments.push_back(ConstantInt::get(int64Ty, measurementID, false));
    ostringstream name;
    name << M->getName().data() << "::"
      << InsertPosition->getFunction()->getName().data()
      << "::" << (instrumentParents ? "Parent" : "SCoP");
    arguments.push_back(builder.CreateGlobalStringPtr(name.str()));
    FunctionType *FType
      = FunctionType::get(voidty, {int64Ty, charPtrTy}, false);
    Constant *F = M->getOrInsertFunction("enter_region", FType);
    builder.CreateCall(F, arguments);
  }

  void ProfileScopDetection::insertExitRegionFunction(
      Module *&M, Instruction *InsertPosition, size_t measurementID){
    LLVMContext &context = M->getContext();
    Type *voidty = Type::getVoidTy(context);
    Type *int64Ty = Type::getInt64Ty(context);
    IRBuilder<> builder(context);
    builder.SetInsertPoint(InsertPosition);

    //void exit_region(uint64_t)
    SmallVector<Value*, 1> arguments;
    arguments.push_back(ConstantInt::get(int64Ty, measurementID, false));
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
      for(pred_iterator it = pred_begin(BB), end = pred_end(BB);
          it != end; it++){
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

  bool ProfileScopDetection::instrumentSplitBlocks(
      RegionID regionID, size_t measurementID){
    bool isInstrumentable = true;
    if(regionID.EntrySplits.empty()){
      getLogger()->critical("Trying to instrument splits without entries");
      isInstrumentable = false;
    }
    if(regionID.ExitSplits.empty()){
      getLogger()->critical("Trying to instrument splits without exits");
      isInstrumentable = false;
    }

    if(isInstrumentable){
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
    }

    return isInstrumentable;
  }

  bool ProfileScopDetection::instrumentRegion(const Region *R){
    getLogger()->debug(
        "Instrumenting (Parent: {}) {}", instrumentParents, R->getNameStr());
    bool instrumentable = true;

    BasicBlock *EntryBB = R->getEntry();
    SmallVector<BasicBlock*, 1> EntrySplits
      = splitPredecessors(R, EntryBB, true);
    if(EntrySplits.empty()){
      //Retrieve entry splits of previously instrumented region
      if(entryExitToRegionMap.count(EntryBB)){
        EntrySplits = regionToIDMap.at(entryExitToRegionMap.at(EntryBB))
          .EntrySplits;
      } else {
        getLogger()->warn("Has no entry splits and there are no entry "
            "splits found for its EntryBB: {}", R->getNameStr());
        instrumentable = false;
      }
    } else {
      entryExitToRegionMap[EntryBB] = R;
    }

    BasicBlock *ExitBB = R->getExit();
    SmallVector<BasicBlock*, 1> ExitSplits
      = splitPredecessors(R, ExitBB, false);
    if(EntrySplits.empty()){
      //Retrieve exit splits of previously instrumented region
      if(entryExitToRegionMap.count(EntryBB)){
        ExitSplits = regionToIDMap.at(entryExitToRegionMap.at(ExitBB))
          .ExitSplits;
      } else {
        getLogger()->warn("Has no exit splits and there are no exit "
            "splits found for its ExitBB: {}", R->getNameStr());
        instrumentable = false;
      }
    } else {
      entryExitToRegionMap[ExitBB] = R;
    }

    if(instrumentable){
      size_t measurementID = generateMeasurementID();
      RegionID regionID = RegionID(R, measurementID, EntrySplits, ExitSplits);
      regionToIDMap[R] = regionID;
      return instrumentSplitBlocks(regionID, measurementID);
    } else {
      return false;
    }
  }

  bool ProfileScopDetection::doInitialization(Module &) {
    return false;
  }

  bool ProfileScopDetection::runOnFunction(Function &F) {
    bool anyInstrumented = false;
    const ScopDetectionWrapperPass &SDWP
      = getAnalysis<ScopDetectionWrapperPass>();
    const ScopDetection &SD = SDWP.getSD();

    for(const Region *R : SD){

      if(instrumentParents){
        bool parentGotInstrumented = false;
        const Region *Parent = R->getParent();
        if(Parent){
          stringstream message;
          message << Parent->getNameStr() << " is invalid because of: ";
          if(Parent->isTopLevelRegion()){
            message << "Region is toplevel region.";
          } else {
            message << SD.regionIsInvalidBecause(Parent);
            parentGotInstrumented = instrumentRegion(Parent);
          }
          getLogger()->info(message.str());
        } else {
          getLogger()->warn("SCoP {} has no parent.", R->getNameStr());
        }

        if(parentGotInstrumented){
          anyInstrumented = true;
          InstrumentedParentsCounter++;
        } else {
          NonInstrumentedParentsCounter++;
        }
      } else {
        if(instrumentRegion(R)){
          anyInstrumented = true;
          InstrumentedScopsCounter++;
        } else {
          getLogger()
            ->error("SCoP {} could not be instrumented.", R->getNameStr());
          NonInstrumentedScopsCounter++;
        }
      }
    }
    return anyInstrumented;
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

  Pass *createProfileScopsPass(bool instrumentParents) {
    return new ProfileScopDetection(instrumentParents);
  }
}
