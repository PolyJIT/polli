// RUN: %clang -rdynamic -O2 -Xclang -load -Xclang LLVMPolly.so -Xclang -load -Xclang LLVMPolyJIT.so -mllvm -polli-process-unprofitable -mllvm -polli %s -o %t %pjit
// RUN: env BB_USE_DATABASE=0 %t 2>&1 | FileCheck %s
#include <stdio.h>

static int A[10];

void test(int n) {
  #pragma nounroll
  for (int i = 0; i < 5; i++) {
    A[i*n] = A[i] + n;
  }
}

void printA() {
  for (int i = 0; i < 10; i++) {
    printf("%d ", A[i]);
  }
  printf("\n");
}

int main(int argc, char **argv) {
  test(1);
  printA();
  test(2);
  printA();
}
// CHECK: 1 1 1 1 1 0 0 0 0 0
// CHECK: 3 1 3 1 5 0 3 0 7 0
