#ifndef POLLI_DB_H
#define POLLI_DB_H

#include <unordered_map>
#include <string>

using EventMapTy = std::unordered_map<uint64_t, uint64_t>;
using RegionMapTy = std::unordered_map<uint64_t, std::string>;


namespace polli {
struct Options {
  std::string experiment;
  std::string project;
  std::string domain;
  std::string group;
  std::string src_uri;
  std::string command;
  bool use_db;
  bool use_csv;
  bool use_file;
  bool execute_atexit;
};

void StoreRun(const EventMapTy &Events, const RegionMapTy &Regions);
}

#endif /* end of include guard: POLLI_DB_H */
