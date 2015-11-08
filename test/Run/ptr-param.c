// RUN: %clang -O2 -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polly-process-unprofitable -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going %s -mllvm -polli-analyze -o %t -lpjit 2>&1 | FileCheck %s -check-prefix=STATIC
// RUN: %t 2>&1 | FileCheck %s
#include <stdio.h>

void test(int n, int *A) {
  #pragma nounroll
  for (int i = 0; i < 5; i++) {
    A[i*n] = A[i] + n;
  }
}

void print(int *A) {
  printf("A: ");
  for (int i = 0; i < 10; i++) {
    printf("%d ", A[i]);
  }

  printf("\n");
}

int A[10];
int main(int argc, char **argv) {
  test(1, A);
  print(A);
  test(2, A);
  print(A);
}

// STATIC: 1 regions require runtime support:
// STATIC:   0 region for.body => for.cond.cleanup requires 1 params
// STATIC:       0 - (4 * (sext i32 %n to i64))
// STATIC:       1 reasons can be fixed at run time:
// STATIC:             0 - Non affine access function: {0,+,(4 * (sext i32 %n to i64))}<nsw><%for.body>

// CHECK: A: 1 1 1 1 1 0 0 0 0 0
// CHECK: A: 3 1 3 1 5 0 3 0 7 0
