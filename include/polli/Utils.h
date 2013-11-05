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
#ifndef POLLI_UTILS_H
#define POLLI_UTILS_H

#include "llvm/PassManager.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FileUtilities.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/ToolOutputFile.h"

#include "llvm/Support/raw_ostream.h"

#include <set>
#include <map>

using namespace llvm;
using namespace llvm::sys::fs;

namespace fs = llvm::sys::fs;
namespace p = llvm::sys::path;

typedef std::map<Module *, ExecutionEngine *> ManagedModules;

extern SmallVector<char, 255> *DefaultDir;

void initializeOutputDir();
void StoreModule(Module &M, const Twine &Name);
void StoreModules(ManagedModules &Modules);
#endif // POLLI_UTILS_H
