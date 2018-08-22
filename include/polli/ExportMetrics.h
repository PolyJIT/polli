#pragma once

#include <string>
#include <unordered_map>

#include "llvm/ADT/SmallVector.h"

namespace polli {
using EventMapTy = std::unordered_map<uint64_t, uint64_t>;
using RegionMapTy = std::unordered_map<uint64_t, std::string>;

struct JitEventData {
  using EventTy = std::pair<uint64_t, uint64_t>;
  using IdToNameTy = std::pair<uint64_t, std::string>;
  
  std::string OutFile;
  uint64_t RunID;

  llvm::SmallVector<JitEventData::EventTy, 8> Events;
  llvm::SmallVector<JitEventData::EventTy, 8> Entries;
  llvm::SmallVector<JitEventData::IdToNameTy, 8> Regions;
};

struct ScopMetadata {
  uint64_t RunID;
  std::string FunctionName;
  std::string Schedule;
  std::string AST;
  std::string OutFile;
};

namespace yaml {
void StoreRun(JitEventData &Data);
void StoreScopMetadata(ScopMetadata &Data);

} // namespace yaml
} // namespace polli