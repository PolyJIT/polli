#ifndef POLLI_LOG_H
#define POLLI_LOG_H
#include "spdlog/spdlog.h"
#include <memory>

using namespace spdlog;

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name = "default");
}
#endif // POLLI_LOG_H
