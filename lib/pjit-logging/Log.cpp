#include <vector>

#include "polli/log.h"
#include "spdlog/spdlog.h"

#include <cstdlib>
#include <unistd.h>

namespace {
static bool use_file_log = false;

static void loadOptionsFromEnv() {
  if (const char *use_file_log_str = std::getenv("POLLI_ENABLE_FILE_LOG")) {
    use_file_log = (bool)std::stoi(use_file_log_str);
  }
}

static std::string &getLogOutFile() {
  static __pid_t pid = getpid();
  static std::string logFile = fmt::format("./polyjit.{:d}.log", pid);
  return logFile;
}

static inline std::vector<spdlog::sink_ptr> &global_init() {
  static bool init = false;
  static std::vector<spdlog::sink_ptr> sinks;

  if (init)
    return sinks;

  loadOptionsFromEnv();
  init = true;

  if (use_file_log) {
    const size_t LOG_SIZE = 1048576 * 100;
    spdlog::set_async_mode(1048576);
    sinks.push_back(std::make_shared<spdlog::sinks::simple_file_sink_mt>(
        getLogOutFile(), true));
  } else {
    sinks.push_back(std::make_shared<spdlog::sinks::stderr_sink_mt>());
  }

  return sinks;
}

static inline void setup(const std::string &name) {
  if (!spdlog::get(name)) {
    auto &sinks = global_init();
    auto logger =
        std::make_shared<spdlog::logger>(name, sinks.begin(), sinks.end());
    spdlog::register_logger(logger);
    logger->set_level(spdlog::level::trace);
  }
}
}

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name) {
  setup(name);
  return spdlog::get(name);
}
}
