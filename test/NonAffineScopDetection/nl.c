#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int foo(int p, int q) {
  int A[128];

  for (int i=0;i<128;++i) {
    A[i] = rand() % 1024;
  }

  for (int i=0;i<64;++i) {
    A[i + q*p] = A[i];
  }

  return 0;
}

int main() {
  foo(3, 6);
  foo(1, 4);
  foo(2, 5);

  return 0;
}
