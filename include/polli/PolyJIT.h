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
  static PolyJIT* Get(ExecutionEngine *EE = 0, Module *M = 0);

  void setEntryFunction(std::string name) {
    EntryFn = name;
  };

  ExecutionEngine *GetEngine() { return &EE; }

  // JIT and run the Main function.
  //
  // Before execution the Module preoptimizes every
  // module for use with Polly.
  // Afterwards n phases are executed:
  //
  int runMain(const std::vector<std::string> &inputArgs,
              const char * const *envp);

  int shutdown(int result);
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
  friend class Sentinel;

  ExecutionEngine &EE;
  Module &M;
  std::string EntryFn;
  FunctionPassManager *FPM;

  typedef std::set<Module *> ManagedModules;
  ManagedModules Mods;

  /* IR function declaration which gets mapped to our callback */
  Function *PJITCallback;

  /* Link extracted Scops into a module for execution. */
  void linkJitableScops(ManagedModules &, Module &);

  /* Instrument extracted Scops with a callback to the JIT */
  void instrumentScops(Module &, ManagedModules &);
  
  void extractJitableScops(Module &);
  void runPollyPreoptimizationPasses(Module &);

};

} // End llvm namespace

#endif
