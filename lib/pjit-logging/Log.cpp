#include "polli/log.h"
#include "spdlog/spdlog.h"

const char *LOG_FILENAME = "/tmp/.polyjit";
const size_t LOG_SIZE = 1048576 * 100;
auto LOG_LEVEL = spdlog::level::notice;

static inline void setup() {
  static bool init = false;
  if (init)
    return;
  init = true;

  spdlog::set_async_mode(1048576);
  spdlog::set_level(LOG_LEVEL);

  auto sharedFileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
      LOG_FILENAME, "log", LOG_SIZE, 5, false);
  spdlog::create("default", {sharedFileSink});
  spdlog::create("pprof", {sharedFileSink});
}

namespace polli {
std::shared_ptr<spdlog::logger> log(const std::string &name) {
  setup();
  return spdlog::get(name);
}
}
