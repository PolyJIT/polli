// RUN: %clang -O2 -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polly-detect-unprofitable -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going %s -mllvm -polli-analyze -o %t -lpjit 2>&1 | FileCheck %s -check-prefix=STATIC
// RUN: %t 2>&1 | FileCheck %s
#include <stdio.h>

struct {
  int A[10];
} StrA;

void test(int n) {
  #pragma nounroll
  for (int i = 0; i < 5; i++) {
    StrA.A[i*n] = StrA.A[i] + n;
  }
}

void printA() {
  for (int i = 0; i < 10; i++) {
    printf("%d ", StrA.A[i]);
  }
  printf("\n");
}

int main(int argc, char **argv) {
  test(1);
  printA();
  test(2);
  printA();
}

// STATIC: 1 regions require runtime support:
// STATIC:   0 region for.body => for.cond.cleanup requires 1 params
// STATIC:     0 - (4 * (sext i32 %n to i64))
// STATIC:     1 reasons can be fixed at run time:
// STATIC:       0 - Non affine access function: {0,+,(4 * (sext i32 %n to i64))}<nsw><%for.body>

// CHECK: 1 1 1 1 1 0 0 0 0 0
// CHECK: 3 1 3 1 5 0 3 0 7 0
