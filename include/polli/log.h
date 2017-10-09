#ifndef POLLI_LOG_H
#define POLLI_LOG_H
#include "spdlog/spdlog.h"
#include <memory>

using namespace spdlog;

namespace polli {
std::shared_ptr<spdlog::logger> register_log(const std::string &name = "default");

struct WrappedLogger {
  WrappedLogger(const std::string &name) : Name(name) {}

  auto operator->() const -> std::shared_ptr<spdlog::logger>& {
    static std::shared_ptr<spdlog::logger> Log = polli::register_log(Name);
    return Log;
  }

  private:
    std::string Name;
};

#define REGISTER_LOG(VARNAME, NAME) \
    static polli::WrappedLogger VARNAME(NAME)
} // namespace polli
#endif // POLLI_LOG_H
