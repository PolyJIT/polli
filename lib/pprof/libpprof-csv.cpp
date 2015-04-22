#include "pprof/pprof.h"
#include "pprof/csv.h"

#include <stdlib.h>
#include <string>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>

#include <sys/stat.h>
#include <map>

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

static std::string event2csv(const PPEvent *Ev, uint64_t TimeOffset,
                             const PPEvent *ExitEv,
                             uint32_t idx, uint32_t n) {
  std::stringstream res;
  res << (Ev->Timestamp - TimeOffset) << "," << Ev->DebugStr << ","
      << (ExitEv->Timestamp - Ev->Timestamp);
  return res.str();
}

typedef std::vector<const PPEvent *>::iterator EventItTy;
static const PPEvent *getMatchingExit(EventItTy &It, const EventItTy &End) {
  const PPEvent *Ev = (*It);
  const PPEvent *NextEvent = *(++It);
  if (Ev->EventTy != PPEventType::ScopEnter &&
      Ev->EventTy != PPEventType::RegionEnter) {
    std::cerr << "ERROR: " << Ev;
    return nullptr;
  }

  int i = 0;
  while (((NextEvent->ID != Ev->ID) ||
          ((NextEvent->EventTy != PPEventType::ScopExit) &&
           (NextEvent->EventTy != PPEventType::RegionExit))) &&
         (It != End)) {
    NextEvent = *(++It);
    if (!NextEvent)
      std::cerr << "NextEvent is a nullptr\n";

    i++;
  }

  if (It == End) {
    std::cerr << "ERROR: Iterator reached end\n";
    return nullptr;
  }

  for (int j = 0; j <= i; j++) { It--; }
  return NextEvent;
}

namespace csv {
void StoreRun(std::vector<const PPEvent *> &Events, const Options &opts) {
  using namespace std;

  if (!opts.use_csv)
    return;

  CsvOptions csvOpts = getCSVoptions();

  std::map<uint32_t, std::pair<uint32_t, const char *>> IdMap;
  uint32_t idx = 0;
  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
    const PPEvent *Event = *I;
    if (!IdMap.count(Event->ID)) {
      IdMap[Event->ID] = std::make_pair(idx++, Event->DebugStr);
    }
  }

  EventItTy Start = Events.begin();

  struct stat buffer;
  bool writeHeader = stat(csvOpts.output.c_str(), &buffer) != 0;

  ofstream out(csvOpts.output, ios_base::out | ios_base::app);
  if (writeHeader)
    out << "StartTime,Region,Duration\n";

  for (EventItTy I = Events.begin(), IE = Events.end(); I != IE; ++I) {
    const PPEvent *Event = *I;
    switch (Event->EventTy) {
    default:
      break;
    case ScopEnter:
    case RegionEnter:
      std::pair<uint32_t, const char *> Idx = IdMap[Event->ID];
      out << event2csv(Event, (*Start)->Timestamp, getMatchingExit(I, IE),
                       Idx.first, IdMap.size()) << "\n";
      break;
    }
  }

  out.flush();
  out.close();
}
}
}
