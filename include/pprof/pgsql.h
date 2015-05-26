#ifndef PPROF_PGSQL_H
#define PPROF_PGSQL_H

#include "pprof/pprof.h"
#include <vector>
#include <map>
#include <set>

namespace pprof {
namespace pgsql {

using IdVector = std::vector<uint32_t>;
using UuidSet = std::set<std::string>;
using Metrics = std::map<std::string, double>;

UuidSet ReadAvailableRunGroups();
IdVector ReadAvailableRunIDs(std::string run_group);
Run<PPEvent> ReadRun(uint32_t run_id,
                     std::map<uint32_t, PPStringRegion> &Regions);

void StoreRun(Run<PPEvent> &Events, const pprof::Options &opts);
void StoreRunMetrics(long run_id, const Metrics &M);
}
}

#endif//PPROF_PGSQL_H
