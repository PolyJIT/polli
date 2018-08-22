#include "absl/strings/str_cat.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/YAMLTraits.h"
#include "llvm/Support/raw_ostream.h"

#include "polli/ExportMetrics.h"
#include "polli/Options.h"

#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_map>

using llvm::yaml::MappingTraits;
using llvm::yaml::ScalarTraits;
using llvm::yaml::SequenceElementTraits;
using llvm::yaml::SequenceTraits;

namespace llvm {
namespace yaml {
template <> struct MappingTraits<polli::JitEventData::EventTy> {
  static void mapping(IO &io, polli::JitEventData::EventTy &Value) {
    io.mapRequired("region-id", std::get<0>(Value));
    io.mapRequired("value", std::get<1>(Value));
  }
  static const bool flow = true;
};

template <> struct MappingTraits<polli::JitEventData::IdToNameTy> {
  static void mapping(IO &io, polli::JitEventData::IdToNameTy &Value) {
    io.mapRequired("region-id", std::get<0>(Value));
    io.mapRequired("region-name", std::get<1>(Value));
  }
  static const bool flow = true;
};

template <> struct SequenceElementTraits<polli::JitEventData::EventTy> {
  static const bool flow = false;
};

template <> struct SequenceElementTraits<polli::JitEventData::IdToNameTy> {
  static const bool flow = false;
};

template <> struct MappingTraits<polli::JitEventData> {
  static void mapping(IO &io, polli::JitEventData &Value) {
    io.mapRequired("RunID", Value.RunID);
    io.mapRequired("events", Value.Events);
    io.mapRequired("entries", Value.Entries);
    io.mapRequired("regions", Value.Regions);
  }
};

template <> struct MappingTraits<polli::ScopMetadata> {
  static void mapping(IO &io, polli::ScopMetadata &Value) {
    io.mapRequired("RunID", Value.RunID);
    io.mapRequired("FunctionName", Value.FunctionName);
    io.mapRequired("Schedule", Value.Schedule);
    io.mapRequired("AST", Value.AST);
  }
};
} // namespace yaml
} // namespace llvm

namespace polli {
namespace yaml {

void StoreRun(polli::JitEventData &Data) {
  if (!polli::opt::EnableTracking)
    return;

  __pid_t PID = getpid();
  std::error_code EC;
  llvm::ToolOutputFile OutF(Data.OutFile, EC,
                            llvm::sys::fs::OpenFlags::F_Text);
  llvm::yaml::Output YamlOut(OutF.os());
  YamlOut << Data;

  OutF.keep();
}

void StoreScopMetadata(polli::ScopMetadata &Data) {
  if (!polli::opt::EnableTracking)
    return;

  __pid_t PID = getpid();
  std::error_code EC;
  llvm::ToolOutputFile OutF(Data.OutFile, EC,
                            llvm::sys::fs::OpenFlags::F_Text);
  llvm::yaml::Output YamlOut(OutF.os());
  YamlOut << Data;

  OutF.keep();
}
} // namespace yaml
} // namespace polli