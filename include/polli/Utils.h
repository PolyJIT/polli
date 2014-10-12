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

enum LogType {
  Info,
  Debug,
  Warning,
  Error
};

typedef std::map<Module *, ExecutionEngine *> ManagedModules;

extern SmallVector<char, 255> *DefaultDir;

/**
 * @brief Get a stream to place log-output into.
 *
 * @param T The log type we want.
 * @param Level indentation level, default: 0
 *
 * @return stream to put our log output to.
 */
llvm::raw_ostream &log(const LogType T = Info, const size_t Level = 0);

/**
 * @brief Initialize the output directory to put all intermediate files into.
 */
void initializeOutputDir();

/**
 * @brief Store a module with a given name in the output directory.
 *
 * @param M the module to store
 * @param Name filename to store the module under.
 */
void StoreModule(Module &M, const Twine &Name);

/**
 * @brief Store a set of modules in the output directory.
 *
 * @param Modules the modules to store
 */
void StoreModules(ManagedModules &Modules);

/**
 * @brief Get a report output stream and indent it to the correct depth
 *
 * @param Indent Indentation level, we indent with spaces.
 *
 * @return the indented output stream.
 */
llvm::raw_ostream &report(const size_t Indent = 0);
#endif // POLLI_UTILS_H
