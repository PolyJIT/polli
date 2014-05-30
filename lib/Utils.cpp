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
#include "llvm/ADT/OwningPtr.h"
#include "llvm/ADT/Twine.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Assembly/PrintModulePass.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"

#include "polli/Options.h"
#include "polli/Utils.h"
using namespace llvm;

SmallVector<char, 255> *DefaultDir;

void initializeOutputDir() {
  DefaultDir = new SmallVector<char, 255>();
  SmallVector<char, 255> cwd;
  fs::current_path(cwd);

  p::append(cwd, "polli");
  fs::createUniqueDirectory(StringRef(cwd.data(), cwd.size()), *DefaultDir);

  outs() << "Storing results in: " << StringRef(DefaultDir->data(),
                                                DefaultDir->size()) << "\n";
}

void StoreModule(Module &M, const Twine &Name) {
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
