#include "pprof/Perf.h"
#include <iostream>

int64_t PerfID = -41;

std::map<std::string, int64_t>& getPerfRegions() {
  static std::map<std::string, int64_t> Perf_Regions;
  return Perf_Regions;
}

int64_t getNewPerfID(std::string RegionName) {
  PerfID--;
  auto &Perf_Regions = getPerfRegions();
  Perf_Regions.insert(std::pair<std::string, int64_t>(RegionName, PerfID));
  return PerfID;
}
