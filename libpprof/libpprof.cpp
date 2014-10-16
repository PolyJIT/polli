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

/**
 * @brief Store experimental results in traces
 *
 * A trace is a named event list.
 */
class TraceStorage {
public:
  typedef std::unique_ptr<PPEvent> PPEventPtr;
  typedef std::vector<PPEventPtr> PPEventPtrs;
  typedef std::map<const std::string, PPEventPtrs> TraceRegions;
private:
  TraceRegions Log;
public:
  /**
   * @brief Store the all traces.
   *
   * @param Trace
   * @param Ptr
   */
  void save(const std::string &Trace, PPEventPtr &Ptr) {}

  /**
   * @brief Load an trace storage from file
   *
   * @param FileName
   */
  void load(std::string FileName) {
  }
};

/**
 * @brief The currently executed PAPI event set.
 */
int EventSet = PAPI_NULL;
int EventSetSize = 0;

/**
 * @brief Setup papi for trace monitoring.
 */
void pprof_setup_papi() {
  int status = PAPI_is_initialized();

  if (status != PAPI_LOW_LEVEL_INITED) {
    status = PAPI_library_init(PAPI_VER_CURRENT);
    if (status != PAPI_VER_CURRENT & status > 0) {
      fprintf(stderr, "PPROF: PAPI_library_init: Version mismatch\n");
      std::exit(status);
    }
  }

  if (PAPI_create_eventset(&EventSet) != PAPI_OK) {
    fprintf(stderr, "PPROF: Could not create an empty event set\n");
    std::exit(1);
  }
}

void pprof_trace_add_event(char *Name) {
  if (PAPI_is_initialized() != PAPI_LOW_LEVEL_INITED)
    pprof_setup_papi();

  int NativeEv = 0x0;
  if (PAPI_event_name_to_code(Name, &NativeEv) != PAPI_OK) {
    fprintf(stderr, "PPROF: Could not get the event code for this name\n");
    std::exit(1);
  }

  pprof_trace_add_event(NativeEv);
}

void pprof_trace_add_event(int PapiEventNum) {
  if (PAPI_is_initialized() != PAPI_LOW_LEVEL_INITED)
    pprof_setup_papi();

  if (PAPI_add_event(EventSet, PapiEventNum) != PAPI_OK) {
    fprintf(stderr,
            "PPROF: Could not add the requested event code to the set\n");
    std::exit(1);
  }

  ++EventSetSize;
}

/**
 * @brief Mark the entry for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_entry(const std::string &TraceName) {

}

/**
 * @brief Mark the exit for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_exit(const std::string &TraceName) {

}

static void papi_append_calls(void) {
  FILE *fp;

  fp = fopen(fileNameCallStack.c_str(), "a+");
  if (fp) {
    fprintf(fp, "%zu\n", PapiEvents.size());
    fclose(fp);
  }
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

  fprintf(stderr, "User time per call (ns): %f\n", avg);
  fprintf(stderr, "Real time per call (ns): %f\n", avg2);
  fprintf(stderr, "PAPI-stack calls: %lu\n", PapiEvents.size() / 2);
  fprintf(stderr, "User time (s): %f\n", time / 1e9);
  fprintf(stderr, "Real time (s): %f\n", time2 / 1e9);
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
