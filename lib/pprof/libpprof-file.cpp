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
void StoreRun(const std::vector<const PPEvent *> &Events, const Options &opts) {
  using namespace std;

  if (!opts.use_file)
    return;

  FileOptions Opts = getFileOptions();
  ofstream out(Opts.profile, ios_base::out | ios_base::app);

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

  // Append calls to papi
  FILE *fp = fopen(Opts.calls.c_str(), "a+");
  if (fp) {
    fprintf(fp, "%zu\n", Events.size());
    fclose(fp);
  }
}
}
}
