#ifndef PPROF_PGSQL_H
#define PPROF_PGSQL_H

#include "pprof/pprof.h"
#include <vector>
#include <map>

namespace pprof {
namespace pgsql {

void StoreRun(Run<PPEvent> &Events, const Options &opts);
bool ReadRun(Run<PPEvent> &Events,
             std::map<uint32_t, PPStringRegion> &Regions, const Options &opt);

using Metrics = std::map<std::string, double>;
void StoreRunMetrics(long run_id, const Metrics &M);
}
}

#endif//PPROF_PGSQL_H
