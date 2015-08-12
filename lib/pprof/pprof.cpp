#include "pprof/pprof.h"

#include <fstream>
#include <sstream>
#include <iostream>
#include <memory>

#include <assert.h>
#include <stdlib.h>
#include <string>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>

namespace pprof {
Options getPprofOptionsFromEnv() {
  Options Opts;

  const char *exp = std::getenv("PPROF_EXPERIMENT");
  const char *prj = std::getenv("PPROF_PROJECT");
  const char *dom = std::getenv("PPROF_DOMAIN");
  const char *grp = std::getenv("PPROF_GROUP");
  const char *uri = std::getenv("PPROF_SRC_URI");
  const char *cmd = std::getenv("PPROF_CMD");
  const char *db = std::getenv("PPROF_USE_DATABASE");
  const char *csv = std::getenv("PPROF_USE_CSV");
  const char *file = std::getenv("PPROF_USE_FILE");
  const char *exec = std::getenv("PPROF_ENABLE");

  Opts.experiment = exp ? exp : "unknown";
  Opts.project = prj ? prj : "unknown";
  Opts.domain = dom ? dom : "unknown";
  Opts.group = grp ? grp : "unknown";
  Opts.src_uri = uri ? uri : "unknown";
  Opts.command = cmd ? cmd : "unknown";
  Opts.use_db = db ? (bool)stoi(db) : false;
  Opts.use_csv = csv ? (bool)stoi(csv) : false;
  Opts.use_file = file ? (bool)stoi(file) : true;
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
  using namespace fmt;
  return pprof::Event(Ev.id(), Ev.event(), Ev.timestamp() - TimeOffset,
                      ExitEv.timestamp() - Ev.timestamp(), Ev.userString());
}

const Run<PPEvent>::iterator
getMatchingExit(Run<PPEvent>::iterator It, const Run<PPEvent>::iterator &End) {
  using namespace fmt;
  const Run<PPEvent>::iterator Cur = It;

  while (It != End) {
    PPEventType T = It->event();
    if (It->id() == Cur->id()) {
      switch(Cur->event()) {
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

  //FIXME: Record an error event, this should not happen.
  assert("BUG: No matching Exit to this Entry");
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
