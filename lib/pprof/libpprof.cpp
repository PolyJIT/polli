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
#include <thread>
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

using RunMap = std::map<const thread::id, Run<PPEvent>>;
static inline RunMap& papi_threaded_events() {
  static RunMap PapiThreadedEvents;
  return PapiThreadedEvents;
}

static inline Run<PPEvent> *papi_local_events(Run<PPEvent> *Evs = nullptr) {
  static __thread Run<PPEvent> *PapiLocalEvents;
  if (Evs != nullptr)
    PapiLocalEvents = Evs;
  return PapiLocalEvents;
}

using TIDMapT = std::map<thread::id, uint64_t>;
static uint64_t TID = 0;
static inline TIDMapT& papi_get_tid_map() {
  static std::map<thread::id, uint64_t> TIDMap;
  return TIDMap;
}

/**
 * @brief Get a unique thread id of type uint64_t
 *
 * thread_id and pthread_t should be treated opaque, so
 * we track a simple integer for each thread_id we encounter.
 *
 * @return a unique thread_id of type uint64_t.
 */
static uint64_t papi_get_thread_id() {
  thread::id sTID = std::this_thread::get_id();
  TIDMapT &TIDMap = papi_get_tid_map();

  if (!(TIDMap.find(sTID) == TIDMap.end()))
    return TIDMap.at(sTID);

  TIDMap[sTID] = TID++;
  return TIDMap[sTID];
}

/**
 * @brief Storage container for all PAPI region events.
 */
Run<PPEvent> PapiEvents;
} // namespace pprof

static __thread bool papi_thread_init = false;
static bool papi_init = false;
static inline void do_papi_thread_init_once() {
  if (!papi_thread_init) {
    if (!papi_init)
      papi_region_setup();
    int ret = PAPI_thread_init(papi_get_thread_id);

    if (ret != PAPI_OK) {
      if (ret == PAPI_ENOINIT) {
        PAPI_library_init(PAPI_VER_CURRENT);
        do_papi_thread_init_once();
      } else {
        fprintf(stderr, "[ERROR] PAPI_thread_init() = %d\n", ret);
        fprintf(stderr, "[ERROR] %s\n", PAPI_strerror(ret));
        exit(ret);
      }
    } else {
      papi_local_events(&papi_threaded_events()[std::this_thread::get_id()]);
      papi_thread_init = (ret == PAPI_OK);
    }
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
  papi_local_events()->push_back(Ev);
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
  papi_local_events()->push_back(Ev);
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
  papi_local_events()->push_back(Ev);
}

/**
 * @brief Partially record polli::Stats objects as papi events.
 */
void record_stats(uint64_t id, const char *dbg,
                  uint64_t enter, uint64_t exit) {
  do_papi_thread_init_once();
  PPEvent Enter(id, RegionEnter, enter, dbg);
  PPEvent Exit(id, RegionExit, exit, dbg);
  papi_local_events()->push_back(Enter);
  papi_local_events()->push_back(Exit);
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
  papi_local_events()->push_back(Ev);
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

  papi_local_events()->push_back(PPEvent(0, RegionExit, "STOP"));
  uint64_t bytes = 0;
  for (auto elem : papi_threaded_events()) {
    bytes += elem.second.size() * sizeof(PPEvent);
  }
  if (opts.use_db) {
    thread::id tid = std::this_thread::get_id();
    fprintf(stderr, "libpprof: %ld tid %ld events - %f MB\n",
            papi_get_tid_map()[tid], papi_threaded_events()[tid].size(),
            papi_threaded_events()[tid].size() * sizeof(PPEvent) /
                (double)(1024 * 1024));

    pgsql::StoreRun(papi_get_tid_map()[tid], papi_threaded_events()[tid], opts);
  }
  if (opts.use_file)
    file::StoreRun(PapiEvents, opts);

  papi_local_events()->clear();
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
  if (init != PAPI_VER_CURRENT) {
    fprintf(stderr, "[ERROR] PAPI_library_init = %d\n", init);
    fprintf(stderr, "[ERROR] %s\n", PAPI_strerror(init));
  }

  papi_init = true;
  do_papi_thread_init_once();

  if (int err = atexit(papi_atexit_handler))
    fprintf(stderr, "[ERROR] Failed to setup papi_atexit_handler (%d).\n",
            err);

  papi_local_events()->push_back(PPEvent(0, RegionEnter, "START"));
  papi_init = true;
}
}
