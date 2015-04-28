#include "pprof/pprof.h"
#include "pprof/csv.h"

#include <stdlib.h>
#include <string>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>

#include <sys/stat.h>
#include <map>
#include <fstream>
#include <iostream>

namespace pprof {
struct CsvOptions {
  std::string output;
};

CsvOptions getCSVoptions() {
  const char *csv = std::getenv("PPROF_CSV_FILE");
  CsvOptions Opts;
  Opts.output = csv ? csv : "papi.profile.events.csv";
  return Opts;
}

static std::string event2csv(const PPEvent &Ev, uint64_t TimeOffset,
                             const PPEvent &ExitEv,
                             uint32_t idx, uint32_t n) {
  using namespace fmt;
  return format("{:s}, {:s}, {:s}", (Ev.timestamp() - TimeOffset),
                Ev.userString(), (ExitEv.timestamp() - Ev.timestamp()));
}

static const Run<PPEvent>::iterator
getMatchingExit(Run<PPEvent>::iterator It,
                const Run<PPEvent>::iterator &End) {
  const PPEvent &Ev = *It;

  while (
      ((It->id() != Ev.id()) || ((It->event() != PPEventType::ScopExit) &&
                                 (It->event() != PPEventType::RegionExit))) &&
      (It != End)) {
    ++It;
  }

  return It;
}

namespace csv {
void StoreRun(Run<PPEvent> &Events, const Options &opts) {
  using namespace std;

  if (!opts.use_csv)
    return;

  CsvOptions csvOpts = getCSVoptions();

  std::map<uint32_t, std::pair<uint32_t, std::string>> IdMap;
  uint32_t idx = 0;
  for (const PPEvent &Event : Events) {
    if (!IdMap.count(Event.id())) {
      IdMap[Event.id()] = std::make_pair(idx++, Event.userString());
    }
  }

  Run<PPEvent>::iterator Start = Events.begin();

  struct stat buffer;
  bool writeHeader = stat(csvOpts.output.c_str(), &buffer) != 0;

  ofstream out(csvOpts.output, ios_base::out | ios_base::app);
  if (writeHeader)
    out << "StartTime,Region,Duration\n";

  for (Run<PPEvent>::iterator I = Events.begin(), IE = Events.end();
       I != IE; ++I) {
    switch (I->event()) {
    default:
      break;
    case ScopEnter:
    case RegionEnter:
      std::pair<uint32_t, std::string> Idx = IdMap[I->id()];
      out << event2csv(*I, Start->timestamp(), *getMatchingExit(I, IE),
                       Idx.first, IdMap.size()) << "\n";
      break;
    }
  }

  out.flush();
  out.close();
}
}
}
