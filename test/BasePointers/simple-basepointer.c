// RUN: %clang -O2 -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polli-process-unprofitable -mllvm -polli -mllvm -jitable %s -o %t %pjit
// RUN: %t 2>&1 | FileCheck %s
#include <stdio.h>
#include <inttypes.h>

#define N 10
static int64_t A[N];
static int64_t B[N];

void init() {
  for (int i=0; i < N; i++) {
    A[i] = 1;
    B[i] = 2;
  }
}

void test(int64_t n) {
  #pragma nounroll
  for (int k = 0; k < 10000; k++) {
    #pragma nounroll
    for (int64_t i = 0; i < 5; i++) {
      A[i*n] = B[i*n] * A[i] + n + k;
      B[i*n] = A[i*n] * B[i] + n + k;
      //A[i*n] = B[i*n] * B[i] + n;
      //B[i*n] = A[i*n] * A[i] + n;
    }
  }
}

void print(int64_t n, double Arr[n]) {
  for (int64_t i = 0; i < n; i++) {
    printf("%g ", Arr[i]);
  }
  printf("\n");
}

int main(int argc, char **argv) {
  init();

  test(1);
  test(2);

  print(N, A);
  print(N, B);
}
