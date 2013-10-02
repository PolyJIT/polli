//===-- PolyJIT.h - Class definition for the JIT --------------------*- C++ -*-===//
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

#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/PassManager.h"
#include "llvm/Support/ValueHandle.h"

#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"

#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include "polli/Utils.h"

#include <set>

namespace llvm {

class Function;
struct JITEvent_EmittedFunctionDetails;
class MachineCodeEmitter;
class MachineCodeInfo;
class TargetJITInfo;
class TargetMachine;

class PolyJIT {
public:
  static PolyJIT* Get(Module *M = 0, bool NoLazyCompilation = false);

  // Creates a fresh ExecutionEngine for the given Module.
  static ExecutionEngine* GetEngine(Module *M, bool NoLazyCompilation = false);

  void setEntryFunction(std::string name) {
    EntryFn = name;
  };

  // JIT and run the Main function.
  //
  // Before execution the Module preoptimizes every
  // module for use with Polly.
  // Afterwards n phases are executed:
  //
  int runMain(const std::vector<std::string> &inputArgs,
              const char * const *envp);

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
  static PolyJIT* Instance;

  PolyJIT(ExecutionEngine *ee, Module *m) : EE(*ee), M(*m) {
    FPM = new FunctionPassManager(&M);
  };

  PolyJIT(const PolyJIT &);
  ~PolyJIT() {}

  struct Sentinel {
  public: ~Sentinel() {
    if (PolyJIT::Instance)
      delete PolyJIT::Instance;
    }
  };
  friend struct Sentinel;

  ExecutionEngine &EE;
  Module &M;
  std::string EntryFn;
  FunctionPassManager *FPM;

  /* The modules we create & manage during execution of the main module M. */
  ManagedModules Mods;

  /* Link extracted Scops into a module for execution. */
  void linkJitableScops(ManagedModules &, Module &);

  /* Instrument extracted Scops with a callback to the JIT */
  void instrumentScops(Module &, ManagedModules &);

  void extractJitableScops(Module &);
  void runPollyPreoptimizationPasses(Module &);
};

} // End llvm namespace

#endif
