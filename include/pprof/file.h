#ifndef PPROF_FILE_H
#define PPROF_FILE_H

#include "pprof/pprof.h"
#include <vector>

namespace pprof {
namespace file {
void StoreRun(const std::vector<const PPEvent *> &Events, const Options &opts);
}
}

#endif//PPROF_FILE_H
