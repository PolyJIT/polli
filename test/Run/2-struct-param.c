// RUN: %clang -O2 -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polly-detect-unprofitable -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going %s -mllvm -polli-analyze -o %t -lpjit 2>&1 | FileCheck %s -check-prefix=STATIC
// RUN: %t 2>&1 | FileCheck %s
#include <stdio.h>

typedef struct {
  int  bar;
  int A[10];
} SA;

SA sA;

typedef struct {
  int foo;
  int B[10];
} SB;

SB sB;

void test(int n) {
  for (int i = 0; i < 5; i++) {
    sA.A[i*n] = sA.A[i] + n;
    sB.B[i*n] = sB.B[i] + n;
  }
}

void print() {
  printf("A: ");
  for (int i = 0; i < 10; i++) {
    printf("%d ", sA.A[i]);
  }

  printf("\n");

  printf("B: ");
  for (int i = 0; i < 10; i++) {
    printf("%d ", sB.B[i]);
  }

  printf("\n");
}

int main(int argc, char **argv) {
  test(1);
  print();
  test(2);
  print();
}

// STATIC: 1 regions require runtime support:
// STATIC:   0 region for.body => for.end requires 2 params
// STATIC:     0 - (4 * (sext i32 %n to i64))
// STATIC:     0 - (4 * (sext i32 %n to i64))
// STATIC:     2 reasons can be fixed at run time:
// STATIC:       0 - Non affine access function: {4,+,(4 * (sext i32 %n to i64))}<nw><%for.body>
// STATIC:       1 - Non affine access function: {4,+,(4 * (sext i32 %n to i64))}<nw><%for.body>

// CHECK: A: 1 1 1 1 1 0 0 0 0 0
// CHECK: B: 1 1 1 1 1 0 0 0 0 0
// CHECK: A: 3 1 3 1 5 0 3 0 7 0
// CHECK: B: 3 1 3 1 5 0 3 0 7 0
