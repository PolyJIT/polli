#include "pprof/pprof.h"

#include <inttypes.h>
#include <papi.h>
#include <stdio.h>
#include <stdlib.h>

#include <map>
#include <fstream>
#include <iostream>
#include <memory>
#include <pthread.h>
#include <sstream>
#include <string>
#include <vector>

#include <sys/stat.h>

#include "pprof/pgsql.h"
#include "pprof/file.h"
#include "pprof/csv.h"

using namespace pprof;

namespace pprof {
Options *getOptions() {
  static Options opts = getPprofOptionsFromEnv();
  return &opts;
}

/**
 * @brief Storage container for all PAPI region events.
 */
Run<PPEvent> PapiEvents;
} // namespace pprof

extern "C" {
void papi_region_enter_scop(uint64_t id, const char *dbg) {
  PPEvent Ev(id, ScopEnter, dbg);
  Ev.snapshot();
  PapiEvents.push_back(Ev);
}

void papi_region_exit_scop(uint64_t id, const char *dbg) {
  PPEvent Ev(id, ScopExit, dbg);
  Ev.snapshot();
  PapiEvents.push_back(Ev);
}

void papi_region_enter(uint64_t id) {
  PPEvent Ev(id, RegionEnter);
  Ev.snapshot();
  PapiEvents.push_back(Ev);
}

void papi_region_exit(uint64_t id) {
  PPEvent Ev(id, RegionExit);
  Ev.snapshot();
  PapiEvents.push_back(Ev);
}

void papi_atexit_handler(void) {
  Options &opts = *getOptions();
  if (!opts.execute_atexit)
    return;

  PapiEvents.push_back(PPEvent(0, RegionExit, "STOP"));

  if (opts.use_db)
    pgsql::StoreRun(PapiEvents, opts);
  if (opts.use_file)
    file::StoreRun(PapiEvents, opts);
  if (opts.use_csv)
    csv::StoreRun(PapiEvents, opts);

  PapiEvents.clear();
  PAPI_shutdown();
}

void papi_region_setup() {
  int init = PAPI_library_init(PAPI_VER_CURRENT);
  if (init != PAPI_VER_CURRENT && init > 0)
    fprintf(stderr, "ERROR(PPROF): PAPI_library_init: Version mismatch\n");

  init = PAPI_is_initialized();
  if (init != PAPI_LOW_LEVEL_INITED)
    fprintf(stderr, "ERROR(PPROF): PAPI_library_init failed!\n");

  if (PAPI_thread_init(pthread_self) != PAPI_OK)
    fprintf(stderr, "ERROR(PPROF): PAPI_thread_init failed!\n");

  int err = atexit(papi_atexit_handler);
  if (err)
    fprintf(stderr, "ERROR(PAPI-Prof): Failed to setup atexit handler (%d).\n",
            err);
  PapiEvents.push_back(PPEvent(0, RegionEnter, "START"));
}
}

class StaticInitializer {
public:
  StaticInitializer() {
    papi_region_setup();
  }
};
static StaticInitializer InitializeLib;
