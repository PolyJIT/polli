#include "pprof/pprof.h"
#include "pprof/file.h"

#include <ctime>
#include <stdlib.h>
#include <string>

#include <fstream>
#include <iostream>
#include <map>

namespace pprof {
static std::map<uint32_t, PPStringRegion> PPStrings;

struct FileOptions {
  std::string profile;
  std::string calls;
};

FileOptions getFileOptions() {
  FileOptions Opts;

  const char *profile = std::getenv("PPROF_FILE_PROFILE");
  const char *calls = std::getenv("PPROF_FILE_CALLS");

  Opts.profile = profile ? profile : "papi.profile.out";
  Opts.calls = calls ? calls : "papi.calls.out";

  return Opts;
}

namespace file {
void StoreRun(Run<PPEvent> &Events, const Options &opts) {
  using namespace std;

  if (!opts.use_file)
    return;

  FileOptions Opts = getFileOptions();
  ofstream out(Opts.profile, ios_base::out | ios_base::app);

  // Build global string table
  // const char *str;
  // for (auto &event : Events) {
  //  str = event.userString();
  //  if (!str)
  //    str = "UNDEF";
  //  switch (event.event()) {
  //  case ScopEnter:
  //  case RegionEnter:
  //    PPStrings[event->ID].Entry = str;
  //    break;
  //  case ScopExit:
  //  case RegionExit:
  //    PPStrings[event->ID].Exit = str;
  //    break;
  //  default:
  //    break;
  //  }

  //  PPStrings[event->ID].ID = event->ID;
  //}

  // Append String table
  for (auto &dbg : PPStrings)
    out << dbg.second;

  // Append Events
  for (auto &event : Events)
    out << event;

  out.flush();
  out.close();

  // Append calls to papi
  FILE *fp = fopen(Opts.calls.c_str(), "a+");
  if (fp) {
    fprintf(fp, "%zu\n", Events.size());
    fclose(fp);
  }
}

static bool ReadRun(std::unique_ptr<std::ifstream> &in, Run<PPEvent> &Events,
                    std::map<uint32_t, PPStringRegion> &Regions) {
  PPStringRegion StartR;

  *in >> StartR;
  assert((StartR.ID == 0) && "ERROR: StartRegion has ID != 0\n");

  PPStringRegion R;
  while ((*in >> R) && R.ID != 0)
    PPStrings[R.ID] = R;

  // Last region we read is an event.
  if (in->eof()) {
    std::cerr << "Reached EOF before finding a run.\n";
    return false;
  }

  Events.push_back(R);

  // Continue until we reach another run.
  PPEvent Ev;
  while (!in->eof() && (*in >> Ev) && Ev.id() != 0)
    Events.push_back(Ev);

  // Last event of a run is defined to have ID 0.
  Events.push_back(Ev);
  std::cout << "Completed reading a single run!\n";
  return true;
}

std::unique_ptr<ifstream> ifs;

bool ReadRun(Run<PPEvent> &Events, std::map<uint32_t, PPStringRegion> &Regions,
             const Options &opt) {
  FileOptions FileOpts = getFileOptions();
  bool gotValidRun = false;

  if (!ifs) {
    ifs = std::unique_ptr<std::ifstream>(
        new std::ifstream(FileOpts.profile, ios_base::in));
    std::cout << "Reading runs from: " << FileOpts.profile << "\n";
  }

  if (ifs) {
    Events.clear();
    gotValidRun = file::ReadRun(ifs, Events, Regions);

    if (!gotValidRun) {
      ifs->close();
      ifs.reset(nullptr);
    }
  }

  return gotValidRun;
}

} // namespace file
} // namespace pprof
