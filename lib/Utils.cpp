//===-- Utils.h -------------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include <string>                       // for string
#include <utility>                      // for pair
#include "llvm/ADT/OwningPtr.h"         // for OwningPtr
#include "llvm/ADT/SmallVector.h"       // for SmallVector
#include "llvm/ADT/Twine.h"             // for Twine
#include "llvm/Bitcode/BitcodeWriterPass.h" // for BitcodeWriterPass
#include "llvm/IR/LegacyPassManager.h"  // for PassManager
#include "llvm/IR/Module.h"             // for Module
#include "llvm/IR/Verifier.h"           // for createVerifierPass
#include "llvm/Pass.h"                  // for FunctionPass
#include "llvm/Support/CommandLine.h"   // for initializer, desc, init, etc
#include "llvm/Support/Debug.h"         // for dbgs, DEBUG
#include "llvm/Support/FileSystem.h"    // for OpenFlags::F_RW
#include "llvm/Support/ToolOutputFile.h"  // for tool_output_file
#include "llvm/Support/raw_ostream.h"   // for raw_ostream
#include "llvm/Support/system_error.h"  // for error_code
#include "polli/Utils.h"                // for ManagedModules

using namespace llvm;

SmallVector<char, 255> *DefaultDir;

static bool DirReady = false;

static cl::opt<bool>
GenerateOutput("polli-debug-ir",
               cl::desc("Store all IR files inside a unique subdirectory."),
               cl::init(false));

void initializeOutputDir() {
  DefaultDir = new SmallVector<char, 255>();
  SmallVector<char, 255> cwd;
  fs::current_path(cwd);

  p::append(cwd, "polli");
  fs::createUniqueDirectory(StringRef(cwd.data(), cwd.size()), *DefaultDir);

  outs() << "Storing results in: " << StringRef(DefaultDir->data(),
                                                DefaultDir->size()) << "\n";
  DirReady = true;
}

void StoreModule(Module &M, const Twine &Name) {
  if (!GenerateOutput)
    return;

  if (!DirReady)
    initializeOutputDir();

  llvm::error_code err;
  SmallVector<char, 255> destPath = *DefaultDir;

  std::string ErrorInfo;
  OwningPtr<tool_output_file> Out;

  M.setModuleIdentifier(Name.str());

  p::append(destPath, Name);

  std::string path = StringRef(destPath.data(), destPath.size()).str();
  DEBUG(dbgs().indent(2) << "Storing: " << M.getModuleIdentifier() << "\n");
  Out.reset(new tool_output_file(path.c_str(), ErrorInfo, F_RW));

  PassManager PM;
  PM.add(new DataLayoutPass(&M));
  PM.add(llvm::createVerifierPass());
  PM.add(createBitcodeWriterPass(Out->os()));
  PM.run(M);
  Out->keep();
}

void StoreModules(ManagedModules &Modules) {
  for (auto &Modules_MI : Modules) {
    Module *M = (Modules_MI).first;
    StoreModule(*M, M->getModuleIdentifier());
  }
}
