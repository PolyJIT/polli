#ifndef POLLI_COMPILER_H
#define POLLI_COMPILER_H

#include <unordered_map>
#include <utility>

#include "polli/Monitor.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/Options.h"

#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/IRTransformLayer.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"


using llvm::DataLayout;
using llvm::Expected;
using llvm::object::OwningBinary;
using llvm::orc::RTDyldObjectLinkingLayer;
using llvm::orc::IRCompileLayer;

using llvm::JITSymbol;
using llvm::LLVMContext;
using llvm::Module;

using polli::RuntimeOptimizer;
using polli::Monitor;

namespace polli {
class ModuleCompiler {
public:
  using ObjFileT = OwningBinary<llvm::object::ObjectFile>;

  ObjFileT operator()(Module &M) const;
};

class SpecializingCompiler {
public:
  using UniqueModule = std::unique_ptr<Module>;
  using SharedModule = std::shared_ptr<Module>;
  using OptimizeFunction = std::function<SharedModule(SharedModule)>;

  using context_type = Monitor<LLVMContext>;
  using context_module_pair =
      std::pair<Module &, Monitor<LLVMContext> &>;

  using ModCacheResult = std::pair<SharedModule, bool>;
  using BlockedModules = std::set<std::shared_ptr<const Module>>;
private:
  Monitor<LLVMContext> Ctx;

  std::mutex DLMutex;
  std::mutex ModuleMutex;

  RTDyldObjectLinkingLayer ObjectLayer;
  IRCompileLayer<decltype(ObjectLayer), ModuleCompiler> CompileLayer;

  std::set<SharedModule> OptimizedModules;

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
  ModCacheResult getModule(const uint64_t ID, const char *prototype);
  const Monitor<LLVMContext> &getContext() const;

  /**
   * @brief Add a module for eager compilation.
   *
   * @param M
   *
   * @return
   */
  using OptimizedModule =
      std::pair<Expected<ModuleHandleT>, /*IsOptimized=*/bool>;
  OptimizedModule addModule(std::shared_ptr<llvm::Module> M);

  void removeModule(ModuleHandleT H);

  JITSymbol findSymbol(const std::string &Name, const DataLayout &DL);
  ~SpecializingCompiler();

  bool IsOptimizeable(const SharedModule &M) const;

  /**
   * @brief Maintain a set of blocked modules, where optimization is useless.
   */
  bool isBlocked(std::shared_ptr<const llvm::Module> M) const {
    return BlockedMods.find(M) != BlockedMods.end();
  }

  void block(std::shared_ptr<const Module> M) {
    BlockedMods.insert(M);
  }

  void unblock(std::shared_ptr<const Module> M) {
    BlockedMods.erase(M);
  }

private:
  std::unordered_map<uint64_t, SharedModule> LoadedModules;
  BlockedModules BlockedMods;
};

} // namespace polli

#endif
