#ifndef PPRINT_H
#define PPRINT_H
#include <inttypes.h>
#include <papi.h>

#include <fstream>
#include <sstream>
#include <iostream>
#include <memory>

#include <assert.h>

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
void papi_region_setup();
}

enum PPEventType {
  ScopEnter,
  ScopExit,
  RegionEnter,
  RegionExit,
  TraceEnter,
  TraceExit
};

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

namespace pprof {
struct Options {
  std::string experiment;
  std::string project;
  std::string command;
  bool        use_db;
  bool        use_csv;
  bool        use_file;
};
}

using namespace std;

std::ostream &operator<<(std::ostream &os, const PPEvent &event);
std::ostream &operator<<(std::ostream &os, const PPEvent *event);
std::ostream &operator<<(std::ostream &os, const PPStringRegion &R);
std::istream &operator>>(std::istream &is, PPEvent &event);
std::istream &operator>>(std::istream &is, PPStringRegion &R);
#endif
