#include "pprof/pprof.h"
#include "pprof/file.h"

#include <ctime>
#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <map>
#include <string>

namespace pprof {
static std::map<uint32_t, PPStringRegion> PPStrings;

struct FileOptions {
  std::string profile;
  std::string calls;
};

FileOptions getFileOptions() {
  FileOptions Opts;

  const char *Profile = std::getenv("PPROF_FILE_PROFILE");
  const char *Calls = std::getenv("PPROF_FILE_CALLS");

  Opts.profile = Profile ? Profile : "papi.profile.out";
  Opts.calls = Calls ? Calls : "papi.calls.out";

  return Opts;
}

namespace file {
void StoreRun(Run<PPEvent> &Events, const Options &opts) {
  using namespace std;

  if (!opts.use_file)
    return;

  FileOptions Opts = getFileOptions();
  ofstream Out(Opts.profile, ios_base::out | ios_base::app);

  // Append Events
  for (auto &Event : Events)
    Out << Event;

  Out.flush();
  Out.close();

  // Append calls to papi
  FILE *Fp = fopen(Opts.calls.c_str(), "a+");
  if (Fp) {
    fprintf(Fp, "%zu\n", Events.size());
    fclose(Fp);
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

std::unique_ptr<std::ifstream> Ifs;

bool ReadRun(Run<PPEvent> &Events, std::map<uint32_t, PPStringRegion> &Regions,
             const Options &opt) {
  FileOptions FileOpts = getFileOptions();
  bool GotValidRun = false;

  if (!Ifs) {
    Ifs = std::unique_ptr<std::ifstream>(
        new std::ifstream(FileOpts.profile, std::ios_base::in));
    std::cout << "Reading runs from: " << FileOpts.profile << "\n";
  }

  if (Ifs) {
    Events.clear();
    GotValidRun = file::ReadRun(Ifs, Events, Regions);

    if (!GotValidRun) {
      Ifs->close();
      Ifs.reset(nullptr);
    }
  }

  return GotValidRun;
}

} // namespace file
} // namespace pprof
