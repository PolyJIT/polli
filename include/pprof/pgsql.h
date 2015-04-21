#ifndef PPROF_PGSQL_H
#define PPROF_PGSQL_H

#include "pprof/pprof.h"
#include <vector>

namespace pprof {
namespace pgsql {
void StoreRun(const std::vector<const PPEvent *> &Events);
}
}

#endif//PPROF_PGSQL_H
