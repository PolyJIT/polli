#ifndef PPROF_TRACING_H
#define PPROF_TRACING_H
#include "pprof/pprof.h"
#include "pprof/Config.h"

#include <inttypes.h>
#include <papi.h>

#include <sstream>
#include <iostream>
#include <memory>

#include <assert.h>

// Enable/Disable tracing
#ifdef ENABLE_TRACING
#define LIKWID_PERFMON

#define TRACE(X) \
  do { X; } while (0)
#else
#undef LIKWID_PERFMON

#define TRACE(X) \
  do { } while (0)
#endif

/**
 * @brief Setup papi for trace monitoring.
 */
void pprof_setup_papi();

/**
 * @brief PAPI Event to add to the tracking.
 *
 * @param PapiEventNum
 */
void pprof_trace_add_event(int PapiEventNum);
void pprof_trace_add_event(std::string &&Name);

/**
 * @brief Mark the entry for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_entry(const std::string &&TraceName);

/**
 * @brief Mark the exit for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_exit(const std::string &&TraceName);

/**
 * @brief Start the configured event set
 */
void pprof_trace_start();

/**
 * @brief Stop the configured event set
 *
 * Adding events is only allowed when the current set is not running.
 *
 */
void pprof_trace_stop();

/**
 * @brief Store arbitrary PAPI event data at defined trace points.
 */
template <typename IdTy>
class PPEventInfo {
protected:
  /**
   * @brief Unique(!) Identification of this event.
   */
  IdTy ID;

  /**
   * @brief Type of this pprof event.
   */
  PPEventType EvTy;

  /**
   * @brief Size of the payload.
   */
  size_t Size;

  /**
   * @brief Payload managed by this PPEventInfo
   */
  long long int *Payload;

  /**
   * @brief Timestamp of this payload data.
   */
  uint64_t Timestamp;

  /**
   * @brief Handle of the event set registered in papi.
   */
  int EventSetHandle;

public:
  /**
   * @brief
   *
   * @param id
   * @param evTy
   * @param EventSetHandle
   * @param EventSetSize
   */
  explicit PPEventInfo(IdTy id, PPEventType evTy, int EventSetHandle,
                       int EventSetSize)
      : ID(id), EvTy(evTy), Size(EventSetSize), EventSetHandle(EventSetHandle) {
    Payload = new long long int[Size];
  }

  /**
   * @brief
   *
   * @param idx
   *
   * @return
   */
  long long int get(size_t idx) const;

  /**
   * @brief
   *
   * @return
   */
  PPEventType type() const;

  /**
   * @brief
   *
   * @return
   */
  IdTy id() const;

  /**
   * @brief
   *
   * @param
   *
   * @return
   */
  size_t size() const;

  /**
   * @brief
   *
   * @return
   */
  uint64_t timestamp() const;

  /**
   * @brief
   */
  void snapshot();

  /**
   * @brief
   */
  ~PPEventInfo() {
    delete[] Payload;
  }
};


#endif //PPROF_TRACING_H
