#ifndef POLLI_COMPILER_H
#define POLLI_COMPILER_H

#include "polli/Monitor.h"
#include "polli/Options.h"

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/ExecutionEngine/RuntimeDyld.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/TargetSelect.h"

#include <unordered_map>

namespace polli {
class ModuleCompiler {
public:
  using ObjFileT = llvm::object::OwningBinary<llvm::object::ObjectFile>;

  ObjFileT operator()(llvm::Module &M) const;
};

class SpecializingCompiler {
public:
  using UniqueModule = std::unique_ptr<llvm::Module>;
  using SharedModule = std::shared_ptr<llvm::Module>;
  using OptimizeFunction = std::function<SharedModule(SharedModule)>;

  using context_type = polli::Monitor<llvm::LLVMContext>;
  using context_module_pair =
      std::pair<llvm::Module &, polli::Monitor<llvm::LLVMContext> &>;

private:
  std::mutex DLMutex;
  std::mutex ModuleMutex;

  llvm::orc::RTDyldObjectLinkingLayer ObjectLayer;
  llvm::orc::IRCompileLayer<decltype(ObjectLayer), ModuleCompiler> CompileLayer;
  llvm::orc::IRTransformLayer<decltype(CompileLayer), OptimizeFunction> OptimizeLayer;
  void *LibHandle;

public:
  using ModuleHandleT = decltype(OptimizeLayer)::ModuleHandleT;

  explicit SpecializingCompiler();

  /**
   * @brief Read the LLVM-IR module from the given prototype string.
   *
   * @param prototype The prototype string we want to read in.
   * @return llvm::Module& The LLVM-IR module we just read.
   */
  SpecializingCompiler::SharedModule
  getModule(const uint64_t ID, const char *prototype, bool &cache_hit);
  std::shared_ptr<context_type> getContext(const uint64_t ID);

  llvm::Expected<ModuleHandleT> addModule(std::shared_ptr<llvm::Module> M);

  void removeModule(ModuleHandleT H);

  llvm::JITSymbol findSymbol(const std::string &Name,
                             const llvm::DataLayout &DL);
  ~SpecializingCompiler();

private:
  using context_list = std::vector<context_type>;

  std::unordered_map<uint64_t, std::shared_ptr<context_type>> LoadedContexts;
  std::unordered_map<uint64_t, SharedModule> LoadedModules;
};

} // namespace polli

#endif
