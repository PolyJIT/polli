#include "pprof/pprof.h"
#include "pprof/file.h"
#include "pprof/pgsql.h"

#include "llvm/Support/CommandLine.h"

#include <string>
#include <vector>
#include <map>

#include <fstream>
#include <iostream>
#include <algorithm>
#include <numeric>

#include <stdexcept>
#include <memory>
#include <assert.h>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>

using namespace llvm;
using namespace fmt;

static std::map<uint32_t, uint64_t> PPDurations;

static uint64_t getTimeInSCoPs(const pprof::Run<PPEvent> &Events) {
  std::vector<int64_t> s(Events.size() + 1);
  std::vector<int64_t> ts(Events.size() + 1);
  std::vector<int64_t> evs;

  uint64_t sum = std::accumulate(Events.begin(), Events.end(), (int64_t)0,
                                 [&](int64_t x, const PPEvent &y) -> int64_t {
    int64_t newx = x;
    if (y.event() == ScopEnter) {
      // Start with 0 in newx, track the start time in ts and reserve a slot
      // in s for our subregions.
      ts.push_back(-y.timestamp());
      s.push_back(0);
      evs.push_back(y.id());
    }

    if (y.event() == ScopExit) {
      // if we trigger this, we found a bug in the instrumentation.
      while (evs.size() > 1 && evs.back() != y.id())
        evs.pop_back();

      if (evs.size() > 0 && evs.back() == y.id()) {
        evs.pop_back();

        int64_t fullDur = ts.back() + y.timestamp();
        int64_t exclusiveDur = fullDur - s.back();

        s.pop_back();
        ts.pop_back();

        s.back() += fullDur;

        // We accumulate only the exclusive Duration.
        newx += exclusiveDur;
        PPDurations[y.id()] += exclusiveDur;
      }
    }

    // Do nothing.
    return newx;
  });

  return sum;
}

static inline uint64_t
getTotalTimeInProgram(const pprof::Run<PPEvent> &Events) {
  return std::accumulate(Events.begin(), Events.end(), (uint64_t)0,
                         [](int64_t x, const PPEvent &y) -> int64_t {
                           int64_t newx = x;
                           if (y.id() == 0) {
                             if (y.event() == RegionEnter)
                               newx -= y.timestamp();

                             if (y.event() == RegionExit)
                               newx += y.timestamp();
                           }
                           // Do nothing.
                           return newx;
                         });
}

using Metrics = std::map<std::string, double>;

static void PrintStats(std::ostream &os, Metrics &M,
                       const std::map<uint32_t, PPStringRegion> &Regions) {
  //os << "The following regions have been executed in all runs:\n\n";
  //for (auto &R : Regions) {
  //  double t_region_ns = (double)PPDurations[R.first];
  //  double pct_region_dyncov = t_region_ns / t_total_ns * 100;
  //  os << R.second << " " << t_region_ns << " " << pct_region_dyncov << "\n";
  //}

  for (auto v : M)
    os << fmt::format("{:<s} - {:>f}\n", v.first, v.second);
}

static void PrintStats(std::ostream &os, Metrics &M) {
  for (auto v : M)
    os << fmt::format("{:<s} - {:>f}\n", v.first, v.second);
}

namespace pprof {
std::string PPROF_TIME_SCOPS_NS = "pprof.time.scops_ns";
std::string PPROF_TIME_TOTAL_NS = "pprof.time.total_ns";
std::string PPROF_TIME_SCOPS_S = "pprof.time.scops_s";
std::string PPROF_TIME_TOTAL_S = "pprof.time.total_s";
std::string PPROF_DYNCOV = "pprof.dyncov";
std::string PPROF_RUN = "pprof.run";

static pprof::Run<PPEvent>
SanitizeRun(pprof::Run<PPEvent> &Events) {
  if (!(Events.size() > 0))
    return Events;

  PPEvent Past;
  if (Events.size() > 0)
    Past = Events[0];

  pprof::Run<PPEvent> ValidEvents(Events.ID);

  ValidEvents.clear();
  for (size_t i = 0; i < Events.size(); i++) {
    const PPEvent Ev = Events[i];
    if (i == 0) {

      long long past = Past.timestamp();
      long long future = Ev.timestamp();

      if (past <= future)
        ValidEvents.push_back(Ev);
      else
        std::cout << "invalid: " << past << " > " << future << "\n"
                  << "PastEv: " << Past << " CurEv:: " << Ev << "\n";
    } else {
      ValidEvents.push_back(Ev);
    }

    Past = Ev;
  }

  size_t InvalidCnt = Events.size() - ValidEvents.size();
  if (InvalidCnt > 0)
    std::cout << Events.size() - ValidEvents.size() << " events are invalid.\n";
  return ValidEvents;
}

static Metrics FinalizeStats(Metrics M) {
  double t_scops_ns = M[PPROF_TIME_SCOPS_NS];
  double t_total_ns = M[PPROF_TIME_TOTAL_NS];

  double t_scops_s = t_scops_ns / 1e9;
  double t_total_s = t_total_ns / 1e9;
  double pct_dyncov = t_scops_ns / t_total_ns * 100.0;

  M[PPROF_TIME_SCOPS_S] = t_scops_s;
  M[PPROF_TIME_TOTAL_S] = t_total_s;
  M[PPROF_DYNCOV] = pct_dyncov;

  return M;
}

static void aggregate(Metrics &From, Metrics &Into) {
  Into[PPROF_TIME_SCOPS_NS] += From[PPROF_TIME_SCOPS_NS];
  Into[PPROF_TIME_TOTAL_NS] += From[PPROF_TIME_TOTAL_NS];
  Into[PPROF_TIME_SCOPS_S] = Into[PPROF_TIME_SCOPS_NS] / 1e9;
  Into[PPROF_TIME_TOTAL_S] = Into[PPROF_TIME_TOTAL_NS] / 1e9;
  Into[PPROF_DYNCOV] =
      Into[PPROF_TIME_SCOPS_NS] / Into[PPROF_TIME_TOTAL_NS] * 100.0;
  Into[PPROF_RUN] += 1;
}

static Metrics GetMetrics(Run<PPEvent> Run) {
  Metrics M;

  double t_scops_ns = getTimeInSCoPs(Run);
  double t_total_ns = getTotalTimeInProgram(Run);
  double t_scops_s = t_scops_ns / 1e9;
  double t_total_s = t_total_ns / 1e9;
  double pct_dyncov = t_scops_ns / t_total_ns * 100.0;

  M[PPROF_TIME_SCOPS_NS] = t_scops_ns;
  M[PPROF_TIME_TOTAL_NS] = t_total_ns;
  M[PPROF_TIME_SCOPS_S] = t_scops_s;
  M[PPROF_TIME_TOTAL_S] = t_total_s;
  M[PPROF_DYNCOV] = pct_dyncov;

  return M;
}

namespace file {
static int main(const Options Opts) {
  Run<PPEvent> SingleRun;
  std::map<uint32_t, PPStringRegion> Regions;
  Metrics M;

  std::cout << "Using RAW file backend\n";
  while (ReadRun(SingleRun, Regions, Opts)) {
    Metrics RunM = GetMetrics(SanitizeRun(SingleRun));
    aggregate(RunM, M);
    SingleRun.clear();
  }

  M = FinalizeStats(M);
  PrintStats(std::cout, M, Regions);
  return 0;
}
}

namespace pgsql {
static int main(const Options Opts) {
  using namespace fmt;
  std::cout << "Using Postgres DB backend\n";
  using RunRegions = std::map<uint32_t, PPStringRegion>;

  for (std::string run_group : ReadAvailableRunGroups()) {
    Metrics M;
    M.clear();

    std::cout << fmt::format("Working on run_group: {:s}\n", run_group);
    for (uint32_t run_id : ReadAvailableRunIDs(run_group)) {
      RunRegions Regions;
      Run<PPEvent> SingleRun = pgsql::ReadRun(run_id, Regions);
      Metrics RunM = GetMetrics(SanitizeRun(SingleRun));
      aggregate(RunM, M);
      StoreRunMetrics(SingleRun.ID, RunM);
      SingleRun.clear();
    }
    M = FinalizeStats(M);
    PrintStats(std::cout, M);
  }

  return 0;
}
}
}

int main(int argc, const char **argv) {
  using namespace pprof;
  pprof::Options Opts = pprof::getPprofOptionsFromEnv();
  if (Opts.use_db) {
    return pgsql::main(Opts);
  }

  if (Opts.use_file) {
    return file::main(Opts);
  }

  if (Opts.use_csv) {
    std::cout << "Using CSV file backend\n";
    std::cout << "Not implemented!\n";
    exit(1);
  }

}
