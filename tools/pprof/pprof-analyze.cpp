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

using namespace llvm;

static std::map<uint32_t, uint64_t> PPDurations;

uint64_t getTimeInSCoPs(std::vector<const PPEvent *> &Events, ostream &os) {
  std::vector<int64_t> s(Events.size() + 1);
  std::vector<int64_t> ts(Events.size() + 1);
  std::vector<int64_t> evs;

  uint64_t sum = std::accumulate(Events.begin(), Events.end(), (int64_t)0,
                                 [&](int64_t x, const PPEvent *y) -> int64_t {
    int64_t newx = x;
    if (y->EventTy == ScopEnter) {
      // Start with 0 in newx, track the start time in ts and reserve a slot
      // in s for our subregions.
      ts.push_back(-y->Timestamp);
      s.push_back(0);
      evs.push_back(y->ID);
    }

    if (y->EventTy == ScopExit) {
      // if we trigger this, we found a bug in the instrumentation.
      while (evs.size() > 1 && evs.back() != y->ID)
        evs.pop_back();

      if (evs.size() > 0 && evs.back() == y->ID) {
        evs.pop_back();

        int64_t fullDur = ts.back() + y->Timestamp;
        int64_t exclusiveDur = fullDur - s.back();

        s.pop_back();
        ts.pop_back();

        s.back() += fullDur;

        // We accumulate only the exclusive Duration.
        newx += exclusiveDur;
        PPDurations[y->ID] += exclusiveDur;
      }
    }

    // Do nothing.
    return newx;
  });

  return sum;
}

uint64_t getTotalTimeInProgram(std::vector<const PPEvent *> &Events,
                               ostream &os) {
  return std::accumulate(Events.begin(), Events.end(), (uint64_t)0,
                         [&os](int64_t x, const PPEvent *y) -> int64_t {
    int64_t newx = x;
    if (y->ID == 0) {
      if (y->EventTy == RegionEnter)
        newx -= y->Timestamp;

      if (y->EventTy == RegionExit)
        newx += y->Timestamp;
    }
    // Do nothing.
    return newx;
  });
}

static void PrintStats(std::ostream &os, const pprof::Metrics &M,
                       const std::map<uint32_t, PPStringRegion> &Regions) {
  double timeInSCoPs_s = M.TimeInSCoPs_ns.Val / 1e9;
  double totalTime_s = M.TotalTime_ns.Val / 1e9;
  double dynCov = M.TimeInSCoPs_ns.Val / (double)M.TotalTime_ns.Val * 100;

  os << "The following regions have been executed in all runs:\n\n";
  for (auto &R : Regions) {
    uint64_t duration = PPDurations[R.first];
    double singleDynCov = duration / (double)M.TotalTime_ns.Val * 100;
    os << R.second << " " << duration << " " << singleDynCov << "\n";
  }
  os << "\nTotal number of program runs - " << M.Runs.Val << "\n";
  os << "Time Spent in SCoPs [ns] - " << M.TimeInSCoPs_ns.Val << "\n";
  os << "Time Spent in SCoPs [s] - " << timeInSCoPs_s << "\n";
  os << "Total run-time [ns] - " << M.TotalTime_ns.Val << "\n";
  os << "Total run-time [s] - " << totalTime_s << "\n";
  os << "Dynamic SCoP coverage - " << dynCov << "\n";
}

static std::vector<const PPEvent *>
SanitizeRun(std::vector<const PPEvent *> &Events) {
  const PPEvent *Past = nullptr;
  std::vector<const PPEvent *> ValidEvents;

  std::cout << "Sanitizing run...\n";
  for (const PPEvent *Ev : Events) {
    if (Past) {
      long long past = Past->Timestamp;
      long long future = Ev->Timestamp;

      if (past < future)
        ValidEvents.push_back(Ev);
      else
        std::cout << "invalid: " << past << " > " << future << "\n"
                  << "PastEv: " << *Past << " CurEv:: " << *Ev << "\n";
    } else {
      ValidEvents.push_back(Ev);
    }

    Past = Ev;
  }

  std::cout << Events.size() - ValidEvents.size() << " events are invalid.\n";
  return ValidEvents;
}

namespace pprof {
static void GenerateStats(std::vector<const PPEvent *> &Events, Metrics &M) {

  M.TimeInSCoPs_ns += getTimeInSCoPs(Events, std::cout);
  M.TotalTime_ns += getTotalTimeInProgram(Events, std::cout);
  M.Runs.Val += 1;
}
}

int main(int argc, const char **argv) {
  using namespace pprof;
  pprof::Options Opts = pprof::getPprofOptionsFromEnv();

  std::vector<const PPEvent *> SingleRun;
  std::map<uint32_t, PPStringRegion> Regions;
  Metrics M;

  if (Opts.use_file) {
    std::cout << "Using RAW file backend\n";
    SingleRun.clear();
    while (file::ReadRun(SingleRun, Regions, Opts)) {
      SingleRun = SanitizeRun(SingleRun);
      GenerateStats(SingleRun, M);
      SingleRun.clear();
    }
  }

  if (Opts.use_csv) {
    std::cout << "Using CSV file backend\n";
  }

  if (Opts.use_db) {
    std::cout << "Using Postgres DB backend\n";
    SingleRun.clear();
    while (pgsql::ReadRun(SingleRun, Regions, Opts)) {
      SingleRun = SanitizeRun(SingleRun);
      GenerateStats(SingleRun, M);
      SingleRun.clear();
    }
  }

  PrintStats(std::cout, M, Regions);
}
