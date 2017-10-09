//===-- Utils.cpp -----------------------------------------------*- C++ -*-===//
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
#include "polli/Utils.h"
#include "polli/log.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/Analysis/PostDominators.h"

#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h" // for createVerifierPass

using namespace llvm;
using namespace llvm::legacy;
using namespace polli;

REGISTER_LOG(console, "utils");

SmallVector<char, 255> *DefaultDir;

static bool DirReady = false;

void initializeOutputDir() {
  DefaultDir = new SmallVector<char, 255>();
  SmallVector<char, 255> Cwd;
  fs::current_path(Cwd);

  p::append(Cwd, "polli");
  fs::createUniqueDirectory(StringRef(Cwd.data(), Cwd.size()), *DefaultDir);

  DirReady = true;
}

void StoreModule(Module &M, const Twine &Name) {
  if (!opt::runtime::GenerateOutput)
    return;

  if (!DirReady)
    initializeOutputDir();

  M.setModuleIdentifier(Name.str());

  SmallVector<char, 255> DestPath = *DefaultDir;
  std::error_code ErrorInfo;

  p::append(DestPath, Name);

  std::string Path = StringRef(DestPath.data(), DestPath.size()).str();
  std::unique_ptr<tool_output_file> Out(
      new tool_output_file(Path.c_str(), ErrorInfo, sys::fs::F_None));

  // Remove all debug info before storing.
  // FIXME: This is just working around bugs.
  // Somewhere we don't fetch all symbols during extraction.
  llvm::StripDebugInfo(M);

  llvm::legacy::PassManager PM;
  PM.add(llvm::createVerifierPass());
  PM.add(createPrintModulePass(Out->os()));
  PM.run(M);

  Out->os().close();
  Out->keep();
}

void StoreModules(ManagedModules &Modules) {
  for (auto &ModulesMi : Modules) {
    ModulePtrT M = (ModulesMi).first;
    StoreModule(*M, M->getModuleIdentifier());
  }
}

namespace polli {
/* @brief Remove the given function from the dominator tree.
 *
 * If we have a DominatorTree available, we can remove the extracted
 * function from it, to avoid further problems with wrong dominance
 * information.
 */
void removeFunctionFromDomTree(Function &F, DominatorTree &DT) {
  DomTreeNode *N = DT.getNode(&F.getEntryBlock());
  if (!N) {
    console->debug("Entry block of ({:s}) not found in given dominator tree.",
                   F.getName().str());
    return;
  }
  std::vector<BasicBlock *> Nodes;

  for (po_iterator<DomTreeNode *> I = po_begin(N), E = po_end(N); I != E; ++I)
    Nodes.push_back(I->getBlock());

  for (BasicBlock *BB : Nodes)
    DT.eraseNode(BB);
}
} // namespace polli
