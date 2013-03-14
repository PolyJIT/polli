#include "PolyJIT.h"
#include "polly/LinkAllPasses.h"
#include "polly/ScopDetection.h"
#include "llvm/Support/DynamicLibrary.h"

using namespace llvm;

/// createPolyJIT - This is the factory method for creating a JIT for the
/// current machine, it does not fall back to the interpreter.  This takes
/// ownership of the module.
ExecutionEngine *PolyJIT::createPolyJIT(Module *M,
                                        std::string *ErrorStr,
                                        JITMemoryManager *JMM,
                                        bool GVsWithCode,
                                        TargetMachine *TM) {
  // Try to register the program as a source of symbols to resolve against.
  //
  // FIXME: Don't do this here.
  sys::DynamicLibrary::LoadLibraryPermanently(0, NULL);

  // If the target supports JIT code generation, create the JIT.
  if (TargetJITInfo *TJ = TM->getJITInfo()) {
    return new PolyJIT(M, *TM, *TJ, JMM, GVsWithCode);
  } else {
    if (ErrorStr)
      *ErrorStr = "target does not support JIT code generation";
    return 0;
  }
}

PolyJIT::PolyJIT(Module *M, TargetMachine &tm, TargetJITInfo &tji,
         JITMemoryManager *jmm, bool GVsWithCode)
  : ExecutionEngine(M), TM(tm), TJI(tji),
    JMM(jmm ? jmm : JITMemoryManager::CreateDefaultMemManager()),
    AllocateGVsWithCode(GVsWithCode), isAlreadyCodeGenerating(false) {
  setDataLayout(TM.getDataLayout());

  jitstate = new PolyJITState(M);

  // Initialize JCE
  JCE = createEmitter(*this, JMM, TM);

  // Register in global list of all JITs.
  AllJits->Add(this);

  // Add target data
  MutexGuard locked(lock);
  FunctionPassManager &PM = jitstate->getPM(locked);
  PM.add(new DataLayout(*TM.getDataLayout()));

  // Turn the machine code intermediate representation into bytes in memory that
  // may be executed.
  if (TM.addPassesToEmitMachineCode(PM, *JCE)) {
    report_fatal_error("Target does not support machine code emission!");
  }

  // Register routine for informing unwinding runtime about new EH frames
#if HAVE_EHTABLE_SUPPORT
#if USE_KEYMGR
  struct LibgccObjectInfo* LOI = (struct LibgccObjectInfo*)
    _keymgr_get_and_lock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST);

  // The key is created on demand, and libgcc creates it the first time an
  // exception occurs. Since we need the key to register frames, we create
  // it now.
  if (!LOI)
    LOI = (LibgccObjectInfo*)calloc(sizeof(struct LibgccObjectInfo), 1);
  _keymgr_set_and_unlock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST, LOI);
  InstallExceptionTableRegister(DarwinRegisterFrame);
  // Not sure about how to deregister on Darwin.
#else
  InstallExceptionTableRegister(__register_frame);
  InstallExceptionTableDeregister(__deregister_frame);
#endif // __APPLE__
#endif // HAVE_EHTABLE_SUPPORT

  // Initialize passes.
  PM.doInitialization();
}
