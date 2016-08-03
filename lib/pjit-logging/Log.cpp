#include "polli/log.h"
#include "spdlog/spdlog.h"

namespace {
static inline spdlog::sinks_init_list &global_init() {
  static bool init = false;
  static spdlog::sinks_init_list sinks = {};
  if (init)
    return sinks;
  init = true;

  const char *LOG_FILENAME = "/tmp/.polyjit";
  const size_t LOG_SIZE = 1048576 * 100;
  const spdlog::level::level_enum LOG_LEVEL = spdlog::level::notice;

  spdlog::set_async_mode(1048576);
  spdlog::set_level(LOG_LEVEL);
  auto sharedFileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
      LOG_FILENAME, "log", LOG_SIZE, 5, false);
  sinks = {sharedFileSink};
  return sinks;
}

static inline void setup(const std::string &name) {
  if (!spdlog::get(name))
        spdlog::create(name, global_init());
}
}

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name) {
  setup(name);
  return spdlog::get(name);
}
}
