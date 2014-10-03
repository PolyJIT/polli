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
};

class PolyJIT {
public:
  static PolyJIT *Get(Module *M = 0);

  // Creates a fresh ExecutionEngine for the given Module.
  ExecutionEngine *GetEngine(Module *M);

  void setEntryFunction(std::string name) { EntryFn = name; };

  // JIT and run the Main function.
  //
  // Before execution the Module preoptimizes every
  // module for use with Polly.
  // Afterwards n phases are executed:
  //
  int runMain(const std::vector<std::string> &inputArgs,
              const char *const *envp);

  int shutdown(int result);

  Module &getExecutedModule() { return M; }

  /* Execute a function with the given arguments.
     The function needs to follow the "main" format:

     i32 main(i32 argc, i8** params);

     The function dispatcher is capable of providing this
     structure. */
  void runSpecializedFunction(Function *NewF,
                              const std::vector<GenericValue> &ArgValues);

private:
  static PolyJIT *Instance;

  Module &M;
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

  ExecutionEngine *EE;
  std::string EntryFn;

  /* The modules we create & manage during execution of the main module M. */
  ManagedModules Mods;

  /* Code generation options for all jit'ed modules. */
  TargetOptions Options;

  /* Code gen optimization level for all jit'ed modules. */
  CodeGenOpt::Level OLvl;

  /* Link extracted Scops into a module for execution. */
  void linkJitableScops(ManagedModules &, Module &);

  /* Instrument extracted Scops with a callback to the JIT */
  void instrumentScops(Module &, ManagedModules &);

  void extractJitableScops(Module &);
  void runPollyPreoptimizationPasses(Module &);
};

} // End llvm namespace

#endif
