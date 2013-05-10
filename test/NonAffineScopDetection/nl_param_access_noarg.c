#include <inttypes.h>

int foo(int64_t n) {
  int64_t A[128];
  int64_t m = n;
  for (int64_t i=0; i<32; ++i) {
    A[i*m] = i+m;
  }
}

int main(int argc, char **argv) {
  foo(3);
}