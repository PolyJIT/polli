#ifndef PPRINT_H
#define PPRINT_H
#include <inttypes.h>
#include <papi.h>

#include <fstream>
#include <iostream>

/**
 * @brief Setup papi for trace monitoring.
 */
void pprof_setup_papi();

/**
 * @brief PAPI Event to add to the tracking.
 *
 * @param PapiEventNum
 */
void pprof_trace_add_event(int PapiEventNum);

/**
 * @brief Mark the entry for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_entry(const std::string &TraceName);

/**
 * @brief Mark the exit for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_exit(const std::string &TraceName);

extern "C" {
/**
 * @brief Mark the entry of a SCoP
 *
 * @param id
 * @param dbg
 */
void papi_region_enter_scop(uint64_t id, const char *dbg);

/**
 * @brief Mark the exit of a SCoP
 *
 * @param id
 * @param dbg
 */
void papi_region_exit_scop(uint64_t id, const char *dbg);

/**
 * @brief Mark the entry of a Region
 *
 * @param id
 */
void papi_region_enter(uint64_t id);

/**
 * @brief Mark the exit of a Region
 *
 * @param id
 */
void papi_region_exit(uint64_t id);

/**
 * @brief Setup the atexit handler
 */
void papi_atexit_handler(void);

/**
 * @brief Initialize papi and output filenames.
 *
 * @param _argc
 * @param _argv
 */
void papi_region_setup(int _argc, char **_argv);
}

enum PPEventType { ScopEnter, ScopExit, RegionEnter, RegionExit };

struct PPStringRegion {
  PPStringRegion(std::pair<uint32_t, std::pair<const char *, const char *>>) {}
  PPStringRegion() {}

  uint32_t ID;
  std::string Entry;
  std::string Exit;
};

struct PPEvent {
  PPEvent(uint64_t id, PPEventType evTy, const char *dbgStr = "")
      : ID(id), EventTy(evTy), DebugStr(dbgStr) {
    Timestamp = -1;
  };

  PPEvent(PPStringRegion &R) {
    ID = R.ID;
    Timestamp = std::stoll(R.Entry);
    EventTy = (PPEventType)std::stoi(R.Exit);
  }

  PPEvent(){};

  uint32_t ID;
  PPEventType EventTy;
  uint64_t Timestamp;
  const char *DebugStr;

  void snapshot() { Timestamp = PAPI_get_virt_nsec(); }
};

using namespace std;

std::ostream &operator<<(std::ostream &os, const PPEvent &event) {
  return os << event.ID << " " << event.Timestamp << " " << event.EventTy
            << "\n";
}

std::ostream &operator<<(std::ostream &os, const PPEvent *event) {
  return os << event->ID << " " << event->Timestamp << " " << event->EventTy
            << "\n";
}

std::ostream &operator<<(std::ostream &os, const PPStringRegion &R) {
  std::string entStr = R.Entry;
  if (entStr.size() == 0)
    entStr = "ERROR:Entry";
  std::string exStr = R.Exit;
  if (exStr.size() == 0)
    exStr = "ERROR:Exit";

  return os << R.ID << " " << entStr << " " << exStr;
}

std::istream &operator>>(std::istream &is, PPEvent &event) {
  int EventTy;
  is >> event.ID;
  is >> event.Timestamp;
  is >> EventTy;

  event.EventTy = (PPEventType)EventTy;
  return is;
}

std::istream &operator>>(std::istream &is, PPStringRegion &R) {
  is >> R.ID >> R.Entry >> R.Exit;
  return is.ignore(1, '\n');
}
#endif
