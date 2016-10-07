#include "polli/Tasks.h"
#include "polli/log.h"

namespace {
REGISTER_LOG(console, "tasks");
}

namespace polli {
TaskSystem::TaskSystem() {
  console->error("started thread pool: {:d} workers", Count);
  for (unsigned n = 0; n < Count; ++n) {
    Threads.emplace_back([&, n] { run(n); });
  }
}

void TaskSystem::run(unsigned i) {
  pthread_setname_np(pthread_self(),
                     fmt::format("pjit_worker_{:d}", i).c_str());
  while (true) {
    std::function<void()> F;

    for (unsigned n = 0; n != Count * 32; ++n) {
      if (JobQs[(i + n) % Count].try_pop(F))
        break;
    }

    if (!F && !JobQs[i].pop(F))
      break;

    F();
  }
}
}
