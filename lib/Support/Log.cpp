#include "polli/log.h"

const char *LOG_FILENAME = "/tmp/polli.log";
const char *LOG_NAME = "default";
const size_t LOG_SIZE = 1048576 * 100;
auto LOG_LEVEL = spdlog::level::err;

static std::shared_ptr<spdlog::logger> setup() {
  spdlog::set_async_mode(8192);
  spdlog::set_level(LOG_LEVEL);
  return spdlog::rotating_logger_mt(LOG_NAME, LOG_FILENAME, LOG_SIZE, 1);
}

namespace polli {
std::shared_ptr<spdlog::logger> log() {
  static auto l = setup();
  return l;
}
}
