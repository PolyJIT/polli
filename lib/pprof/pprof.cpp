#include "pprof/pprof.h"

#include <fstream>
#include <sstream>
#include <iostream>
#include <memory>

#include <assert.h>

#include <string>

namespace pprof {
Options getPprofOptionsFromEnv() {
  Options Opts;

  const char *exp = std::getenv("PPROF_EXPERIMENT");
  const char *prj = std::getenv("PPROF_PROJECT");
  const char *cmd = std::getenv("PPROF_CMD");
  const char *db = std::getenv("PPROF_USE_DATABASE");
  const char *csv = std::getenv("PPROF_USE_CSV");
  const char *file = std::getenv("PPROF_USE_FILE");

  Opts.experiment = exp ? exp : "unknown";
  Opts.project = prj ? prj : "unknown";
  Opts.command = cmd ? cmd : "unknown";
  Opts.use_db = db ? (bool)stoi(db) : false;
  Opts.use_csv = csv ? (bool)stoi(csv) : false;
  Opts.use_file = file ? (bool)stoi(file) : true;

  return Opts;
}
}

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

 return os << R.ID << " " << entStr << " " << exStr << "\n";
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
  return is;
}
