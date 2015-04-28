#ifndef PPROF_FILE_H
#define PPROF_FILE_H

#include "pprof/pprof.h"
#include <vector>
#include <map>

namespace pprof {
namespace file {
void StoreRun(Run<PPEvent> &Events, const Options &opts);
bool ReadRun(Run<PPEvent> &Events,
             std::map<uint32_t, PPStringRegion> &Regions, const Options &opt);
}
}

#endif//PPROF_FILE_H
