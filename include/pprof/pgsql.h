#ifndef PPROF_PGSQL_H
#define PPROF_PGSQL_H

#include "pprof/pprof.h"
#include <vector>
#include <map>

namespace pprof {
namespace pgsql {
void StoreRun(const std::vector<const PPEvent *> &Events, const Options &opts);
bool ReadRun(std::vector<const PPEvent *> &Events,
             std::map<uint32_t, PPStringRegion> &Regions, const Options &opt);
}
}

#endif//PPROF_PGSQL_H
