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
        public:
            static char ID;
            explicit ProfileScopDetection() : FunctionPass(ID) {}

        private:
            static int LoopID;
            static int instrumentedCounter;
            static int nonInstrumentedCounter;
            static bool calledSetup;
            static list<string> instrumentedToplevelRegions;
            size_t hashvalue;

        private:
            static size_t generateHash(Module*&);
            static void insertSetupTracingFunction(Function*);
            static void insertEnterRegionFunction(Module*&, Instruction*, PProfID&);
            static void insertExitRegionFunction(Module*&, Instruction*, PProfID&);
            static SmallVector<BasicBlock*, 1> splitPredecessors(const Region*, BasicBlock*, bool);
            static SmallVector<BasicBlock*, 1> splitPredecessors(const Region*, SmallVector<BasicBlock*, 1>&, bool );
            static void instrumentSplitBlocks(pair<SmallVector<BasicBlock*, 1>, SmallVector<BasicBlock*, 1>>&);

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
    list<string> ProfileScopDetection::instrumentedToplevelRegions = list<string>();

    void ProfileScopDetection::getAnalysisUsage(AnalysisUsage &usage) const {
        usage.setPreservesAll();
        usage.addRequired<ScopDetectionWrapperPass>();
    }

    size_t ProfileScopDetection::generateHash(Module *&M){
        LoopID++;
        hash<string> stringhashFn;
        string hashstring = M->getName().str() + "::Loop" + to_string(LoopID);
        return stringhashFn(hashstring)/10000000000; //FIXME Avoid dividing hash
    }

    void ProfileScopDetection::insertSetupTracingFunction(Function *Main){
        Module *M = Main->getParent();
        LLVMContext &context = M->getContext();
        IRBuilder<> builder(context);
        Instruction *insertInstruction = Main->getEntryBlock().getFirstNonPHIOrDbgOrLifetime();
        builder.SetInsertPoint(insertInstruction);

        Type *voidty = Type::getVoidTy(context);

        //void setup_tracing()
        FunctionType *FType = FunctionType::get(voidty, false);
        Constant *F = M->getOrInsertFunction("setup_tracing", FType);
        builder.CreateCall(F, {});
    }

    void ProfileScopDetection::insertEnterRegionFunction(Module *&M, Instruction *insertPosition, PProfID &pprofID){
        LLVMContext &context = M->getContext();
        Type *voidty = Type::getVoidTy(context);
        Type *int64Ty = Type::getInt64Ty(context);
        Type *charPtrTy = Type::getInt8PtrTy(context);
        IRBuilder<> builder(context);
        builder.SetInsertPoint(insertPosition);

        //void enter_R(uint64_t, const char*)
        SmallVector<Value*, 2> arguments;
        arguments.push_back(pprofID.globalID);
        ostringstream name;
        name << M->getName().data() << "::" << insertPosition->getFunction()->getName().data() << " "
            << pprofID.MID;
        errs() << name.str() << '\n';
        arguments.push_back(builder.CreateGlobalStringPtr(name.str()));
        FunctionType *FType = FunctionType::get(voidty, {int64Ty, charPtrTy}, false);
        Constant *F = M->getOrInsertFunction("enter_R", FType);
        builder.CreateCall(F, arguments);
    }

    void ProfileScopDetection::insertExitRegionFunction(Module *&M, Instruction *insertPosition, PProfID &pprofID){
        LLVMContext &context = M->getContext();
        Type *voidty = Type::getVoidTy(context);
        Type *int64Ty = Type::getInt64Ty(context);
        IRBuilder<> builder(context);
        builder.SetInsertPoint(insertPosition);

        //void exit_R(uint64_t)
        SmallVector<Value*, 1> arguments;
        arguments.push_back(pprofID.globalID);
        FunctionType *FType = FunctionType::get(voidty, {int64Ty}, false);
        Constant *F = M->getOrInsertFunction("exit_R", FType);
        builder.CreateCall(F, arguments);
    }

    SmallVector<BasicBlock*, 1> ProfileScopDetection::splitPredecessors(const Region *R, BasicBlock *block, bool isEntry){
        SmallVector<BasicBlock*, 1> splitBlocks;
        //TODO Why is there a comma instead of using it directly in condition?
        for(pred_iterator it = pred_begin(block), end = pred_end(block); it != end; it++){
            BasicBlock *predecessor = *it;
            if(isEntry != R->contains(predecessor)){
                BasicBlock *splitBlock = SplitEdge(predecessor, block);
                if(splitBlock != nullptr){
                    splitBlocks.push_back(splitBlock);
                }
            }
        }
        return splitBlocks;
    }

    SmallVector<BasicBlock*, 1> ProfileScopDetection::splitPredecessors(const Region *R, SmallVector<BasicBlock*, 1> &blocks,
            bool isEntry){
        SmallVector<BasicBlock*, 1> Splits;
        for(BasicBlock *block : blocks){
            SmallVector<BasicBlock*, 1> newSplits = splitPredecessors(R, block, isEntry);
            Splits.insert(Splits.end(), newSplits.begin(), newSplits.end());
        }
        return Splits;
    }

    void ProfileScopDetection::instrumentSplitBlocks(pair<SmallVector<BasicBlock*, 1>, SmallVector<BasicBlock*, 1>> &Splits){
        Module *M = Splits.first.front()->getModule();
        Type *int64Ty = Type::getInt64Ty(M->getContext());
        //FIXME According to docs ConstantInt::get(...) returns a ConstantInt, but clang complains...
        PProfID pprofID((ConstantInt*) ConstantInt::get(int64Ty, generateHash(M), false), LoopID);;

        for(BasicBlock *BB : Splits.first){
            BasicBlock::iterator insertPosition = BB->getFirstNonPHIOrDbgOrLifetime()->getIterator();
            if(BB->isLandingPad()){
                insertPosition++;
            }
            while(isa<AllocaInst>(insertPosition)){
                insertPosition++;
            }
            //To be sure that the enter call is past a previous exit call.
            while(isa<CallInst>(insertPosition)){
                insertPosition++;
            }
            insertEnterRegionFunction(M, &*insertPosition, pprofID);
        }

        for(BasicBlock *BB : Splits.second){
            BasicBlock::iterator insertPosition = BB->getFirstNonPHIOrDbgOrLifetime()->getIterator();
            if(BB->isLandingPad()){
                insertPosition++;
            }
            while(isa<AllocaInst>(insertPosition)){
                insertPosition++;
            }
            insertExitRegionFunction(M, &*insertPosition, pprofID);
        }
    }

    bool ProfileScopDetection::doInitialization(Module &) {
        return false;
    }

    bool ProfileScopDetection::runOnFunction(Function &F) {
        bool gotInstrumented = false;
        const ScopDetectionWrapperPass &SDWP = getAnalysis<ScopDetectionWrapperPass>();
        SDWP.print(errs(), F.getParent());
        const ScopDetection &SD = SDWP.getSD();

        for(const Region *R : SD){
            errs() << "Region: " << R->getNameStr() << '\n';
            if(const Region *Parent = R->getParent()){
                instrumentedCounter++;
                errs() << SD.regionIsInvalidBecause(Parent) << '\n';

                BasicBlock *EntryBB = Parent->getEntry();
                SmallVector<BasicBlock*, 1> ExitBBs;
                ExitBBs.push_back(Parent->getExit());
                pair<SmallVector<BasicBlock*, 1>, SmallVector<BasicBlock*, 1>> Splits;
                Splits.first = splitPredecessors(Parent, EntryBB, true);
                Splits.second = splitPredecessors(Parent, ExitBBs, false);
                instrumentSplitBlocks(Splits);
                gotInstrumented = true;
            } else {
                nonInstrumentedCounter++;
            }
        }
        return gotInstrumented;
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
static void registerProfileScopDetection(const PassManagerBuilder &, legacy::PassManagerBase &PM){
    if(opt::Enabled){
        registerCanonicalicationPasses(PM);
        PM.add(createScopDetectionWrapperPassPass());
        PM.add(new ProfileScopDetection());
    }
}

static RegisterStandardPasses registeredProfileScopDetectionPass(PassManagerBuilder::EP_EarlyAsPossible, registerProfileScopDetection);

//Register for clang opt
static cl::opt<bool, true> ProfileScopDetectionEnabled("profileScopDetection", cl::desc("profile using ScopDetection"),
        cl::ZeroOrMore, cl::location(opt::Enabled), cl::init(false), cl::cat(PolliCategory));
