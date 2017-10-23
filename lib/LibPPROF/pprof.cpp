#include "pprof/pprof.h"

#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>

#include <assert.h>
#include <stdlib.h>
#include <string>

namespace pprof {
Options getPprofOptionsFromEnv() {
  Options Opts;

  const char *Exp = std::getenv("BB_EXPERIMENT");
  const char *Prj = std::getenv("BB_PROJECT");
  const char *Dom = std::getenv("BB_DOMAIN");
  const char *Grp = std::getenv("BB_GROUP");
  const char *Uri = std::getenv("BB_SRC_URI");
  const char *Cmd = std::getenv("BB_CMD");
  const char *Db = std::getenv("BB_USE_DATABASE");
  const char *Csv = std::getenv("BB_USE_CSV");
  const char *File = std::getenv("BB_USE_FILE");
  const char *Exec = std::getenv("BB_ENABLE");

  Opts.experiment = Exp ? Exp : "unknown";
  Opts.project = Prj ? Prj : "unknown";
  Opts.domain = Dom ? Dom : "unknown";
  Opts.group = Grp ? Grp : "unknown";
  Opts.src_uri = Uri ? Uri : "unknown";
  Opts.command = Cmd ? Cmd : "unknown";
  Opts.use_db = Db ? (bool)stoi(Db) : true;
  Opts.use_csv = Csv ? (bool)stoi(Csv) : false;
  Opts.use_file = File ? (bool)stoi(File) : false;
  Opts.execute_atexit = Exec ? (bool)stoi(Exec) : true;

  return Opts;
}

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
const pprof::Event simplify(const PPEvent &Ev, const PPEvent &ExitEv,
                            uint64_t TimeOffset) {
  return pprof::Event(Ev.id(), Ev.event(), Ev.timestamp() - TimeOffset,
                      ExitEv.timestamp() - Ev.timestamp(), Ev.userString());
}

const Run<PPEvent>::iterator
getMatchingExit(Run<PPEvent>::iterator It, const Run<PPEvent>::iterator &End) {
  const Run<PPEvent>::iterator Cur = It;

  while (It != End) {
    PPEventType T = It->event();
    if (It->id() == Cur->id()) {
      switch (Cur->event()) {
      case RegionEnter:
        if (T == RegionExit) {
          return It;
        }
        break;
      case ScopEnter:
        if (T == ScopExit) {
          return It;
        }
        break;
      default:
        break;
      }
    }
    ++It;
  }

  // FIXME: Record an error event, this should not happen.
  static_assert("BUG: No matching Exit to this Entry", "");
  return Cur;
}
} // namespace pprof

std::ostream &operator<<(std::ostream &os, const PPEvent &event) {
  return os << event.id() << " " << event.timestamp() << " " << event.event()
            << "\n";
}

std::ostream &operator<<(std::ostream &os, const PPStringRegion &R) {
  std::string EntStr = R.Entry;
  if (EntStr.size() == 0)
    EntStr = "ERROR:Entry";
  std::string ExStr = R.Exit;
  if (ExStr.size() == 0)
    ExStr = "ERROR:Exit";

  return os << R.ID << " " << EntStr << " " << ExStr << "\n";
}

std::istream &operator>>(std::istream &is, PPEvent &event) {
  uint16_t Id;
  uint64_t Timestamp;
  uint32_t Type;

  ((is >> Id) >> Timestamp) >> Type;
  event = PPEvent(Id, (PPEventType)Type, Timestamp);

  return is;
}

std::istream &operator>>(std::istream &is, PPStringRegion &R) {
  uint32_t Id;
  std::string Entry;
  std::string Exit;
  ((is >> Id) >> Entry) >> Exit;

  R = PPStringRegion(Id, Entry, Exit);
  return is;
}
