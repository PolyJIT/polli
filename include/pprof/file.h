#ifndef PPROF_FILE_H
#define PPROF_FILE_H

#include "pprof/pprof.h"
#include <vector>

namespace pprof {
namespace file {
void StoreRun(const std::vector<const PPEvent *> &Events);
}
}

#endif//PPROF_FILE_H
