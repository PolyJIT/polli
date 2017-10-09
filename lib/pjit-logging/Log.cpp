#include <vector>

#include "polli/Options.h"
#include "polli/log.h"
#include "spdlog/spdlog.h"

#include <cstdlib>
#include <iostream>
#include <unistd.h>

namespace {
static std::string &getLogOutFile() {
  static __pid_t Pid = getpid();
  static std::string LogFile = fmt::format("./polyjit.{:d}.log", Pid);
  return LogFile;
}

static inline std::vector<spdlog::sink_ptr> &global_init() {
  static bool Init = false;
  static std::vector<spdlog::sink_ptr> Sinks;

  if (Init)
    return Sinks;

  Init = true;

  if (polli::opt::EnableLogFile &&
      (polli::opt::LogLevel != spdlog::level::off)) {
    spdlog::set_async_mode(1048576);

    auto Sink = std::make_shared<spdlog::sinks::simple_file_sink_mt>(
        getLogOutFile(), true);
    Sink->set_force_flush(true);
    Sinks.push_back(Sink);
  } else {
    Sinks.push_back(std::make_shared<spdlog::sinks::stderr_sink_mt>());
  }

  return Sinks;
}

static inline void setup(const std::string &name) {
  if (!spdlog::get(name)) {
    auto &Sinks = global_init();
    auto Logger =
        std::make_shared<spdlog::logger>(name, Sinks.begin(), Sinks.end());
    spdlog::register_logger(Logger);
    Logger->set_level(polli::opt::LogLevel);
  }
}
} // namespace // namespace

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name) {
  setup(name);
  return spdlog::get(name);
}
} // namespace polli // namespace polli
