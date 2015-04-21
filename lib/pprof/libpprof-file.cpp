#include "pprof/file.h"
#include "pprof/pprof.h"

#include <ctime>
#include <stdlib.h>
#include <string>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>

#include <map>

namespace pprof {
static std::map<uint32_t, PPStringRegion> PPStrings;

struct PprofOptions {
  std::string experiment;
  std::string project;
  std::string command;
  bool use_db;
};

PprofOptions getPprofOptionsFromEnv() {
  PprofOptions Opts;

  const char *exp = std::getenv("PPROF_EXPERIMENT");
  const char *prj = std::getenv("PPROF_PROJECT");
  const char *cmd = std::getenv("PPROF_CMD");
  const char *db = std::getenv("PPROF_USE_DATABASE");

  Opts.experiment = exp ? exp : "unknown";
  Opts.project = prj ? prj : "unknown";
  Opts.command = cmd ? cmd : "unknwon";
  Opts.use_db = db ? (bool)stoi(db) : false;

  return Opts;
}
void StoreRun(const std::vector<const PPEvent *> &Events) {
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
}
