//===-- PolyJIT.h - Class definition for the JIT --------------------*- C++
//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the top-level JIT data structure.
//
//===----------------------------------------------------------------------===//

#ifndef PolyJIT_H
#define PolyJIT_H
#include "polli/Utils.h"

#include "llvm/ExecutionEngine/SectionMemoryManager.h"

#include <string> // for string
#include <vector> // for vector

namespace llvm {
class ExecutionEngine;
class Module;
class Function;
struct GenericValue;
}

namespace polli {
/// @brief Memory manager for PolyJIT.
class PolyJITMemoryManager : public SectionMemoryManager {
private:
  uint64_t NumAllocatedDataSections;
  uint64_t NumAllocatedCodeSections;
  uint64_t AllocatedBytes;

public:
  explicit PolyJITMemoryManager() : AllocatedBytes(0) {}

  void print(llvm::raw_ostream &OS);
  uint64_t getSymbolAddress(const std::string &Name) override;
  uint8_t *allocateCodeSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID,
                               StringRef SectionName) override;
  uint8_t *allocateDataSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID, StringRef SectionName,
                               bool IsReadOnly) override;

  virtual ~PolyJITMemoryManager() override;
};

/**
 * @brief The PolyJIT. Execute arbitrary code powered by MCJIT.
 *
 * TODO: longer explanation needs to go here.
 */
class PolyJIT {
public:
  /**
   * @brief Get the singleton instance.
   *
   * @param M
   *
   * @return The current PolyJIT instance.
   */
  static PolyJIT *Get(Module *M = 0);

  /**
   * @brief Creates a fresh ExecutionEngine for the given Module.
   *
   * @param M The module we need a fresh execution engine for.
   *
   * @return A new execution engine for the module.
   */
  ExecutionEngine *GetEngine(Module *M);

  /**
   * @brief Setter for the JIT's EntryFn.
   *
   * @param name The entry function's name.
   */
  void setEntryFunction(std::string name) { EntryFn = name; };

  /**
   * @brief Run the EntryFn. Starts this PolyJIT session.
   *
   * @param inputArgs
   * @param envp
   *
   * @return
   */
  int runMain(const std::vector<std::string> &inputArgs,
              const char *const *envp);

  /**
   * @brief Shutdown the JIT and clean up the mess we made.
   *
   * Before we actually do the cleanup, we print some nice stats about the
   * current session.
   *
   * @param result Our exit-code
   *
   * @return
   */
  int shutdown(int result);

  /**
   * @brief Getter for the 'main' module.
   *
   * @return Reference to the main module.
   */
  Module &getExecutedModule() { return M; }

  /**
   * @brief Execute a specialized function.
   *
   * Executes a specialized function by applying it to the given list of
   * argument values.
   *  The function needs to follow the "main" format:
   *
   *  i32 main(i32 argc, i8** params);
   *
   * @param NewF The function to execute
   * @param ArgValues A list of parameter values to the apply the function to.
   */
  void runSpecializedFunction(Function *NewF,
                              const std::vector<GenericValue> &ArgValues);

private:
  /**
   * @name Hidden, because singleton.
   * @{ */
  static PolyJIT *Instance;
  PolyJIT(Module &Main);
  PolyJIT(const PolyJIT &);
  ~PolyJIT() {}
  struct Sentinel {
  public:
    ~Sentinel() {
      if (PolyJIT::Instance)
        delete PolyJIT::Instance;
    }
  };
  friend struct Sentinel;
  /**  @} */

  /**
   * @brief Our 'main' module we work on.
   */
  Module &M;

  /**
   * @brief Our default 'main' execution engine.
   * TODO: Why do I store it in here, check that again.
   */
  ExecutionEngine *EE;

  /**
   * @brief Our EntryFn, usually it is main()
   */
  std::string EntryFn;

  /**
   * @brief The set of modules this PolyJIT hast to deal with.
   */
  ManagedModules Mods;

  /**
   * @brief Our memory manager, keeps track of all emitted objects.
   */
  PolyJITMemoryManager MemMan;

  /**
   * @brief TargetOptions to be used for all execution engines.
   */
  TargetOptions Options;

  /**
   * @brief CodeGen optimization level for all modules emitted by the JIT.
   */
  CodeGenOpt::Level OLvl;

  /**
   * @brief Link extracted Scops into a module for execution.
   *
   * @param The set of managed modules to link into a single one.
   * @param The module to link into.
   */
  void linkJitableScops(ManagedModules &, Module &);

  /**
   * @brief Optimize the module before executing it for the first time.
   *
   * @param M The 'main' module we prepare for execution.
   */
  void prepareOptimizedIR(Module &M);

  /**
   * @brief Instrument extracted Scops with a callback to the JIT
   *
   * @param
   * @param
   */
  void instrumentScops(Module &, ManagedModules &);

  /**
   * @brief Extract all jitable Scops into a separate module
   *
   * @param The module to extract all jitable Scops from
   */
  void extractJitableScops(Module &);

  /**
   * @brief Run Polly's default set of preoptimization on a module.
   *
   * @param The module to run the preoptimization on.
   */
  void runPollyPreoptimizationPasses(Module &);
};

} // End llvm namespace

#endif
