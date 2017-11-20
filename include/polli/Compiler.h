#ifndef POLLI_COMPILER_H
#define POLLI_COMPILER_H

#include "polli/Monitor.h"
#include "polli/RuntimeOptimizer.h"
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
#include <utility>

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
  polli::Monitor<llvm::LLVMContext> Ctx;

  std::mutex DLMutex;
  std::mutex ModuleMutex;

  llvm::orc::RTDyldObjectLinkingLayer ObjectLayer;
  llvm::orc::IRCompileLayer<decltype(ObjectLayer), ModuleCompiler> CompileLayer;

  polli::RuntimeOptimizer RtOptFtor;

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
  using ModCacheResult = std::pair<SharedModule, bool>;
  ModCacheResult getModule(const uint64_t ID, const char *prototype);

  const polli::Monitor<llvm::LLVMContext> &getContext() const;

  /**
   * @brief Add a module for eager compilation.
   *
   * @param M
   *
   * @return
   */
  using OptimizedModule =
      std::pair<llvm::Expected<ModuleHandleT>, /*IsOptimized=*/bool>;
  OptimizedModule addModule(std::shared_ptr<llvm::Module> M);

  void removeModule(ModuleHandleT H);

  llvm::JITSymbol findSymbol(const std::string &Name,
                             const llvm::DataLayout &DL);
  ~SpecializingCompiler();

  bool IsOptimizeable(const polli::SharedModule &M) const;

  /**
   * @brief Maintain a set of blocked modules, where optimization is useless.
   */
  using BlockedModules = std::set<std::shared_ptr<const llvm::Module>>;
  bool isBlocked(std::shared_ptr<const llvm::Module> M) const {
    return BlockedMods.find(M) != BlockedMods.end();
  }

  void block(std::shared_ptr<const llvm::Module> M) {
    BlockedMods.insert(M);
  }

  void unblock(std::shared_ptr<const llvm::Module> M) {
    BlockedMods.erase(M);
  }

private:
  std::unordered_map<uint64_t, SharedModule> LoadedModules;
  BlockedModules BlockedMods;
};

} // namespace polli

#endif
