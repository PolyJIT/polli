#include "polli/Options.h"

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/RuntimeDyld.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/TargetSelect.h"

namespace polli {
class ModuleCompiler {
  llvm::TargetMachine &TM;

public:
  using ObjFileT = llvm::object::OwningBinary<llvm::object::ObjectFile>;

  ModuleCompiler(llvm::TargetMachine &TM) : TM(TM) {}
  ObjFileT operator()(llvm::Module &M) const;
};


class PolyJITEngine {
public:
  using ObjLayerT = llvm::orc::RTDyldObjectLinkingLayer;
  using CompileLayerT = llvm::orc::IRCompileLayer<ObjLayerT, ModuleCompiler>;
  using ModuleHandleT = CompileLayerT::ModuleHandleT;
  using UniqueModule = std::unique_ptr<llvm::Module>;
  using SharedModule = std::shared_ptr<llvm::Module>;

  explicit PolyJITEngine();

  /**
   * @brief Read the LLVM-IR module from the given prototype string.
   *
   * @param prototype The prototype string we want to read in.
   * @return llvm::Module& The LLVM-IR module we just read.
   */
  llvm::Module &getModule(const char *prototype, bool &cache_hit);
  llvm::Expected<ModuleHandleT> addModule(std::unique_ptr<llvm::Module> M);

  void removeModule(ModuleHandleT H);

  llvm::JITSymbol findSymbol(const std::string &Name);
  ~PolyJITEngine();

private:
  std::mutex DLMutex;
  std::vector<std::shared_ptr<llvm::LLVMContext>> CtxList;
  std::unique_ptr<llvm::TargetMachine> TM;
  const llvm::DataLayout DL;
  ObjLayerT ObjectLayer;
  CompileLayerT CompileLayer;
  llvm::DenseMap<const char *, SharedModule> LoadedModules;
  llvm::DenseMap<llvm::Module *, ModuleHandleT> CompiledModules;
  void *LibHandle;
};

}
