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

namespace llvm {
  // Runtime Options
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
}

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
  std::unique_ptr<Module> Mod(parseIRFile(InputFile, Err, Context));
  if (Mod.get() == 0) {
    Err.print(argv[0], errs());
    return 1;
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

  LIKWID_MARKER_INIT;

  polli::PolyJIT *pjit = polli::PolyJIT::Get(Mod.get());

  if (!pjit) {
    errs() << argv[0] << ": error creating PolyJIT\n";
    exit(1);
  }

  pjit->setEntryFunction(EntryFunc);

  // Link libraries.
  for (unsigned i = 0; i < Libraries.size(); ++i) {
    std::string Lib = "lib" + Libraries[i] + ".so";
    if (Libraries[i] == "gfortran")
      Lib = Lib + ".3";


    // Load the symbols and try the staic lib, if we can't load the shared one.
    if (!loadSymbolsFromLibrary(Lib)) {
      Lib = "lib" + Libraries[i] + ".a";
      if (loadSymbolsFromLibrary(Lib)) {
        errs() << "Loaded " << Lib << " instead.\n";
      }
    }

  }

  int Result = pjit->runMain(InputArgv, envp);

  pjit->shutdown(Result);

  return Result;
}
