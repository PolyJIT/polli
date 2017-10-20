#include "pprof/pprof.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <pthread.h>
#include <sstream>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

#include <sys/stat.h>

#include "polli/log.h"
#include "pprof/file.h"
#include "pprof/pgsql.h"

#include "spdlog/spdlog.h"

#include <papi.h>

using namespace pprof;

REGISTER_LOG(console, "libpprof");

namespace pprof {
Options *getOptions() {
  static Options Opts = getPprofOptionsFromEnv();
  return &Opts;
}

using RunMap = std::map<const thread::id, Run<PPEvent>>;
static inline RunMap &papi_threaded_events() {
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
static inline TIDMapT &papi_get_tid_map() {
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
  thread::id STid = std::this_thread::get_id();
  TIDMapT &TIDMap = papi_get_tid_map();

  if (TIDMap.find(STid) != TIDMap.end())
    return TIDMap.at(STid);

  TIDMap[STid] = TID++;
  return TIDMap[STid];
}

/**
 * @brief Storage container for all PAPI region events.
 */
Run<PPEvent> PapiEvents;

void papi_store_thread_events(const Options &opts) {
  thread::id Tid = std::this_thread::get_id();
  uint64_t Id = papi_get_tid_map()[Tid];
  //pgsql::StoreRun(Id, papi_threaded_events()[Tid], opts);
}
} // namespace pprof

static __thread bool PapiThreadInit = false;
static bool PapiInit = false;
static void do_papi_thread_init_once() {
  if (!PapiThreadInit) {
    if (!PapiInit)
      papi_region_setup();

    int Ret = PAPI_thread_init(papi_get_thread_id);
    if (Ret != PAPI_OK) {
      if (Ret == PAPI_ENOINIT) {
        PAPI_library_init(PAPI_VER_CURRENT);
        do_papi_thread_init_once();
      } else {
        console->error("PAPI_thread_init() = {:d}", Ret);
        console->error("{:s}", PAPI_strerror(Ret));
        exit(Ret);
      }
    } else {
      papi_local_events(&papi_threaded_events()[std::this_thread::get_id()]);
      PapiThreadInit = (Ret == PAPI_OK);
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
void record_stats(uint64_t id, const char *dbg, uint64_t enter, uint64_t exit) {
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
  Options &Opts = *getOptions();
  if (!Opts.execute_atexit)
    return;

  uint64_t Bytes = 0;
  for (auto Elem : papi_threaded_events()) {
    Bytes += Elem.second.size() * sizeof(PPEvent);
  }

  if (Opts.use_file) {
    papi_local_events()->push_back(PPEvent(0, RegionExit, "STOP"));
    for (auto Elem : papi_threaded_events()) {
      file::StoreRun(Elem.second, Opts);
    }
  }

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
  int Init = PAPI_library_init(PAPI_VER_CURRENT);
  if (Init != PAPI_VER_CURRENT) {
    console->error("[ERROR] PAPI_library_init = {:d}", Init);
    console->error("[ERROR] {:s}", PAPI_strerror(Init));
  }

  PapiInit = true;
  do_papi_thread_init_once();

  SPDLOG_DEBUG("libpprof", "papi_region_setup from thread: {:d}",
               papi_get_thread_id());

  if (int Err = atexit(papi_atexit_handler))
    console->error("Failed to setup papi_atexit_handler ({:d}).", Err);

  papi_local_events()->push_back(PPEvent(0, RegionEnter, "START"));
  PapiInit = true;
}
}
