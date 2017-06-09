// RUN: %clang -rdynamic -O2 -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polli-process-unprofitable -mllvm -polli -mllvm -jitable %s -mllvm -polli-analyze -o %t %pjit 2>&1 | FileCheck %s -check-prefix=STATIC
// RUN: env BB_USE_DATABASE=0 %t 2>&1 | FileCheck %s
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
// STATIC:   0 region for.body => for.end requires 1 params
// STATIC:     0 - %n

// CHECK: 1 1 1 1 1 0 0 0 0 0
// CHECK: 3 1 3 1 5 0 3 0 7 0
