//===-- PolyJIT.h - Class definition for the PolyJIT ------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the top-level PolyJIT data structure.
//
//===----------------------------------------------------------------------===//
#ifndef POLYJIT_H
#define POLYJIT_H

#include "JIT.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"

namespace llvm {

class Function;
struct JITEvent_EmittedFunctionDetails;
class MachineCodeEmitter;
class MachineCodeInfo;
class TargetJITInfo;
class TargetMachine;

class PolyJITState : public JITState {
private:
  FunctionPassManager PM;
  Module *M;
    
  std::vector<AssertingVH<Function> > PendingFunctions;

public:
  explicit PolyJITState(Module *M) : JITState(M), PM(M), M(M) {}

  FunctionPassManager &getPM(const MutexGuard &L) {
    return PM;
  }

  Module *getModule() const { return M; }
  std::vector<AssertingVH<Function> > &getPendingFunctions(const MutexGuard &L){
    return PendingFunctions;
  }
};

class PolyJIT : public JIT {
  /// types
  typedef ValueMap<const BasicBlock *, void *>
      BasicBlockAddressMapTy;
  /// data
  TargetMachine &TM;       // The current target we are compiling to
  TargetJITInfo &TJI;      // The JITInfo for the target we are compiling to
  JITCodeEmitter *JCE;     // JCE object
  JITMemoryManager *JMM;
  std::vector<JITEventListener*> EventListeners;

  /// AllocateGVsWithCode - Some applications require that global variables and
  /// code be allocated into the same region of memory, in which case this flag
  /// should be set to true.  Doing so breaks freeMachineCodeForFunction.
  bool AllocateGVsWithCode;

  /// True while the JIT is generating code.  Used to assert against recursive
  /// entry.
  bool isAlreadyCodeGenerating;

  PolyJITState *jitstate;

  /// BasicBlockAddressMap - A mapping between LLVM basic blocks and their
  /// actualized version, only filled for basic blocks that have their address
  /// taken.
  BasicBlockAddressMapTy BasicBlockAddressMap;


  PolyJIT(Module *M, TargetMachine &tm, TargetJITInfo &tji,
      JITMemoryManager *JMM, bool AllocateGVsWithCode);
public:
  ~PolyJIT();

  static void Register() {
    PolyJITCtor = createPolyJIT;
  }
  
  /// getJITInfo - Return the target JIT information structure.
  ///
  TargetJITInfo &getJITInfo() const { return TJI; }

  /// create - Create an return a new JIT compiler if there is one available
  /// for the current target.  Otherwise, return null.
  ///
  static ExecutionEngine *create(Module *M,
                                 std::string *Err,
                                 JITMemoryManager *JMM,
                                 CodeGenOpt::Level OptLevel =
                                   CodeGenOpt::Default,
                                 bool GVsWithCode = true,
                                 Reloc::Model RM = Reloc::Default,
                                 CodeModel::Model CMM = CodeModel::JITDefault) {
    return ExecutionEngine::createPolyJIT(M, Err, JMM, OptLevel, GVsWithCode,
                                          RM, CMM);
  }
  
  static ExecutionEngine *createPolyJIT(Module *M,
                                        std::string *ErrorStr,
                                        JITMemoryManager *JMM,
                                        bool GVsWithCode,
                                        TargetMachine *TM);

};

} // End of namespace llvm

#endif
