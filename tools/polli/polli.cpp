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
#define DEBUG_TYPE "polyjit"
#include "polli/PolyJIT.h"

#include "llvm/ADT/Triple.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IRReader/IRReader.h"

#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
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

#include "polli/Options.h"
#include "pprof/Tracing.h"

#ifdef __CYGWIN__
#include <cygwin/version.h>
#if defined(CYGWIN_VERSION_DLL_MAJOR) && CYGWIN_VERSION_DLL_MAJOR<1007
#define DO_NOTHING_ATEXIT 1
#endif
#endif

#include <memory>

using namespace llvm;

static ExecutionEngine *EE = 0;

static void do_shutdown() {
  // Cygwin-1.5 invokes DLL's dtors before atexit handler.
#ifndef DO_NOTHING_ATEXIT
  delete EE;
  llvm_shutdown();
  LIKWID_MARKER_CLOSE;
#endif
}

static bool loadSymbolsFromLibrary(const std::string &Lib) {
  std::string ErrorMsg;
  DEBUG(dbgs().indent(2) << "Linking: " << Lib << "\n");
  if (sys::DynamicLibrary::LoadLibraryPermanently(Lib.c_str(), &ErrorMsg)) {
    errs() << "ERROR: " << ErrorMsg << "\n";
    return false;
  }

  return true;
}

//===----------------------------------------------------------------------===//
// main Driver function
//
int main(int argc, char **argv, char * const *envp) {
  using namespace polli;

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
  if (opt::DisableCoreFiles)
    sys::Process::PreventCoreFiles();

  // Load the bitcode...
  SMDiagnostic Err;
  std::unique_ptr<Module> Mod(parseIRFile(opt::InputFile, Err, Context));
  if (Mod.get() == 0) {
    Err.print(argv[0], errs());
    return 1;
  }

  // Otherwise, if there is a .bc suffix on the executable strip it off, it
  // might confuse the program.
  if (StringRef(opt::InputFile).endswith(".bc"))
    opt::InputFile.erase(opt::InputFile.length() - 3);

  // Add the module's name to the start of the vector of arguments to main().
  opt::InputArgv.insert(opt::InputArgv.begin(), (!opt::FakeArgv0.empty())
                                                    ? opt::FakeArgv0
                                                    : opt::InputFile);

  // Reset errno to zero on entry to main.
  errno = 0;

  LIKWID_MARKER_INIT;

  polli::PolyJIT *pjit = polli::PolyJIT::Get(Mod.get());

  if (!pjit) {
    errs() << argv[0] << ": error creating PolyJIT\n";
    exit(1);
  }

  pjit->setEntryFunction(opt::EntryFunc);

  // Link libraries.
  for (unsigned i = 0; i < opt::Libraries.size(); ++i) {
    std::string Lib = "lib" + opt::Libraries[i] + ".so";
    if (opt::Libraries[i] == "gfortran")
      Lib = Lib + ".3";

    // Load the symbols and try the staic lib, if we can't load the shared one.
    if (!loadSymbolsFromLibrary(Lib)) {
      Lib = "lib" + opt::Libraries[i] + ".a";
      if (loadSymbolsFromLibrary(Lib)) {
        errs() << "Loaded " << Lib << " instead.\n";
      }
    }
  }

  int Result = pjit->runMain(opt::InputArgv, envp);

  pjit->shutdown(Result);

  return Result;
}
