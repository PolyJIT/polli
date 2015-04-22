#ifndef PPROF_CSV_H
#define PPROF_CSV_H

#include "pprof/pprof.h"
#include <vector>

namespace pprof {
namespace csv {
void StoreRun(std::vector<const PPEvent *> &Events, const Options &opts);
}
}

#endif//PPROF_CSV_H
