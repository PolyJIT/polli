#ifndef PERF_H
#define PERF_H

#include <stdint.h>
#include <map>


extern int64_t PerfID;

std::map<std::string, int64_t>& getPerfRegions();

int64_t getNewPerfID(std::string RegionName);

#endif
