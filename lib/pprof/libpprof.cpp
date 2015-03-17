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

static std::map<uint32_t, PPStringRegion> PPStrings;

/**
 * @brief Storage container for all PAPI region events.
 */
static std::vector<const PPEvent *> PapiEvents;

static int argc;
static char **argv;
static std::string fileName = "papi.profile.out";
static std::string fileNameCallStack = "papi.calls.out";
static std::string csvFileName = "papi.profile.events.csv";

static std::string event2csv(const PPEvent *Ev, uint64_t TimeOffset,
                             const PPEvent *ExitEv,
                             uint32_t idx, uint32_t n) {
  std::stringstream res;
  res << (Ev->Timestamp - TimeOffset) << "," << Ev->DebugStr << ","
      << (ExitEv->Timestamp - Ev->Timestamp);
  return res.str();
}

//static std::string event2csv(const PPEvent *Ev, uint64_t TimeOffset,
//                             const PPEvent *ExitEv,
//                             uint32_t idx, uint32_t n) {
//  std::stringstream res;
//  res << (Ev->Timestamp - TimeOffset);
//  for (uint32_t i = 0; i < n; i++) {
//    res << ",";
//    if (i == idx)
//      res << (ExitEv->Timestamp - Ev->Timestamp);
//    else
//      res << 0;
//  }
//  return res.str();
//}

typedef std::vector<const PPEvent *>::iterator EventItTy;
static const PPEvent *getMatchingExit(EventItTy &It, const EventItTy &End) {
  const PPEvent *Ev = (*It);
  const PPEvent *NextEvent = *(++It);
  if (Ev->EventTy != PPEventType::ScopEnter &&
      Ev->EventTy != PPEventType::RegionEnter) {
    std::cerr << "ERROR: " << Ev;
    return nullptr;
  }

  int i = 0;
  while (((NextEvent->ID != Ev->ID) ||
          ((NextEvent->EventTy != PPEventType::ScopExit) &&
           (NextEvent->EventTy != PPEventType::RegionExit))) &&
         (It != End)) {
    NextEvent = *(++It);
    if (!NextEvent)
      std::cerr << "NextEvent is a nullptr\n";

    i++;
  }

  if (It == End) {
    std::cerr << "ERROR: Iterator reached end\n";
    return nullptr;
  }

  for (int j = 0; j <= i; j++) { It--; }
  return NextEvent;
}

void StoreRunAsCSV(std::vector<const PPEvent *> &Events) {
  using namespace std;
  ofstream out(csvFileName, ios_base::out | ios_base::app);

  std::map<uint32_t, std::pair<uint32_t, const char *>> IdMap;
  uint32_t idx =0;
  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
    const PPEvent *Event = *I;
    if (!IdMap.count(Event->ID)) {
      IdMap[Event->ID] = std::make_pair(idx++, Event->DebugStr);
    }
  }

  EventItTy Start = Events.begin();

  out << "StartTime,Region,Duration\n";
  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
    const PPEvent *Event = *I;
    switch(Event->EventTy) {
    default:
      break;
    case ScopEnter:
    case RegionEnter:
      std::pair<uint32_t, const char *> Idx = IdMap[Event->ID];
      out << event2csv(Event, (*Start)->Timestamp,
                       getMatchingExit(I, IE), Idx.first, IdMap.size()) << "\n";
      break;
    }
  }

  out.flush();
  out.close();
}

//void StoreRunAsCSV(std::vector<const PPEvent *> &Events) {
//  using namespace std;
//  ofstream out(csvFileName, ios_base::out | ios_base::app);
//
//  std::map<uint32_t, std::pair<uint32_t, const char *>> IdMap;
//  uint32_t idx =0;
//  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
//    const PPEvent *Event = *I;
//    if (!IdMap.count(Event->ID)) {
//      IdMap[Event->ID] = std::make_pair(idx++, Event->DebugStr);
//    }
//  }
//
//  EventItTy Start = Events.begin();
//
//  out << "StartTime";
//  for (auto &p : IdMap) {
//    out << "," << p.second.second;
//  }
//  out << "\n";
//
//  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
//    const PPEvent *Event = *I;
//    switch(Event->EventTy) {
//    default:
//      break;
//    case ScopEnter:
//    case RegionEnter:
//      std::pair<uint32_t, const char *> Idx = IdMap[Event->ID];
//      out << event2csv(Event, (*Start)->Timestamp,
//                       getMatchingExit(I, IE), Idx.first, IdMap.size()) << "\n";
//      break;
//    }
//  }
//
//  out.flush();
//  out.close();
//}

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
  StoreRunAsCSV(PapiEvents);

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
    csvFileName = argv[0];

    fileName += ".profile.out";
    fileNameCallStack += ".calls";
    csvFileName += ".profile.events.csv";
  }

  int err = atexit(papi_atexit_handler);
  if (err)
    fprintf(stderr, "ERROR(PAPI-Prof): Failed to setup atexit handler (%d).\n",
            err);
}
};

#ifdef ENABLE_CALIBRATION
static long long papi_calib_cnt = 1000;
//static long long papi_calib_cnt = 1;

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

#include <getopt.h>
static void parse_command_line(int argc, char **argv) {
  // Set a default, if the user did not specify any command line options.
  if (argv) {
    fileName = argv[0];
    fileNameCallStack = argv[0];
    csvFileName = argv[0];

    fileName += ".profile.out";
    fileNameCallStack += ".calls";
    csvFileName += ".profile.events.csv";

  }

  static struct option options[] = {
    {"file", required_argument, 0, 'f'},
    {"calls", required_argument, 0, 'c'},
    {0, 0, 0, 0}
  };

  int opt_index = 0;
  int c;
  while ((c = getopt_long(argc, argv, "fc", options, &opt_index)) != -1) {
    switch (c) {
    case 'f':
      fileName = std::string(optarg);
      break;
    case 'c':
      fileNameCallStack = std::string(optarg);
      break;
    default:
      abort();
    }
  }
  printf("profile goes into: %s\n", fileName.c_str());
  printf("papi calls go into: %s\n", fileNameCallStack.c_str());
}

int main(int argc, char **argv) {
  parse_command_line(argc, argv);
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
