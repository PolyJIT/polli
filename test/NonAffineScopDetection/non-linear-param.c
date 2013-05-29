#include <stdlib.h>

int foo(int n) {
  int A[1024];

  for (int i=0; i<n; ++i) {
    A[n*i] = i;
  }
  return A[42];
}

int main(int argc, char **argv) {
  int A[1024];
  int n = rand() % 32;

  for (int i=0; i<n; ++i) {
    A[n*i] = i;
  }

  foo(32);
  return A[42];
}
