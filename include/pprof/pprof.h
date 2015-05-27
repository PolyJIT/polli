#ifndef PPRINT_H
#define PPRINT_H
#include <inttypes.h>
#include <papi.h>

#include <assert.h>
#include <memory>
#include <vector>
#include <string>

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
  ScopEnter = 0,
  ScopExit = 1,
  RegionEnter = 2,
  RegionExit = 3,
  TraceEnter = 4,
  TraceExit = 5,
  Unknown = 6,
};

struct PPStringRegion {
  PPStringRegion(uint32_t ID, std::string Entry, std::string Exit)
      : Entry(Entry), Exit(Exit) {}
  PPStringRegion() {}

  uint32_t ID;
  std::string Entry;
  std::string Exit;
};

class PPEvent {
public:
  PPEvent(uint64_t ID = 0, PPEventType Ty = Unknown, const char *dbgStr = "")
      : ID(ID), EventTy(Ty), Timestamp(PAPI_get_real_nsec()), DebugStr(dbgStr) {
  }
  explicit PPEvent(uint64_t ID, PPEventType Ty, long long int Timestamp,
                   const char *dbgStr = "")
      : ID(ID), EventTy(Ty), Timestamp(Timestamp), DebugStr(dbgStr) {}

  // Conversion from String Region.
  PPEvent(const PPStringRegion &R) {
    ID = R.ID;
    Timestamp = std::stoll(R.Entry);
    EventTy = (PPEventType)std::stoi(R.Exit);
  }

  uint32_t id() const { return ID; }
  PPEventType event() const { return EventTy; }
  long long int timestamp() const { return Timestamp; }
  std::string userString() const { return DebugStr; }

  /**
   * @brief Set the timestamp of this event to 'right now'
   */
  void snapshot() { Timestamp = PAPI_get_real_nsec(); }
private:
  uint32_t ID;
  PPEventType EventTy;
  long long int Timestamp;
  std::string DebugStr;
};

namespace pprof {
template<typename T>
class Run : public std::vector<T> {
  typedef std::vector<T> vector;
public:
  Run(long ID = -1, size_t Size = 1024) : std::vector<T>(Size), ID(ID) {}

  using vector::begin;
  using vector::end;
  using vector::pop_back;
  using vector::push_back;
  using vector::size;
  using vector::back;
  using vector::clear;
  using vector::operator[];

  long ID;
};

struct Options {
  std::string experiment;
  std::string project;
  std::string domain;
  std::string group;
  std::string src_uri;
  std::string command;
  bool use_db;
  bool use_csv;
  bool use_file;
  bool execute_atexit;
};

Options *getOptions();
Options getPprofOptionsFromEnv();
} // end of namespace pprof

#include <iostream>
using namespace std;
std::ostream &operator<<(std::ostream &os, const PPEvent &event);
std::ostream &operator<<(std::ostream &os, const PPStringRegion &R);
std::istream &operator>>(std::istream &is, PPEvent &event);
std::istream &operator>>(std::istream &is, PPStringRegion &R);
#endif
