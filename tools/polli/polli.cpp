//===- polli.cpp - LLVM Interpreter / Dynamic polyhedral compiler ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is derived from LLVM's lli tool and provides access to
// polyhedral & adaptive extensions of the Execution engines, without
// modifying lli's functionality itself.
//
// This utility provides a simple wrapper around the LLVM Execution Engines,
// which allow the direct execution of LLVM programs through a Just-In-Time
// compiler, or through an interpreter if no JIT is available for this platform.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polli"
#include "llvm/Support/Debug.h"

#include "llvm/IR/LLVMContext.h"
#include "RecordingMemoryManager.h"
#include "RemoteTarget.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/ExecutionEngine/JITEventListener.h"
#include "llvm/ExecutionEngine/JITMemoryManager.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/Memory.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/PluginLoader.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include <cerrno>

#include "polli/PolyJIT.h"

#ifdef __CYGWIN__
#include <cygwin/version.h>
#if defined(CYGWIN_VERSION_DLL_MAJOR) && CYGWIN_VERSION_DLL_MAJOR<1007
#define DO_NOTHING_ATEXIT 1
#endif
#endif

using namespace llvm;

namespace {
  // Runtime Options
  cl::OptionCategory PolliCategory("Polli Options",
                                   "Configure the runtime options of polli");

  cl::list<std::string> LibPaths("L", cl::Prefix,
    cl::desc("Specify a library search path"),
    cl::value_desc("directory"), cl::ZeroOrMore, cl::cat(PolliCategory));

  cl::list<std::string> Libraries("l", cl::Prefix,
    cl::desc("Specify libraries to link to"),
    cl::value_desc("library prefix"), cl::ZeroOrMore,
    cl::cat(PolliCategory));

  cl::opt<std::string>
  InputFile(cl::desc("<input bitcode>"), cl::Positional, cl::init("-"));

  cl::list<std::string>
  InputArgv(cl::ConsumeAfter, cl::desc("<program arguments>..."));

  cl::opt<std::string>
  EntryFunc("entry-function",
            cl::desc("Specify the entry function (default = 'main') "
                     "of the executable"),
            cl::value_desc("function"),
            cl::init("main"));

  cl::opt<std::string>
  FakeArgv0("fake-argv0",
            cl::desc("Override the 'argv[0]' value passed into the executing"
                     " program"), cl::value_desc("executable"));

  cl::opt<bool>
  DisableCoreFiles("disable-core-files", cl::Hidden,
                   cl::desc("Disable emission of core files if possible"));

  cl::opt<bool>
  NoLazyCompilation("disable-lazy-compilation",
                  cl::desc("Disable JIT lazy compilation"),
                  cl::init(false));

}

static ExecutionEngine *EE = 0;

static void do_shutdown() {
  // Cygwin-1.5 invokes DLL's dtors before atexit handler.
#ifndef DO_NOTHING_ATEXIT
  delete EE;
  llvm_shutdown();
#endif
}

void layoutRemoteTargetMemory(RemoteTarget *T, RecordingMemoryManager *JMM) {
  // Lay out our sections in order, with all the code sections first, then
  // all the data sections.
  uint64_t CurOffset = 0;
  unsigned MaxAlign = T->getPageAlignment();
  SmallVector<std::pair<const void*, uint64_t>, 16> Offsets;
  SmallVector<unsigned, 16> Sizes;
  for (RecordingMemoryManager::const_code_iterator I = JMM->code_begin(),
                                                   E = JMM->code_end();
       I != E; ++I) {
    DEBUG(dbgs() << "code region: size " << I->first.size()
                 << ", alignment " << I->second << "\n");
    // Align the current offset up to whatever is needed for the next
    // section.
    unsigned Align = I->second;
    CurOffset = (CurOffset + Align - 1) / Align * Align;
    // Save off the address of the new section and allocate its space.
    Offsets.push_back(std::pair<const void*,uint64_t>(I->first.base(), CurOffset));
    Sizes.push_back(I->first.size());
    CurOffset += I->first.size();
  }
  // Adjust to keep code and data aligned on seperate pages.
  CurOffset = (CurOffset + MaxAlign - 1) / MaxAlign * MaxAlign;
  unsigned FirstDataIndex = Offsets.size();
  for (RecordingMemoryManager::const_data_iterator I = JMM->data_begin(),
                                                   E = JMM->data_end();
       I != E; ++I) {
    DEBUG(dbgs() << "data region: size " << I->first.size()
                 << ", alignment " << I->second << "\n");
    // Align the current offset up to whatever is needed for the next
    // section.
    unsigned Align = I->second;
    CurOffset = (CurOffset + Align - 1) / Align * Align;
    // Save off the address of the new section and allocate its space.
    Offsets.push_back(std::pair<const void*,uint64_t>(I->first.base(), CurOffset));
    Sizes.push_back(I->first.size());
    CurOffset += I->first.size();
  }

  // Allocate space in the remote target.
  uint64_t RemoteAddr;
  if (T->allocateSpace(CurOffset, MaxAlign, RemoteAddr))
    report_fatal_error(T->getErrorMsg());
  // Map the section addresses so relocations will get updated in the local
  // copies of the sections.
  for (unsigned i = 0, e = Offsets.size(); i != e; ++i) {
    uint64_t Addr = RemoteAddr + Offsets[i].second;
    EE->mapSectionAddress(const_cast<void*>(Offsets[i].first), Addr);

    DEBUG(dbgs() << "  Mapping local: " << Offsets[i].first
                 << " to remote: " << format("%p", Addr) << "\n");

  }

  // Trigger application of relocations
  EE->finalizeObject();

  // Now load it all to the target.
  for (unsigned i = 0, e = Offsets.size(); i != e; ++i) {
    uint64_t Addr = RemoteAddr + Offsets[i].second;

    if (i < FirstDataIndex) {
      T->loadCode(Addr, Offsets[i].first, Sizes[i]);

      DEBUG(dbgs() << "  loading code: " << Offsets[i].first
            << " to remote: " << format("%p", Addr) << "\n");
    } else {
      T->loadData(Addr, Offsets[i].first, Sizes[i]);

      DEBUG(dbgs() << "  loading data: " << Offsets[i].first
            << " to remote: " << format("%p", Addr) << "\n");
    }

  }
}

//===----------------------------------------------------------------------===//
// main Driver function
//
int main(int argc, char **argv, char * const *envp) {
  sys::PrintStackTraceOnErrorSignal();
  PrettyStackTraceProgram X(argc, argv);

  LLVMContext &Context = getGlobalContext();
  atexit(do_shutdown);  // Call llvm_shutdown() on exit.

  // If we have a native target, initialize it to ensure it is linked in and
  // usable by the JIT.
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();
  InitializeNativeTargetAsmParser();

  cl::ParseCommandLineOptions(argc, argv,
                              "llvm interpreter & dynamic compiler\n");

  // If the user doesn't want core files, disable them.
  if (DisableCoreFiles)
    sys::Process::PreventCoreFiles();

  // Load the bitcode...
  SMDiagnostic Err;
  OwningPtr<Module> Mod;
  Mod.reset(ParseIRFile(InputFile, Err, Context));
  if (Mod.get() == 0) {
    Err.print(argv[0], errs());
    return 1;
  }

  // If not jitting lazily, load the whole bitcode file eagerly too.
  std::string ErrorMsg;
  if (NoLazyCompilation) {
    if (Mod->MaterializeAllPermanently(&ErrorMsg)) {
      errs() << argv[0] << ": bitcode didn't read correctly.\n";
      errs() << "Reason: " << ErrorMsg << "\n";
      exit(1);
    }
  }

  // If the user specifically requested an argv[0] to pass into the program,
  // do it now.
  if (!FakeArgv0.empty()) {
    InputFile = FakeArgv0;
  } else {
    // Otherwise, if there is a .bc suffix on the executable strip it off, it
    // might confuse the program.
    if (StringRef(InputFile).endswith(".bc"))
      InputFile.erase(InputFile.length() - 3);
  }

  // Add the module's name to the start of the vector of arguments to main().
  InputArgv.insert(InputArgv.begin(), InputFile);

  // Reset errno to zero on entry to main.
  errno = 0;

  PolyJIT *pjit = PolyJIT::Get(Mod.get());

  if (!pjit) {
    if (!ErrorMsg.empty())
      errs() << argv[0] << ": error creating EE: " << ErrorMsg << "\n";
    else
      errs() << argv[0] << ": unknown error creating EE!\n";
    exit(1);
  }

  pjit->setEntryFunction(EntryFunc);

  // Run main.
  llvm_start_multithreaded();

  int Result = pjit->runMain(InputArgv, envp);
  pjit->shutdown(Result);

  llvm_stop_multithreaded();

  return Result;
}
