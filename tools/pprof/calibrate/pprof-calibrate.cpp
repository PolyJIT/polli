#include "pprof/pprof.h"

static long long papi_calib_cnt = 100000;

void papi_calibrate(void) {
  long long time = PAPI_get_virt_nsec();
  long long time2 = PAPI_get_real_nsec();

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

  time = (PAPI_get_virt_nsec() - time);
  time2 = (PAPI_get_real_nsec() - time2);

  // Measurement is done per "pair" of PAPI calls.
  double avg = time / (double)(pprof::PapiEvents.size() / 2);
  double avg2 = time2 / (double)(pprof::PapiEvents.size() / 2);

  fprintf(stdout, "User time per call (ns): %f\n", avg);
  fprintf(stdout, "Real time per call (ns): %f\n", avg2);
  fprintf(stdout, "PAPI-stack calls: %lu\n", pprof::PapiEvents.size() / 2);
  fprintf(stdout, "User time (s): %f\n", time / 1e9);
  fprintf(stdout, "Real time (s): %f\n", time2 / 1e9);
}

int main(int argc, char **argv) {
  fprintf(stdout, "EventSize: %zu\n", sizeof(PPEvent));
  fprintf(stdout, "EventTySize: %zu\n", sizeof(PPEventType));

  PAPI_library_init(PAPI_VER_CURRENT);
  if (!PAPI_is_initialized()) {
    fprintf(stderr, "ERROR: libPAPI is not initialized\n");
  }
  papi_region_setup();
  papi_calibrate();
}
