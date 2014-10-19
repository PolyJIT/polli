#include "pprof/pprof.h"

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

using namespace std;

static std::map<uint32_t, PPStringRegion> PPStrings;
static std::map<uint32_t, uint64_t> PPDurations;

typedef std::vector<PPEvent> PPVector;
static uint32_t runs = 0;

static std::string fileName = "papi.profile.out";

static int64_t timeInSCoPs_ns = 0;
static int64_t totalTime_ns = 0;

uint64_t getTimeInSCoPs(PPVector &Events, ostream &os) {
  std::shared_ptr<std::vector<int64_t>> s(
      new std::vector<int64_t>(Events.size() + 1));
  std::shared_ptr<std::vector<int64_t>> ts(
      new std::vector<int64_t>(Events.size() + 1));
  std::vector<int64_t> evs;

  uint64_t sum = std::accumulate(Events.begin(), Events.end(), (int64_t)0,
                                 [&](int64_t x, PPEvent y) -> int64_t {
    int64_t newx = x;
    if (y.EventTy == ScopEnter) {
      // Start with 0 in newx, track the start time in ts and reserve a slot
      // in s for our subregions.
      ts->push_back(-y.Timestamp);
      s->push_back(0);
      evs.push_back(y.ID);
    }

    if (y.EventTy == ScopExit) {
      // if we trigger this, we found a bug in the instrumentation.
      while (evs.size() > 1 && evs.back() != y.ID)
        evs.pop_back();

      if (evs.size() > 0 && evs.back() == y.ID) {
        evs.pop_back();

        int64_t fullDur = ts->back() + y.Timestamp;
        int64_t exclusiveDur = fullDur - s->back();

        s->pop_back();
        ts->pop_back();

        s->back() += fullDur;

        // We accumulate only the exclusive Duration.
        newx += exclusiveDur;
        PPDurations[y.ID] += exclusiveDur;
      }
    }

    // Do nothing.
    return newx;
  });

  return sum;
}

uint64_t getTotalTimeInProgram(PPVector &Events, ostream &os) {
  return std::accumulate(Events.begin(), Events.end(), (uint64_t)0,
                         [&os](int64_t x, PPEvent y) -> int64_t {
    int64_t newx = x;
    if (y.ID == 0) {
      if (y.EventTy == RegionEnter)
        newx -= y.Timestamp;

      if (y.EventTy == RegionExit)
        newx += y.Timestamp;
    }
    // Do nothing.
    return newx;
  });
}

void ReadRun(std::string fileName, std::ifstream &in, std::ostream &dbg) {
  PPStringRegion StartR;

  in >> StartR;

  assert((StartR.ID == 0) && "ERROR: StartRegion has ID != 0\n");

  PPStringRegion R;
  while ((in >> R) && R.ID != 0)
    PPStrings[R.ID] = R;

  // Last region we read is an event.
  if (in.eof())
    return;

  PPVector Run;
  Run.push_back(R);

  bool foundDr = false;
  int doctors = 0;
  // Continue until we reach another run.
  PPEvent Ev;
  while ((in >> Ev) && Ev.ID != 0) {
    PPEvent Past = Run.back();
    long long past = Past.Timestamp;
    long long future = Ev.Timestamp;

    foundDr = (past > future);
    if (foundDr) {
      doctors++;
    } else
      Run.push_back(Ev);
  }

  // Last event of a run is defined to have ID 0.
  Run.push_back(Ev);

  if (!doctors) {
    // Run is finished, accumulate.
    timeInSCoPs_ns += getTimeInSCoPs(Run, dbg);
    totalTime_ns += getTotalTimeInProgram(Run, dbg);

    ++runs;
  } else
    dbg << "WARN: Found " << doctors << " time travellers (RUN IGNORED)\n";

  Run.clear();
}

void PrintStats(std::ostream &os) {
  double timeInSCoPs_s = timeInSCoPs_ns / 1e9;
  double totalTime_s = totalTime_ns / 1e9;
  double dynCov = timeInSCoPs_ns / (double)totalTime_ns * 100;

  os << "The following regions have been executed in all runs:\n\n";
  for (auto &R : PPStrings) {
    uint64_t duration = PPDurations[R.first];
    double singleDynCov = duration / (double)totalTime_ns * 100;
    os << R.second << " " << duration << " " << singleDynCov << "\n";
  }
  os << "\nTotal number of program runs - " << runs << "\n";

  os << "Time Spent in SCoPs [ns] - " << timeInSCoPs_ns << "\n";
  os << "Time Spent in SCoPs [s] - " << timeInSCoPs_s << "\n";

  os << "Total run-time [ns] - " << totalTime_ns << "\n";
  os << "Total run-time [s] - " << totalTime_s << "\n";

  os << "Dynamic SCoP coverage - " << dynCov << "\n";
}

int main(int argc, const char **argv) {
  ostream &dbgs = std::cout;

  if (argv[1])
    fileName = argv[1];

  ifstream in(fileName, ios_base::in);

  assert(in && "Could not open input file!");

  if (in) {
    while (!in.eof())
      ReadRun(fileName, in, dbgs);

    PrintStats(std::cout);
    in.close();
  }
}
