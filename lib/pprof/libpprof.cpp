#include "pprof/pprof.h"

#include <inttypes.h>
#include <papi.h>
#include <stdio.h>
#include <stdlib.h>

#include <map>
#include <unordered_map>
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

using namespace pprof;

namespace pprof {
Options *getOptions() {
  static Options opts = getPprofOptionsFromEnv();
  return &opts;
}

using RunMap = std::unordered_map<pthread_t, Run<PPEvent>>;
static RunMap PapiThreadedEvents;
static __thread Run<PPEvent> *PapiLocalEvents;

/**
 * @brief Storage container for all PAPI region events.
 */
Run<PPEvent> PapiEvents;
} // namespace pprof

static __thread bool papi_thread_init = false;
static inline void do_papi_thread_init_once() {
  if (!papi_thread_init) {
    int ret = PAPI_thread_init(pthread_self);
    if (ret != PAPI_OK) {
      fprintf(stderr, "PAPI_library_init() failed\n");
      exit(ret);
    }
    PapiLocalEvents = &PapiThreadedEvents[pthread_self()];
    papi_thread_init = (ret == PAPI_OK);
  }
}

extern "C" {
/**
 * @brief Mark the entry of a SCoP.
 *
 * The Entry gets assigned to the matching event-chain in memory.
 *
 * @param id An unique ID that identifies the SCoP.
 * @param dbg An optional name for the SCoP.
 * @return void
 */
void papi_region_enter_scop(uint64_t id, const char *dbg) {
  do_papi_thread_init_once();
  PPEvent Ev(id, ScopEnter, dbg);
  Ev.snapshot();
  PapiLocalEvents->push_back(Ev);
}

/**
 * @brief Mark the exit of a SCoP
 *
 * @param id An unique ID that identifies the SCoP.
 * @param dbg An optional name for the SCoP.
 * @return void
 */
void papi_region_exit_scop(uint64_t id, const char *dbg) {
  PPEvent Ev(id, ScopExit, dbg);
  Ev.snapshot();
  PapiLocalEvents->push_back(Ev);
}

/**
 * @brief Mark the entry of a Region
 *
 * @param id An unique ID that identifies the Region.
 * @return void
 */
void papi_region_enter(uint64_t id, const char *dbg) {
  do_papi_thread_init_once();
  PPEvent Ev(id, RegionEnter, dbg);
  Ev.snapshot();
  PapiLocalEvents->push_back(Ev);
}

/**
 * @brief Mark the exit of a Region
 *
 * @param id An unique ID that identifies the Region.
 * @return void
 */
void papi_region_exit(uint64_t id, const char *dbg) {
  PPEvent Ev(id, RegionExit, dbg);
  Ev.snapshot();
  PapiLocalEvents->push_back(Ev);
}

/**
 * @brief Persist all measurement data in the backend.
 *
 * Depending on the backend this will push out the data from memory.
 * Nothing is stored before the atexit handler has been executed.
 * If applications exit without honoring the atexit handler, you're
 * out of luck.
 *
 * @return void
 */
void papi_atexit_handler(void) {
  Options &opts = *getOptions();
  if (!opts.execute_atexit)
    return;

  PapiLocalEvents->push_back(PPEvent(0, RegionExit, "STOP"));

  if (opts.use_db) {
    for (auto elem : PapiThreadedEvents) {
      pgsql::StoreRun(elem.first, elem.second, opts);
    }
  }
  if (opts.use_file)
    file::StoreRun(PapiEvents, opts);

  PapiLocalEvents->clear();
  PAPI_shutdown();
}

/**
 * @brief Initialize the PAPI based region profiler.
 *
 * This executes maintenance tasks for the use of the PAPI library.
 *
 * @return void
 */
void papi_region_setup() {
  int init = PAPI_library_init(PAPI_VER_CURRENT);
  if (init != PAPI_VER_CURRENT && init > 0)
    fprintf(stderr, "ERROR(PPROF): PAPI_library_init: Version mismatch\n");

  do_papi_thread_init_once();

  init = PAPI_is_initialized();
  if (init != PAPI_LOW_LEVEL_INITED)
    fprintf(stderr, "ERROR(PPROF): PAPI_library_init failed!\n");

  int err = atexit(papi_atexit_handler);
  if (err)
    fprintf(stderr, "ERROR(PAPI-Prof): Failed to setup atexit handler (%d).\n",
            err);
  //PapiEvents.push_back(PPEvent(0, RegionEnter, "START"));
  PapiLocalEvents->push_back(PPEvent(0, RegionEnter, "START"));
}
}

class StaticInitializer {
public:
  StaticInitializer() {
    papi_region_setup();
  }
};
static StaticInitializer InitializeLib;
