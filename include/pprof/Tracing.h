#ifndef PPROF_TRACING_H
#define PPROF_TRACING_H

#include "pprof/pprof.h"
#include "pprof/Config.h"

#include <likwid.h>

#ifdef POLLI_ENABLE_TRACING
#define POLLI_TRACING_INIT polliTracingInit()
#define POLLI_TRACING_FINALIZE polliTracingFinalize()
#define POLLI_TRACING_REGION_START(ID, NAME) polliTracingRegionStart(ID, NAME)
#define POLLI_TRACING_REGION_STOP(ID, NAME) polliTracingRegionStop(ID, NAME)
#define POLLI_TRACING_SCOP_START(ID, NAME) polliTracingScopStart(ID, NAME)
#define POLLI_TRACING_SCOP_STOP(ID, NAME) polliTracingScopStop(ID, NAME)
#else
#define POLLI_TRACING_INIT
#define POLLI_TRACING_FINALIZE
#define POLLI_TRACING_REGION_START(ID, NAME)
#define POLLI_TRACING_REGION_STOP(ID, NAME)
#define POLLI_TRACING_SCOP_START(ID, NAME)
#define POLLI_TRACING_SCOP_STOP(ID, NAME)
#endif

// PolyJIT's own PAPI instrumentation takes precedence.
#ifdef POLLI_ENABLE_PAPI
#undef POLLI_ENABLE_LIKWID
#endif

#ifdef POLLI_ENABLE_LIKWID
#define LIKWID_PERFMON
#endif

#ifdef __cplusplus
extern "C" {
#endif
void polliTracingInit();
void polliTracingFinalize();

void polliTracingRegionStart(uint64_t Id, const char *Name);
void polliTracingRegionStop(uint64_t Id, const char *Name);
void polliTracingScopStart(uint64_t Id, const char *Name);
void polliTracingScopStop(uint64_t Id, const char *Name);

#ifdef POLLI_ENABLE_LIKWID
void polliTracingInit() {
  LIKWID_MARKER_INIT;
}

void polliTracingFinalize() {
  LIKWID_MARKER_STOP;
}

void polliTracingRegionStart(uint64_t Id, const char *Name) {
  LIKWID_MARKER_START(Name);
}

void polliTracingRegionStop(uint64_t Id, const char *Name) {
  LIKWID_MARKER_STOP(Name);
}

void polliTracingScopStart(uint64_t Id, const char *Name) {
  LIKWID_MARKER_START(Name);
}

void polliTracingScopStop(uint64_t Id, const char *Name) {
  LIKWID_MARKER_STOP(Name);
}
#endif

#ifdef POLLI_ENABLE_PAPI
void polliTracingInit() {
}

void polliTracingFinalize() {
}

void polliTracingRegionStart(uint64_t Id, const char *Name) {
  papi_region_enter(Id, Name);
}

void polliTracingRegionStop(uint64_t Id, const char *Name) {
  papi_region_exit(Id, Name);
}

void polliTracingScopStart(uint64_t Id, const char *Name) {
  papi_region_enter_scop(Id, Name);
}

void polliTracingScopStop(uint64_t Id, const char *Name) {
  papi_region_exit_scop(Id, Name);
}
#endif
#ifdef __cplusplus
}
#endif
#endif //PPROF_TRACING_H
