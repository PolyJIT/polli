#ifndef PPROF_PGSQL_H
#define PPROF_PGSQL_H

#include "pprof/pprof.h"
#include <pthread.h>
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
Run<pprof::Event> ReadSimpleRun(uint32_t run_id);

void StoreRun(const pthread_t tid, Run<PPEvent> &Events,
              const pprof::Options &opts);
void StoreRunMetrics(long run_id, const Metrics &M);
}
}

#endif//PPROF_PGSQL_H
