#include "pprof/Tracing.h"
#include "polli/Options.h"

#ifdef POLLI_ENABLE_TRACING
namespace polli {
static TracerTy createTracer() {
  if (opt::havePapi())
    return TracerTy(new PapiTracer());
  else if (opt::haveLikwid())
    return TracerTy(new LikwidTracer());

  return TracerTy(new Tracer());
}

TracerTy getOrCreateActiveTracer() {
  static std::unique_ptr<Tracer> ActiveTracer = createTracer();
}
}

#ifdef __cplusplus
extern "C" {
#endif
void polliTracingInit() { polli::getOrCreateActiveTracer()->init(); }

void polliTracingFinalize() { polli::getOrCreateActiveTracer()->finalize(); }

void polliTracingRegionStart(uint64_t Id, const char *Name) {
  polli::getOrCreateActiveTracer()->regionStart(Id, Name);
}

void polliTracingRegionStop(uint64_t Id, const char *Name) {
  polli::getOrCreateActiveTracer()->regionStop(Id, Name);
}

void polliTracingScopStart(uint64_t Id, const char *Name) {
  polli::getOrCreateActiveTracer()->scopStart(Id, Name);
}

void polliTracingScopStop(uint64_t Id, const char *Name) {
  polli::getOrCreateActiveTracer()->scopStop(Id, Name);
}
#ifdef __cplusplus
}
#endif
#endif // POLLI_ENABLE_TRACING
