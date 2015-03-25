#include "polli/ModuleExtractor.h"
#include "polli/ScopMapper.h"
#include "polli/FunctionCloner.h"

#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Attributes.h"

#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "spdlog/spdlog.h"

using namespace llvm;

namespace polli {
char ModuleExtractor::ID = 0;
auto Console = spdlog::stderr_logger_st("polli");

using ModulePtrT = std::shared_ptr<Module>;

static ModulePtrT copyModule(Module &M) {
  ModulePtrT NewM =
      std::make_shared<Module>(M.getModuleIdentifier(), M.getContext());
  NewM->setTargetTriple(M.getTargetTriple());
  NewM->setDataLayout(M.getDataLayout());
  NewM->setMaterializer(M.getMaterializer());

  return NewM;
}


void ModuleExtractor::getAnalysisUsage(AnalysisUsage &AU) const { 
  AU.addRequired<ScopMapper>();
}

void ModuleExtractor::releaseMemory() {
}

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

static Function *extractPrototypeM(ValueToValueMapTy &VMap, Function &F,
                                   Module &M) {
    MovingFunctionCloner MoveCloner(VMap, &M);
    MoveCloner.setSource(&F);
    return MoveCloner.start();
}

static Function *extractInstrumentedM(ValueToValueMapTy &VMap, Function &F,
                                      Module &M, Pass &SinkHost) {
    InstrumentingFunctionCloner InstCloner(VMap, &M);
    InstCloner.setSource(&F);
    InstCloner.setSinkHostPass(&SinkHost);

    Function *InstF = InstCloner.start();
    InstF->addFnAttr(Attribute::OptimizeNone);
    return InstF;
}

bool ModuleExtractor::runOnFunction(Function &F) {
  ScopMapper &SM = getAnalysis<ScopMapper>();

  Module &M = *(F.getParent());
  StringRef ModuleName = F.getParent()->getModuleIdentifier();
  ValueToValueMapTy VMap;
  IRBuilder<> Builder(F.begin());

  std::for_each(SM.begin(), SM.end(), [&](Function *F) {
    StringRef FunctionName = F->getName();

    ModulePtrT PrototypeM = copyModule(M);
    PrototypeM->setModuleIdentifier((ModuleName + "." + FunctionName).str() +
                                    ".prototype");

    Function *ProtoF = extractPrototypeM(VMap, *F, *PrototypeM);
    Function *InstrF = extractInstrumentedM(VMap, *ProtoF, M, SM);

    F->replaceAllUsesWith(InstrF);

    std::string PrototypeModStr = moduleToString(*PrototypeM);
    Builder.CreateGlobalString(PrototypeModStr,
                               InstrF->getName() + ".prototype");
  });
  
  return true;
}

void ModuleExtractor::print(raw_ostream &, const Module *) const {
}

static RegisterPass<ModuleExtractor>
    X("polli-extract-scops", "PolyJIT - Move extracted SCoPs into new modules");
} // end of polli namespace
