#include "pprof/pprof.h"
namespace papi {
#include <papi.h>
}

static long long papi_calib_cnt = 100000;

void papi_calibrate(void) {
  long long time = papi::PAPI_get_virt_usec();
  long long time2 = papi::PAPI_get_real_usec();

  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(1, "a");
    papi_region_enter_scop(2, "b");
    papi_region_exit_scop(2, "b");
    papi_region_exit_scop(1, "a");
  }

  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(1, "a");
    papi_region_enter_scop(2, "b");
    papi_region_enter_scop(3, "c");
    papi_region_exit_scop(3, "c");
    papi_region_exit_scop(2, "b");
    papi_region_exit_scop(1, "a");
  }

  for (int i = 0; i < papi_calib_cnt; ++i) {
    papi_region_enter_scop(3, "c");
    papi_region_exit_scop(3, "c");
  }

  time = (papi::PAPI_get_virt_usec() - time);
  time2 = (papi::PAPI_get_real_usec() - time2);

  // Measurement is done per "pair" of PAPI calls.
  double avg = time / (double)(pprof::PapiEvents.size() / 2);
  double avg2 = time2 / (double)(pprof::PapiEvents.size() / 2);

  fprintf(stdout, "User time per call (ns): %f\n", avg);
  fprintf(stdout, "Real time per call (ns): %f\n", avg2);
  fprintf(stdout, "PAPI-stack calls: %lu\n", pprof::PapiEvents.size() / 2);
  fprintf(stdout, "User time (s): %f\n", time / 1e6);
  fprintf(stdout, "Real time (s): %f\n", time2 / 1e6);
}

int main(int argc, char **argv) {
  fprintf(stdout, "EventSize: %zu\n", sizeof(PPEvent));
  fprintf(stdout, "EventTySize: %zu\n", sizeof(PPEventType));

  papi::PAPI_library_init(PAPI_VER_CURRENT);
  if (!papi::PAPI_is_initialized()) {
    fprintf(stderr, "ERROR: libPAPI is not initialized\n");
  }
  papi_region_setup();
  papi_calibrate();
}
