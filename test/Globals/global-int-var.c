// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going -o /dev/null -x c++ %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

// Check that we can handle a single global variable during compilation.

static int A[10240];

void test(int n) {
  for (int i = 0; i < 1024; i++) {
    A[i*n] = A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);

  return A[0];
}
// CHECK: polyjit.entry:
// CHECK-NEXT:   %params = alloca [2 x i8*]
// CHECK-NEXT:   %1 = alloca i32
// CHECK-NEXT:   store volatile i32 %0, i32* %1
// CHECK-NEXT:   %2 = getelementptr [2 x i8*], [2 x i8*]* %params, i32 0, i32 0
// CHECK-NEXT:   %3 = bitcast i32* %1 to i8*
// CHECK-NEXT:   store i8* %3, i8** %2
// CHECK-NEXT:   %4 = getelementptr [2 x i8*], [2 x i8*]* %params, i32 0, i32 1
// CHECK-NEXT:   store i8* bitcast ([10240 x i32]* @_ZL1A to i8*), i8** %4
// CHECK-NEXT:   %5 = bitcast [2 x i8*]* %params to i8*
// CHECK-NEXT:   call void @pjit_main(i8* getelementptr inbounds ([{{[0-9]+}} x i8], [{{[0-9]+}} x i8]* @_Z4testi_.pjit.scop.prototype, i32 0, i32 0), i32 2, i8* %5)
// CHECK-NEXT:   ret void
