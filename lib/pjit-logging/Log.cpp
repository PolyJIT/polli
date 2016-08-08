#include <vector>

#include "polli/log.h"
#include "spdlog/spdlog.h"

namespace {
static inline std::vector<spdlog::sink_ptr> &global_init() {
  static bool init = false;
  static std::vector<spdlog::sink_ptr> sinks;
  if (init)
    return sinks;
  init = true;

  const char *LOG_FILENAME = "/tmp/.polyjit";
  const size_t LOG_SIZE = 1048576 * 100;

  spdlog::set_async_mode(1048576);
  sinks.push_back(std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
      LOG_FILENAME, "log", LOG_SIZE, 5, true));
  //sinks.push_back(std::make_shared<spdlog::sinks::stderr_sink_mt>());
  return sinks;
}

static inline void setup(const std::string &name) {
  if (!spdlog::get(name)) {
    auto &sinks = global_init();
    auto logger =
        std::make_shared<spdlog::logger>(name, sinks.begin(), sinks.end());
    spdlog::register_logger(logger);
    logger->set_level(spdlog::level::trace);
    logger->critical("registered.");
  }
}
}

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name) {
  setup(name);
  return spdlog::get(name);
}
}
