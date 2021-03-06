/* Task system for asynchronous execution.
 *
 * This follows Sean Parents implementation of a task system and
 * futures, from his talk: 2015-02-27 'Concurrency'.
 *
 * Copyright © 2016 Andreas Simbürger <simbuerg@lairosiel.de>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#ifndef POLLI_TASKS_H
#define POLLI_TASKS_H

#include <algorithm>
#include <atomic>
#include <condition_variable>
#include <deque>
#include <functional>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

namespace polli {
using LockT = std::unique_lock<std::mutex>;

class JobQueue {
private:
  std::deque<std::function<void()>> Jobs;
  bool Done{false};
  std::mutex Mutex;
  std::condition_variable Ready;

public:
  bool try_pop(std::function<void()> &JobFn) {
    LockT Lock{Mutex, std::try_to_lock};
    if (!Lock || Jobs.empty())
      return false;
    JobFn = std::move(Jobs.front());
    Jobs.pop_front();

    return true;
  }

  bool pop(std::function<void()> &JobFn) {
    LockT Lock{Mutex};
    while (Jobs.empty() && !Done)
      Ready.wait(Lock);
    if (Jobs.empty())
      return false;
    JobFn = std::move(Jobs.front());
    Jobs.pop_front();
    return true;
  }

  void done() {
    {
      LockT Lock{Mutex, std::try_to_lock};
      Done = true;
    }
    Ready.notify_all();
  }

  void cancel_pending_jobs() {
    {
      LockT Lock{Mutex};
      Jobs.clear();
    }
    Ready.notify_all();
  }

  template <typename F> bool try_push(F &&f) {
    {
      LockT Lock{Mutex, std::try_to_lock};
      if (!Lock)
        return false;
      Jobs.emplace_back(std::forward<F>(f));
    }
    Ready.notify_one();
    return true;
  }

  template <typename F> void push(F &&JobFn) {
    {
      LockT Lock{Mutex};
      Jobs.emplace_back(std::forward<F>(JobFn));
    }
    Ready.notify_one();
  }
};

class TaskSystem {
private:
  const unsigned Count{1};
  std::vector<std::thread> Threads;
  std::vector<polli::JobQueue> JobQs{Count};
  std::atomic<unsigned> Index{0};

  void run(unsigned i);
public:
  TaskSystem();

  ~TaskSystem() {
    for (auto &Q : JobQs)
      Q.done();
    for (auto &T : Threads)
      if (T.joinable())
        T.join();
  }

  void wait_for_running_jobs() {
    for (auto &T : Threads)
      if (T.joinable())
        T.join();
  }

  void cancel_pending_jobs() {
    for (auto &Q : JobQs)
      Q.done();
  }

  template <typename F> void async(F &&Fn) {
    auto I = Index++;

    for (unsigned N = 0; N < Count; ++N) {
      if (JobQs[(I + N) % Count].try_push(std::forward<F>(Fn)))
        return;
    }
    JobQs[I % Count].push(std::forward<F>(Fn));
  }
};
} // namespace polli
#endif // POLLI_TASKS_H
