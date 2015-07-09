#include "pprof/Tracing.h"

#include <set>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include <assert.h>
#include <fstream>

/**
 * @brief Output filename.
 */
static std::string fileName = "papi.profile.out";

/**
 * @name PPEventInfo<IdTy> definitions.
 * @{ */
template<typename IdTy>
long long int PPEventInfo<IdTy>::get(size_t idx) const {
  assert(idx < Size && "PPROF: Don't access payload out of bounds!");
  assert(Payload && "PPROF: Snapshot first!");

  return Payload[idx];
}

template<typename IdTy>
PPEventType PPEventInfo<IdTy>::type() const { return EvTy; }

template<typename IdTy>
IdTy PPEventInfo<IdTy>::id() const { return ID; }

template<typename IdTy>
size_t PPEventInfo<IdTy>::size() const { return Size; }

template<typename IdTy>
uint64_t PPEventInfo<IdTy>::timestamp() const { return Timestamp; }

template<typename IdTy>
void PPEventInfo<IdTy>::snapshot() {
  long long *ev_data = new long long int[Size];
  if (int status = PAPI_read(EventSetHandle, ev_data) != PAPI_OK) {
    fprintf(stderr, "PPROF: %s\n", PAPI_strerror(status));
    std::exit(1);
  }

  std::swap(Payload, ev_data);
  if (ev_data)
    delete[] ev_data;

  Timestamp = PAPI_get_virt_nsec();
}
/**  @} */

using namespace std;

template <typename IdTy>
std::ostream &operator<<(std::ostream &os,
                         const std::unique_ptr<PPEventInfo<IdTy>> &&event) {
  os << event->id() << " " << event->type() << " " << event->timestamp();
  for (size_t i=0; i < event->size(); ++i)
    os << " " << event->get(i);
  os << "\n";
  return os;
}

/**
 * @brief Store experimental results in traces
 *
 * A trace is a named event list.
 */
template<typename IdTy>
class TraceStorage {
public:
  typedef std::unique_ptr<PPEventInfo<IdTy>> PPEventPtr;
  typedef std::vector<PPEventPtr> PPEventPtrs;
  typedef std::map<IdTy, PPEventPtrs> TraceRegions;
private:
  TraceRegions Log;
public:
  /**
   * @brief Append the log event to the trace storage container.
   *
   * @param Ev
   */
  void append(PPEventPtr && Ev) {
    Log[Ev->id()].push_back(std::move(Ev));
  }

  /**
   * @brief Store all traces of this log in a file.
   *
   * @param FileName
   */
  void save(std::string FileName) {
    using namespace std;

    ofstream out(FileName, ios_base::out | ios_base::app);

    set<string> TraceEventNames;

    /**
     * @name Fetch Event names.
     *
     * FIXME: This looks horribly inefficient for something that simple.
     * Just fetch the set of keys.
     * @{ */
    for (auto &TracePair : Log) {
      TraceEventNames.insert(TracePair.first);
    }
    /**  @} */

    /**
     * @name Iterate over all traces and print the log.
     * @{ */
    for (auto &TracePair : Log) {
      for (const PPEventPtr &Event : TracePair.second) {
        out << std::move(Event);
      }
    }
    /**  @} */

    out.flush();
    out.close();
  }

  /**
   * @brief Load all traces from file
   *
   * @param FileName
   */
  void load(std::string FileName) {
  }
};

static TraceStorage<std::string> TraceLog;

/**
 * @brief The currently executed PAPI event set.
 */
int EventSet = PAPI_NULL;
int EventSetSize = 0;

/**
 * @brief Setup papi for trace monitoring.
 */
void pprof_setup_papi() {
  int status = PAPI_is_initialized();

  if (status != PAPI_LOW_LEVEL_INITED) {
    status = PAPI_library_init(PAPI_VER_CURRENT);
    if (status != PAPI_VER_CURRENT) {
      fprintf(stderr, "PPROF: PAPI_library_init: Version mismatch\n");
      std::exit(status);
    }
  }

  if (PAPI_create_eventset(&EventSet) != PAPI_OK) {
    fprintf(stderr, "PPROF: Could not create an empty event set\n");
    std::exit(1);
  }
}

void pprof_trace_add_event(std::string &&Name) {
  if (PAPI_is_initialized() != PAPI_LOW_LEVEL_INITED)
    pprof_setup_papi();

  int NativeEv = 0x0;
  char *CName = const_cast<char *>(Name.c_str());
  if (PAPI_event_name_to_code(CName, &NativeEv) != PAPI_OK) {
    fprintf(stderr, "PPROF: Could not get the event code for this name\n");
    fprintf(stderr, "PPROF: %s\n", CName);
    std::exit(1);
  }

  pprof_trace_add_event(NativeEv);
}

void pprof_trace_add_event(int PapiEventNum) {
  if (PAPI_is_initialized() != PAPI_LOW_LEVEL_INITED)
    pprof_setup_papi();


  int status = PAPI_add_event(EventSet, PapiEventNum);
  if (status != PAPI_OK) {
    fprintf(stderr,
            "PPROF: Could not add the requested event code to the set\n");
    fprintf(stderr,
            "PPROF: %x\n", PapiEventNum);
    char *out = (char *)malloc(sizeof(char) * 255);
    PAPI_event_code_to_name(PapiEventNum, out);
    fprintf(stderr,
            "PPROF: %s Reason: %s\n", out, PAPI_strerror(status));
    free(out);
    std::exit(1);
  }

  ++EventSetSize;
}

/**
 * @brief Mark the entry for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_entry(const std::string &&TraceName) {
  std::unique_ptr<PPEventInfo<std::string>> Ev(new PPEventInfo<std::string>(
      TraceName, TraceEnter, EventSet, EventSetSize));

  Ev->snapshot();
  TraceLog.append(std::move(Ev));
}

/**
 * @brief Mark the exit for a specified trace.
 *
 * @param TraceName
 */
void pprof_trace_exit(const std::string &&TraceName) {
  std::unique_ptr<PPEventInfo<std::string>> Ev(new PPEventInfo<std::string>(
      TraceName, TraceExit, EventSet, EventSetSize));

  Ev->snapshot();
  TraceLog.append(std::move(Ev));
}

/**
 * @brief Start the current event set
 */
void pprof_trace_start() {
  if (PAPI_start(EventSet) != PAPI_OK) {
    fprintf(stderr,
            "PPROF: Could not add the requested event code to the set\n");
    std::exit(1);
  }
}

/**
 * @brief Stop the current event set
 */
void pprof_trace_stop() {
  std::unique_ptr<PPEventInfo<std::string>> Ev(new PPEventInfo<std::string>(
      "Stop tracing", TraceEnter, EventSet, EventSetSize));

  Ev->snapshot();
  TraceLog.append(std::move(Ev));
  TraceLog.save(fileName);
}
