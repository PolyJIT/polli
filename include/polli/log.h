#ifndef POLLI_LOG_H
#define POLLI_LOG_H
#include "spdlog/spdlog.h"
#include <memory>

using namespace spdlog;

namespace polli {
std::shared_ptr<spdlog::logger> log();
}
#endif // POLLI_LOG_H
