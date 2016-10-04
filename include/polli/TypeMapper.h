#ifndef POLLI_TYPE_MAPPER_H
#define POLLI_TYPE_MAPPER_H

#include "llvm/Linker/IRMover.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Casting.h"

namespace polli {
class TypeMapTy : public llvm::ValueMapTypeRemapper {
  /// This is a mapping from a source type to a destination type to use.
  llvm::DenseMap<llvm::Type *, llvm::Type *> MappedTypes;

  /// When checking to see if two subgraphs are isomorphic, we speculatively
  /// add types to MappedTypes, but keep track of them here in case we need to
  /// roll back.
  llvm::SmallVector<llvm::Type *, 16> SpeculativeTypes;

  llvm::SmallVector<llvm::StructType *, 16> SpeculativeDstOpaqueTypes;

  /// This is a list of non-opaque structs in the source module that are mapped
  /// to an opaque struct in the destination module.
  llvm::SmallVector<llvm::StructType *, 16> SrcDefinitionsToResolve;

  /// This is the set of opaque types in the destination modules who are
  /// getting a body from the source module.
  llvm::SmallPtrSet<llvm::StructType *, 16> DstResolvedOpaqueTypes;

public:
  TypeMapTy(llvm::IRMover::IdentifiedStructTypeSet &DstStructTypesSet)
      : DstStructTypesSet(DstStructTypesSet) {}

  llvm::IRMover::IdentifiedStructTypeSet &DstStructTypesSet;
  /// Indicate that the specified type in the destination module is conceptually
  /// equivalent to the specified type in the source module.
  void addTypeMapping(llvm::Type *DstTy, llvm::Type *SrcTy);

  /// Produce a body for an opaque type in the dest module from a type
  /// definition in the source module.
  void linkDefinedTypeBodies();

  /// Return the mapped type to use for the specified input type from the
  /// source module.
  llvm::Type *get(llvm::Type *SrcTy);
  llvm::Type *get(llvm::Type *SrcTy,
                  llvm::SmallPtrSet<llvm::StructType *, 8> &Visited);

  void finishType(llvm::StructType *DTy, llvm::StructType *STy,
                  llvm::ArrayRef<llvm::Type *> ETypes);

  llvm::FunctionType *get(llvm::FunctionType *T) {
    return llvm::cast<llvm::FunctionType>(get((llvm::Type *)T));
  }

private:
  llvm::Type *remapType(llvm::Type *SrcTy) override { return get(SrcTy); }

  bool areTypesIsomorphic(llvm::Type *DstTy, llvm::Type *SrcTy);
};
} //namespace polli
#endif /* end of include guard: POLLI_TYPE_MAPPER_H */
