#include "polli/Tasks.h"
#include "polli/log.h"
#include "pprof/pprof.h"

namespace {
REGISTER_LOG(console, "tasks");
} // namespace

namespace polli {
TaskSystem::TaskSystem() {
  for (unsigned N = 0; N < Count; ++N) {
    Threads.emplace_back([&, N] { run(N); });
  }
}

void TaskSystem::run(unsigned i) {
  pthread_setname_np(pthread_self(),
                     fmt::format("pjit_worker_{:d}", i).c_str());
  while (true) {
    std::function<void()> F;

    for (unsigned N = 0; N != Count * 32; ++N) {
      if (JobQs[(i + N) % Count].try_pop(F))
        break;
    }

    if (!F && !JobQs[i].pop(F))
      break;

    F();
  }
}
} // namespace polli
