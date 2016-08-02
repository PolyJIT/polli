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

  spdlog::set_async_mode(8192);
  spdlog::set_level(LOG_LEVEL);

  auto sharedFileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
      LOG_FILENAME, "txt", LOG_SIZE, 1, true);
  auto default_log = std::make_shared<spdlog::logger>("default", sharedFileSink);
  auto pprof_log = std::make_shared<spdlog::logger>("pprof", sharedFileSink);

  spdlog::create("default", {sharedFileSink});
  spdlog::create("pprof", {sharedFileSink});
}

namespace polli {
std::shared_ptr<spdlog::logger> log(const std::string &name) {
  setup();
  return spdlog::get(name);
}
}
