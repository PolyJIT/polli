#ifndef POLLI_DB_H
#define POLLI_DB_H

#include <unordered_map>
#include <string>

using EventMapTy = std::unordered_map<uint64_t, uint64_t>;
using RegionMapTy = std::unordered_map<uint64_t, std::string>;

namespace polli {
namespace opt {
extern std::string Experiment;
extern std::string ExperimentUUID;
extern std::string Project;
extern std::string Domain;
extern std::string Group;
extern std::string SourceUri;
extern std::string Argv0;
extern bool EnableDatabase;
extern bool ExecuteAtExit;

extern std::string DbHost;
extern int DbPort;
extern std::string DbUsername;
extern std::string DbPassword;
extern std::string DbName;
extern std::string RunGroupUUID;
extern int RunID;
}

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
};

TraceData &setup();
extern "C" void enter_region(uint64_t id, const char *name);
extern "C" void exit_region(uint64_t id);
extern "C" void submit_results();
extern "C" void setup_tracing();

}
}

#endif /* end of include guard: POLLI_DB_H */
