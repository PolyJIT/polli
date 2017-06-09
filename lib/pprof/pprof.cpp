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

  const char *exp = std::getenv("BB_EXPERIMENT");
  const char *prj = std::getenv("BB_PROJECT");
  const char *dom = std::getenv("BB_DOMAIN");
  const char *grp = std::getenv("BB_GROUP");
  const char *uri = std::getenv("BB_SRC_URI");
  const char *cmd = std::getenv("BB_CMD");
  const char *db = std::getenv("BB_USE_DATABASE");
  const char *csv = std::getenv("BB_USE_CSV");
  const char *file = std::getenv("BB_USE_FILE");
  const char *exec = std::getenv("BB_ENABLE");

  Opts.experiment = exp ? exp : "unknown";
  Opts.project = prj ? prj : "unknown";
  Opts.domain = dom ? dom : "unknown";
  Opts.group = grp ? grp : "unknown";
  Opts.src_uri = uri ? uri : "unknown";
  Opts.command = cmd ? cmd : "unknown";
  Opts.use_db = db ? (bool)stoi(db) : true;
  Opts.use_csv = csv ? (bool)stoi(csv) : false;
  Opts.use_file = file ? (bool)stoi(file) : false;
  Opts.execute_atexit = exec ? (bool)stoi(exec) : true;

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
  std::string entStr = R.Entry;
  if (entStr.size() == 0)
    entStr = "ERROR:Entry";
  std::string exStr = R.Exit;
  if (exStr.size() == 0)
    exStr = "ERROR:Exit";

  return os << R.ID << " " << entStr << " " << exStr << "\n";
}

std::istream &operator>>(std::istream &is, PPEvent &event) {
  uint16_t id;
  uint64_t timestamp;
  uint32_t type;

  ((is >> id) >> timestamp) >> type;
  event = PPEvent(id, (PPEventType)type, timestamp);

  return is;
}

std::istream &operator>>(std::istream &is, PPStringRegion &R) {
  uint32_t id;
  std::string entry;
  std::string exit;
  ((is >> id) >> entry) >> exit;

  R = PPStringRegion(id, entry, exit);
  return is;
}
