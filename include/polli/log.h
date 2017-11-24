#ifndef POLLI_LOG_H
#define POLLI_LOG_H
#include <memory>
#include <string>

#include "polli/Options.h"
#include "spdlog/spdlog.h"

using spdlog::logger;
using spdlog::level::level_enum;

using polli::opt::LogLevel;

namespace polli {
std::shared_ptr<spdlog::logger>
register_log(const std::string &Name = "default",
             const level_enum = spdlog::level::off);

struct WrappedLogger {
  WrappedLogger(const std::string &name) : Name(name) {}

  auto operator-> () const -> std::shared_ptr<logger> & {
    static std::shared_ptr<logger> Log = register_log(Name, LogLevel);
    return Log;
  }

  private:
    std::string Name;
};

#define REGISTER_LOG(VARNAME, NAME) \
    static polli::WrappedLogger VARNAME(NAME)
} // namespace polli
#endif // POLLI_LOG_H
