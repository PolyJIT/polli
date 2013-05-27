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


namespace llvm {

class Function;
struct JITEvent_EmittedFunctionDetails;
class MachineCodeEmitter;
class MachineCodeInfo;
class TargetJITInfo;
class TargetMachine;

class PolyJIT {
public:
  PolyJIT(ExecutionEngine *ee, Module *m) : EE(*ee), M(*m) {
    FPM = new FunctionPassManager(&M);
  };

  void setEntryFunction(std::string name) {
    EntryFn = name;
  };

  void runJitableSCoPDetection(Module &);
  void runPollyPreoptimizationPasses(Module &);

  // JIT and run the Main function.
  //
  // Before execution the Module preoptimizes every
  // module for use with Polly.
  // Afterwards n phases are executed:
  //
  int runMain(const std::vector<std::string> &inputArgs, const char * const *envp) {
    Function *Main = M.getFunction(EntryFn);

    if (!Main) {
      errs() << '\'' << EntryFn << "\' function not found in module.\n";
      return -1;
    }

    // Run static constructors.
    EE.runStaticConstructorsDestructors(false);

    // Trigger compilation separately so code regions that need to be 
    // invalidated will be known.
    //(void)EE.getPointerToFunction(Main);

    runPollyPreoptimizationPasses(M);
    runJitableSCoPDetection(M);

    return EE.runFunctionAsMain(Main, inputArgs, envp);
  };

  int shutdown(int result) {
    LLVMContext &Context = M.getContext();
    // Run static destructors.
    EE.runStaticConstructorsDestructors(true);

    // If the program doesn't explicitly call exit, we will need the Exit
    // function later on to make an explicit call, so get the function now.
    Constant *Exit = M.getOrInsertFunction("exit", Type::getVoidTy(Context),
                                                   Type::getInt32Ty(Context),
                                                   NULL);

    // If the program didn't call exit explicitly, we should call it now.
    // This ensures that any atexit handlers get called correctly.
    if (Function *ExitF = dyn_cast<Function>(Exit)) {
      std::vector<GenericValue> Args;
      GenericValue ResultGV;
      ResultGV.IntVal = APInt(32, result);
      Args.push_back(ResultGV);
      EE.runFunction(ExitF, Args);
      errs() << "ERROR: exit(" << result << ") returned!\n";
      abort();
    } else {
      errs() << "ERROR: exit defined with wrong prototype!\n";
      abort();
    }
  };
private:
  ExecutionEngine &EE;
  Module &M;
  std::string EntryFn;
  FunctionPassManager *FPM;
};

} // End llvm namespace

#endif
