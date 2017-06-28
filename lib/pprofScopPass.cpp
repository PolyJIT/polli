#include <algorithm>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/Pass.h>
#include <llvm/Transforms/IPO/PassManagerBuilder.h>
#include <llvm/Transforms/Utils/BasicBlockUtils.h>
#include <polli/RegisterCompilationPasses.h>
#include <polly/Canonicalization.h>
#include <polly/RegisterPasses.h>
#include <polly/ScopInfo.h>
#include <sstream>

using namespace llvm;
using namespace std;
using namespace polly;

namespace {

    struct PProfID{
        PProfID(ConstantInt *globalID, size_t moduleID){
            this->globalID = globalID;
            this->moduleID = moduleID;
        }
        ConstantInt *globalID;
        size_t moduleID;
    };

    class PprofScop : public FunctionPass {
        public:
            static char ID;
            explicit PprofScop() : FunctionPass(ID) {}

        private:
            static int loopID;
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
            static SmallVector<BasicBlock*, 0> splitPredecessors(const Region*, BasicBlock*, bool);
            static SmallVector<BasicBlock*, 0> splitPredecessors(const Region*, SmallVector<BasicBlock*, 0>&, bool );
            static void instrumentSplitBlocks(pair<SmallVector<BasicBlock*, 0>, SmallVector<BasicBlock*, 0>>&);

        public:
            void getAnalysisUsage(AnalysisUsage&) const override;
            bool doInitialization(Module&) override;
            bool runOnFunction(Function&) override;
            bool doFinalization(Module&) override;
    };

    char PprofScop::ID = 0;
    int PprofScop::loopID = 0;
    int PprofScop::instrumentedCounter = 0;
    int PprofScop::nonInstrumentedCounter = 0;
    bool PprofScop::calledSetup = false;
    list<string> PprofScop::instrumentedToplevelRegions = list<string>();

    void PprofScop::getAnalysisUsage(AnalysisUsage &usage) const {
        usage.setPreservesAll();
        usage.addRequiredTransitive<ScopDetection>();
    }

    size_t PprofScop::generateHash(Module *&module){
        loopID++;
        hash<string> stringhashFn;
        string hashstring = module->getName().str() + "::Loop" + to_string(loopID);
        return stringhashFn(hashstring)/10000000000; //FIXME Avoid dividing hash
    }

    void PprofScop::insertSetupTracingFunction(Function *mainFunction){
        Module * module = mainFunction->getParent();
        LLVMContext &context = module->getContext();
        IRBuilder<> builder(context);
        Instruction *insertInstruction = mainFunction->getEntryBlock().getFirstNonPHIOrDbgOrLifetime();
        builder.SetInsertPoint(insertInstruction);

        Type *voidty = Type::getVoidTy(context);

        //void setup_tracing()
        FunctionType *functionType = FunctionType::get(voidty, false);
        Constant *function = module->getOrInsertFunction("setup_tracing", functionType);
        builder.CreateCall(function, {});
    }

    void PprofScop::insertEnterRegionFunction(Module *&module, Instruction *insertPosition, PProfID &pprofID){
        LLVMContext &context = module->getContext();
        Type *voidty = Type::getVoidTy(context);
        Type *int64Ty = Type::getInt64Ty(context);
        Type *charPtrTy = Type::getInt8PtrTy(context);
        IRBuilder<> builder(context);
        builder.SetInsertPoint(insertPosition);

        //void enter_region(uint64_t, const char*)
        SmallVector<Value*, 2> arguments;
        arguments.push_back(pprofID.globalID);
        ostringstream name;
        name << module->getName().data() << "::" << insertPosition->getFunction()->getName().data() << " "
            << pprofID.moduleID;
        errs() << name.str() << '\n';
        arguments.push_back(builder.CreateGlobalStringPtr(name.str()));
        FunctionType *functionType = FunctionType::get(voidty, {int64Ty, charPtrTy}, false);
        Constant *function = module->getOrInsertFunction("enter_region", functionType);
        builder.CreateCall(function, arguments);
    }

    void PprofScop::insertExitRegionFunction(Module *&module, Instruction *insertPosition, PProfID &pprofID){
        LLVMContext &context = module->getContext();
        Type *voidty = Type::getVoidTy(context);
        Type *int64Ty = Type::getInt64Ty(context);
        IRBuilder<> builder(context);
        builder.SetInsertPoint(insertPosition);

        //void exit_region(uint64_t)
        SmallVector<Value*, 1> arguments;
        arguments.push_back(pprofID.globalID);
        FunctionType *functionType = FunctionType::get(voidty, {int64Ty}, false);
        Constant *function = module->getOrInsertFunction("exit_region", functionType);
        builder.CreateCall(function, arguments);
    }

    SmallVector<BasicBlock*, 0> PprofScop::splitPredecessors(const Region *region, BasicBlock *block, bool isEntry){
        SmallVector<BasicBlock*, 0> splitBlocks;
        //TODO Why is there a comma instead of using it directly in condition?
        for(pred_iterator it = pred_begin(block), end = pred_end(block); it != end; it++){
            BasicBlock *predecessor = *it;
            if(isEntry != region->contains(predecessor)){
                BasicBlock *splitBlock = SplitEdge(predecessor, block);
                if(splitBlock != nullptr){
                    splitBlocks.push_back(splitBlock);
                }
            }
        }
        return splitBlocks;
    }

    SmallVector<BasicBlock*, 0> PprofScop::splitPredecessors(const Region *region, SmallVector<BasicBlock*, 0> &blocks,
            bool isEntry){
        SmallVector<BasicBlock*, 0> splits;
        for(BasicBlock *block : blocks){
            SmallVector<BasicBlock*, 0> newSplits = splitPredecessors(region, block, isEntry);
            splits.insert(splits.end(), newSplits.begin(), newSplits.end());
        }
        return splits;
    }

    void PprofScop::instrumentSplitBlocks(pair<SmallVector<BasicBlock*, 0>, SmallVector<BasicBlock*, 0>> &splits){
        Module *module = splits.first.front()->getModule();
        Type *int64Ty = Type::getInt64Ty(module->getContext());
        //FIXME According to docs ConstantInt::get(...) returns a ConstantInt, but clang complains...
        PProfID pprofID((ConstantInt*) ConstantInt::get(int64Ty, generateHash(module), false), loopID);;

        for(BasicBlock *split : splits.first){
            BasicBlock::iterator insertPosition = split->getFirstNonPHIOrDbgOrLifetime()->getIterator();
            if(split->isLandingPad()){
                insertPosition++;
            }
            while(isa<AllocaInst>(insertPosition)){
                insertPosition++;
            }
            //To be sure that the enter call is past a previous exit call.
            while(isa<CallInst>(insertPosition)){
                insertPosition++;
            }
            insertEnterRegionFunction(module, &*insertPosition, pprofID);
        }

        for(BasicBlock *split : splits.second){
            BasicBlock::iterator insertPosition = split->getFirstNonPHIOrDbgOrLifetime()->getIterator();
            if(split->isLandingPad()){
                insertPosition++;
            }
            while(isa<AllocaInst>(insertPosition)){
                insertPosition++;
            }
            insertExitRegionFunction(module, &*insertPosition, pprofID);
        }
    }

    bool PprofScop::doInitialization(Module &module) {
        return false;
    }

    bool PprofScop::runOnFunction(Function &function) {
        bool gotInstrumented = false;
        if(ScopDetection *scopDetection = getAnalysisIfAvailable<ScopDetection>()){
            for(ScopDetection::const_iterator it = scopDetection->begin(); it != scopDetection->end(); it++){
                if(const Region *region = (*it)->getParent()){
                    instrumentedCounter++;

                    BasicBlock *entryBlock = region->getEntry();
                    SmallVector<BasicBlock*, 0> exitBlocks;
                    exitBlocks.push_back(region->getExit());
                    pair<SmallVector<BasicBlock*, 0>, SmallVector<BasicBlock*, 0>> splits;
                    splits.first = splitPredecessors(region, entryBlock, true);
                    splits.second = splitPredecessors(region, exitBlocks, false);
                    instrumentSplitBlocks(splits);
                    gotInstrumented = true;
                } else {
                    nonInstrumentedCounter++;
                }
            }
        } else {
            errs() << "analysis not available\n";
        }
        return gotInstrumented;
    }

    bool PprofScop::doFinalization(Module &module) {
        errs() << "Instrumented SCoPs: " << instrumentedCounter << '\n';
        errs() << "Not instrumented SCoPs: " << nonInstrumentedCounter << '\n';

        bool insertedSetupTracing = false;
        if(!calledSetup && instrumentedCounter > 0){
            Function *mainFunction = module.getFunction("main");
            if(mainFunction != nullptr){
                insertSetupTracingFunction(mainFunction);
                insertedSetupTracing = true;
                calledSetup = true;
            }
        }

        return insertedSetupTracing;
    }
}

static RegisterPass<PprofScop> XX("pprof", "pprof using ScopDetection");

static void registerPprofScop(const PassManagerBuilder &builder, legacy::PassManagerBase &managerBase){
    polly::registerCanonicalicationPasses(managerBase);
    managerBase.add(new PprofScop());
}

static RegisterStandardPasses registeredPprofScopPass(PassManagerBuilder::EP_EarlyAsPossible, registerPprofScop);
