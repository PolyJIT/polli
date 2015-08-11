#ifndef PPRINT_H
#define PPRINT_H
#include <inttypes.h>
#include <papi.h>
#include <pthread.h>

#include <assert.h>
#include <memory>
#include <vector>
#include <string>

extern "C" {
/**
  * @brief Mark the entry of a SCoP.
  *
  * The Entry gets assigned to the matching event-chain in memory.
  *
  * @param id A unique ID identifying the SCoP.
  * @param dbg An optional name for the SCoP.
  * @return void
  */
void papi_region_enter_scop(uint64_t id, const char *dbg);

/**
 * @brief Mark the exit of a SCoP
 *
 * @param id An unique ID that identifies the SCoP.
 * @param dbg An optional name for the SCoP.
 * @return void
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
template <typename T> class Run : public std::vector<T> {
  typedef std::vector<T> vector;

public:
  Run(long ID = -1, size_t Size = 0) : std::vector<T>(Size), ID(ID) {}

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

struct Event {
  uint32_t ID;
  PPEventType Type;
  uint64_t Start;
  uint64_t Duration;
  std::string Name;
  pthread_t TID;

  Event(uint32_t ID = 0, PPEventType T = Unknown, uint64_t S = 0,
        uint64_t D = 0, std::string N = "", uint64_t TID = pthread_self())
      : ID(ID), Type(T), Start(S), Duration(D), Name(N), TID(TID) {}
};

/**
 * @brief Combines 2 profiling events into one.
 *
 * Profiling events have the format:
 *  {ID} {Type} {Timestamp}
 * After combining 2 matching events the result has the form:
 *  {ID} {StartTime} {Duration}
 *
 * @param Ev The Entry event to simplify.
 * @param ExitEv The Exit event to simplify.
 * @param TimeOffset An offset to subtract from the timings.
 * @return pprof::Event
 */
const Event simplify(const PPEvent &Ev, const PPEvent &ExitEv,
                     uint64_t TimeOffset);
/**
 * @brief Get the exit event that matches this iterator.
 *
 * If we can't find a matching exit, we just return the end.
 *
 * @param It The iterator position we seek a matching exit event to.
 * @param End The end.
 * @return const Run< PPEvent >::iterator
 */
const Run<PPEvent>::iterator getMatchingExit(Run<PPEvent>::iterator It,
                                             const Run<PPEvent>::iterator &End);

/**
 * @brief Storage container for all PAPI region events.
 */
extern Run<PPEvent> PapiEvents;

} // end of namespace pprof

#include <iostream>
using namespace std;
std::ostream &operator<<(std::ostream &os, const PPEvent &event);
std::ostream &operator<<(std::ostream &os, const PPStringRegion &R);
std::istream &operator>>(std::istream &is, PPEvent &event);
std::istream &operator>>(std::istream &is, PPStringRegion &R);
#endif
