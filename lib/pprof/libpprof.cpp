#include "pprof/pprof.h"

#include <inttypes.h>
#include <papi.h>
#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <vector>
#include <map>
#include <pthread.h>
#include <memory>
#include <fstream>
#include <iostream>
#include <sstream>

#include <sys/stat.h>

#include "pprof/pgsql.h"
#include "pprof/file.h"
#include "pprof/csv.h"

using namespace pprof;

/**
 * @brief Storage container for all PAPI region events.
 */
static std::vector<const PPEvent *> PapiEvents;

extern "C" {
void papi_region_enter_scop(uint64_t id, const char *dbg) {
  PPEvent *ev = new PPEvent(id, ScopEnter, dbg);
  PapiEvents.push_back(ev);
  ev->snapshot();
}

void papi_region_exit_scop(uint64_t id, const char *dbg) {
  PPEvent *ev = new PPEvent(id, ScopExit, dbg);
  ev->snapshot();
  PapiEvents.push_back(ev);
}

void papi_region_enter(uint64_t id) {
  PPEvent *ev = new PPEvent(id, RegionEnter);
  ev->snapshot();
  PapiEvents.push_back(ev);
}

void papi_region_exit(uint64_t id) {
  PPEvent *ev = new PPEvent(id, RegionExit);
  ev->snapshot();
  PapiEvents.push_back(ev);
}

static Options getPprofOptionsFromEnv() {
  Options Opts;

  const char *exp = std::getenv("PPROF_EXPERIMENT");
  const char *prj = std::getenv("PPROF_PROJECT");
  const char *cmd = std::getenv("PPROF_CMD");
  const char *db = std::getenv("PPROF_USE_DATABASE");
  const char *csv = std::getenv("PPROF_USE_CSV");
  const char *file = std::getenv("PPROF_USE_FILE");

  Opts.experiment = exp ? exp : "unknown";
  Opts.project = prj ? prj : "unknown";
  Opts.command = cmd ? cmd : "unknown";
  Opts.use_db = db ? (bool)stoi(db) : false;
  Opts.use_csv = csv ? (bool)stoi(csv) : true;
  Opts.use_file = file ? (bool)stoi(file) : true;

  return Opts;
}

void papi_atexit_handler(void) {
  PPEvent *ev = new PPEvent(0, RegionExit, "STOP");
  Options opts = getPprofOptionsFromEnv();

  ev->snapshot();
  PapiEvents.push_back(ev);

  if (opts.use_db)
    pgsql::StoreRun(PapiEvents, opts);
  if (opts.use_file)
    file::StoreRun(PapiEvents, opts);
  if (opts.use_csv)
    csv::StoreRun(PapiEvents, opts);

  for (auto evt : PapiEvents)
    delete evt;

  PapiEvents.clear();
  PAPI_shutdown();
}

void papi_region_setup() {
  PPEvent *ev = new PPEvent(0, RegionEnter, "START");
  PapiEvents.push_back(ev);
  ev->snapshot();

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
}
}

#ifdef ENABLE_CALIBRATION
static long long papi_calib_cnt = 1000;

void papi_calibrate(void) {
  long long time = PAPI_get_virt_nsec();
  long long time2 = PAPI_get_real_nsec();


  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(1, "a");
    papi_region_enter_scop(2, "b");
    papi_region_exit_scop(2, "b");
    papi_region_exit_scop(1, "a");
  }

  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(1, "a");
    papi_region_enter_scop(2, "b");
    papi_region_enter_scop(3, "c");
    papi_region_exit_scop(3, "c");
    papi_region_exit_scop(2, "b");
    papi_region_exit_scop(1, "a");
  }

  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(3, "c");
    papi_region_exit_scop(3, "c");
  }

  time = (PAPI_get_virt_nsec() - time);
  time2 = (PAPI_get_real_nsec() - time2);

  // Measurement is done per "pair" of PAPI calls.
  double avg = time / (double)(PapiEvents.size() / 2);
  double avg2 = time2 / (double)(PapiEvents.size() / 2);

  fprintf(stdout, "User time per call (ns): %f\n", avg);
  fprintf(stdout, "Real time per call (ns): %f\n", avg2);
  fprintf(stdout, "PAPI-stack calls: %lu\n", PapiEvents.size() / 2);
  fprintf(stdout, "User time (s): %f\n", time / 1e9);
  fprintf(stdout, "Real time (s): %f\n", time2 / 1e9);
}

int main(int argc, char **argv) {
  fprintf(stdout, "EventSize: %zu\n", sizeof(PPEvent));
  fprintf(stdout, "EventTySize: %zu\n", sizeof(PPEventType));

  PAPI_library_init(PAPI_VER_CURRENT);
  if (!PAPI_is_initialized()) {
    fprintf(stderr, "ERROR: libPAPI is not initialized\n");
  }
  papi_region_setup();
  papi_calibrate();
}
#endif
