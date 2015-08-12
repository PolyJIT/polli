#ifndef PPROF_TRACING_H
#define PPROF_TRACING_H

#include "pprof/pprof.h"
#include "pprof/Config.h"
#include "polli/Options.h"

#include "spdlog/spdlog.h"
#include <memory>

#ifdef POLLI_ENABLE_TRACING
#define LIKWID_PERFMON

#include <likwid.h>
#define POLLI_TRACING_INIT polliTracingInit()
#define POLLI_TRACING_FINALIZE polliTracingFinalize()
#define POLLI_TRACING_REGION_START(ID, NAME) polliTracingRegionStart(ID, NAME)
#define POLLI_TRACING_REGION_STOP(ID, NAME) polliTracingRegionStop(ID, NAME)
#define POLLI_TRACING_SCOP_START(ID, NAME) polliTracingScopStart(ID, NAME)
#define POLLI_TRACING_SCOP_STOP(ID, NAME) polliTracingScopStop(ID, NAME)
namespace polli {
static std::shared_ptr<spdlog::logger> logger() {
  static auto Console = spdlog::stderr_logger_st("polli/tracer");
  return Console;
}

struct Tracer {
  virtual void init() const {}
  virtual void finalize() const {}
  virtual void regionStart(uint64_t Id, const char *Name) const {}
  virtual void regionStop(uint64_t Id, const char *Name) const {}
  virtual void scopStart(uint64_t Id, const char *Name) const {}
  virtual void scopStop(uint64_t Id, const char *Name) const {}
  virtual ~Tracer() = default;
};

struct LikwidTracer : public Tracer {
  void init() const override {
    likwid_markerInit();
    likwid_markerThreadInit();
  }
  void finalize() const override { likwid_markerClose(); }
  void regionStart(uint64_t Id, const char *Name) const override {
    likwid_markerStartRegion(Name);
  }
  void regionStop(uint64_t Id, const char *Name) const override {
    likwid_markerStopRegion(Name);
  }
  void scopStart(uint64_t Id, const char *Name) const override {
    likwid_markerStartRegion(Name);
  }
  void scopStop(uint64_t Id, const char *Name) const override {
    likwid_markerStopRegion(Name);
  }
};

struct PapiTracer : public Tracer {
  void init() const override { papi_region_setup(); }
  void finalize() const override {}
  void regionStart(uint64_t Id, const char *Name) const override {
    papi_region_enter(Id, Name);
  }
  void regionStop(uint64_t Id, const char *Name) const override {
    papi_region_exit(Id, Name);
  }
  void scopStart(uint64_t Id, const char *Name) const override {
    papi_region_enter_scop(Id, Name);
  }
  void scopStop(uint64_t Id, const char *Name) const override {
    papi_region_exit_scop(Id, Name);
  }
};

static std::unique_ptr<Tracer> createTracer() {
  if (opt::havePapi())
    return std::unique_ptr<Tracer>(new PapiTracer());
  else if (opt::haveLikwid())
    return std::unique_ptr<Tracer>(new LikwidTracer());

  return std::unique_ptr<Tracer>(new Tracer());
}

static std::unique_ptr<Tracer> ActiveTracer = createTracer();
}

#ifdef __cplusplus
extern "C" {
#endif
void polliTracingInit() {
  polli::ActiveTracer->init();
}

void polliTracingFinalize() {
  polli::ActiveTracer->finalize();
}

void polliTracingRegionStart(uint64_t Id, const char *Name) {
  polli::ActiveTracer->regionStart(Id, Name);
}

void polliTracingRegionStop(uint64_t Id, const char *Name) {
  polli::ActiveTracer->regionStop(Id, Name);
}

void polliTracingScopStart(uint64_t Id, const char *Name) {
  polli::ActiveTracer->scopStart(Id, Name);
}

void polliTracingScopStop(uint64_t Id, const char *Name) {
  polli::ActiveTracer->scopStop(Id, Name);
}
#ifdef __cplusplus
#else
#define POLLI_TRACING_INIT
#define POLLI_TRACING_FINALIZE
#define POLLI_TRACING_REGION_START(ID, NAME)
#define POLLI_TRACING_REGION_STOP(ID, NAME)
#define POLLI_TRACING_SCOP_START(ID, NAME)
#define POLLI_TRACING_SCOP_STOP(ID, NAME)
#endif
}
#endif
#endif //PPROF_TRACING_H
