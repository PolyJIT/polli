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

static std::map<uint32_t, PPStringRegion> PPStrings;

/**
 * @brief Storage container for all PAPI region events.
 */
static std::vector<const PPEvent *> PapiEvents;

static int argc;
static char **argv;
static std::string fileName = "papi.profile.out";
static std::string fileNameCallStack = "papi.calls.out";

void StoreRun(std::vector<const PPEvent *> &Events) {
  using namespace std;

  ofstream out(fileName, ios_base::out | ios_base::app);

  // Build global string table
  const char *str;
  for (auto &event : Events) {
    str = event->DebugStr;
    if (!str)
      str = "UNDEF";
    switch (event->EventTy) {
    case ScopEnter:
    case RegionEnter:
      PPStrings[event->ID].Entry = str;
      break;
    case ScopExit:
    case RegionExit:
      PPStrings[event->ID].Exit = str;
      break;
    default:
      break;
    }

    PPStrings[event->ID].ID = event->ID;
  }

  // Append String table
  for (auto &dbg : PPStrings)
    out << dbg.second << "\n";

  // Append Events
  for (auto &event : Events)
    out << event;

  out.flush();
  out.close();
}

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

static void papi_append_calls(void) {
  FILE *fp;

  fp = fopen(fileNameCallStack.c_str(), "a+");
  if (fp) {
    fprintf(fp, "%zu\n", PapiEvents.size());
    fclose(fp);
  }
}


void papi_atexit_handler(void) {
  PPEvent *ev = new PPEvent(0, RegionExit, "STOP");
  ev->snapshot();
  PapiEvents.push_back(ev);

  StoreRun(PapiEvents);

  for (auto evt : PapiEvents)
    delete evt;

  papi_append_calls();
  PAPI_shutdown();
}

void papi_region_setup(int _argc, char **_argv) {
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

  argc = _argc;
  argv = _argv;

  if (argv) {
    fileName = argv[0];
    fileNameCallStack = argv[0];

    fileName += ".profile.out";
    fileNameCallStack += ".calls";
  }

  int err = atexit(papi_atexit_handler);
  if (err)
    fprintf(stderr, "ERROR(PAPI-Prof): Failed to setup atexit handler (%d).\n",
            err);
}
};

#ifdef ENABLE_CALIBRATION
static long long papi_calib_cnt = 10000000;

void papi_calibrate(void) {
  long long time = PAPI_get_virt_nsec();
  long long time2 = PAPI_get_real_nsec();
  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(1, "a");
    papi_region_enter_scop(2, "b");
    papi_region_enter_scop(3, "c");
    papi_region_exit_scop(3, "c");
    papi_region_exit_scop(2, "b");
    papi_region_exit_scop(1, "a");
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
  papi_region_setup(argc, argv);
  papi_calibrate();
}
#endif
