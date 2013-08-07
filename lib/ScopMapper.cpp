//===-- ScopMapper.cpp - LLVM Just in Time Compiler -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The SCoPMapper extracts SCoPs into a separate function in a new module.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

#include "polli/ScopMapper.h"
#include "polli/Utils.h"

#include "polli/NonAffineScopDetection.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/Verifier.h"

#include "llvm/IR/Module.h"

#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <set>

using namespace llvm;
using namespace polli;
using namespace polly;

void ScopMapper::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<NonAffineScopDetection>();
  AU.addRequired<DominatorTree>();
  AU.addRequired<RegionInfo>();
  AU.setPreservesAll();
};

void ScopMapper::moveFunctionIntoModule(Function *F, Module *Dest) {
  /* Create a new function for cloning, based on the properties
   * of our source function, but set linkage to external. */
  Function *NewF = Function::Create(F->getFunctionType(),
                                    F->getLinkage(),
                                    F->getName(),
                                    Dest);
  NewF->copyAttributesFrom(F);

  /* Copy function body ExtractedF over to ClonedF */
  Function::arg_iterator NewArg = NewF->arg_begin();
  for (Function::const_arg_iterator
       Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
    NewArg->setName(Arg->getName());
    VMap[Arg] = NewArg++;
  }

  SmallVector<ReturnInst*, 8> Returns;
  CloneFunctionInto(NewF, F, VMap,/* ModuleLevelChanges=*/false, Returns);

  // No need for the mapping anymore.
  for (Function::const_arg_iterator
       Arg = F->arg_begin(), AE = F->arg_end(); Arg != AE; ++Arg) {
    VMap.erase(Arg);
  }

  VMap[F] = NewF;
};

bool ScopMapper::runOnFunction(Function &F) {
  DominatorTree *DT  = &getAnalysis<DominatorTree>();
  NonAffineScopDetection *NSD = &getAnalysis<NonAffineScopDetection>();

  if (CreatedFunctions.count(&F))
    return false;

  /* Prepare a fresh module for this function. */
  Module *M, *NewM;
  M = F.getParent();

  /* Copy properties of our source module */
  NewM = new Module(M->getModuleIdentifier(), M->getContext());
  NewM->setTargetTriple(M->getTargetTriple());
  NewM->setDataLayout(M->getDataLayout());
  NewM->setMaterializer(M->getMaterializer());
  NewM->setModuleIdentifier(
    (M->getModuleIdentifier() + "." + F.getName()).str());

  /* Extract each SCoP in this function into a new one. */
  CodeExtractor *Extractor;
  for (NonAffineScopDetection::iterator RP = NSD->begin(), RE = NSD->end();
       RP != RE; ++RP) {
    const Region *R = RP->first;

    Extractor = new CodeExtractor(*DT, *R);
    Function *ExtractedF = Extractor->extractCodeRegion();

    if (ExtractedF) {
      ExtractedF->setLinkage(GlobalValue::ExternalLinkage);

      DefaultFunctionCloner Cloner(VMap, NewM); 
      Cloner.setSource(ExtractedF);
      
      InstrumentingFunctionCloner InstCloner(VMap);
      InstCloner.setSource(Cloner.start());
      InstCloner.start(); 

      /* FIXME: Do not depend on this set. */
      CreatedFunctions.insert(ExtractedF);
    }

    delete Extractor;
  }

  DEBUG(StoreModule(*NewM, M->getModuleIdentifier() + "." + F.getName()));

  /* Keep track for the linker after cleaning the cloned functions. */
  CreatedModules.insert(NewM);

  return true;
};

char ScopMapper::ID = 0;
