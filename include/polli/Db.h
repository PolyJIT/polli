#ifndef POLLI_DB_H
#define POLLI_DB_H

#include <unordered_map>
#include <string>

using EventMapTy = std::unordered_map<uint64_t, uint64_t>;
using RegionMapTy = std::unordered_map<uint64_t, std::string>;

namespace polli {
namespace db {
void StoreRun(const EventMapTy &Events, const EventMapTy &Entries,
              const RegionMapTy &Regions);

void StoreTransformedScop(const std::string &FnName,
                          const std::string &IslAstStr,
                          const std::string &ScheduleTreeStr);

void ValidateOptions();
}

namespace tracing {
struct TraceData {
  std::unordered_map<uint64_t, uint64_t> Events;
  std::unordered_map<uint64_t, uint64_t> Entries;
  std::unordered_map<uint64_t, std::string> Regions;

  ~TraceData();
};

extern "C" void enter_region(uint64_t id, const char *name);
extern "C" void exit_region(uint64_t id);
extern "C" void setup_tracing();
}
}

#endif /* end of include guard: POLLI_DB_H */
