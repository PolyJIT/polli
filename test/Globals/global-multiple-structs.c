// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polly-detect-unprofitable -mllvm -polly-detect-keep-going -o /dev/null -x c++ %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

// Check that we can handle a single global variable during compilation.

typedef struct {
  int A[10240];
} TestA;
TestA StructA;
TestA StructB;

void test(int n) {
  #pragma nounroll
  for (int i = 0; i < 1024; i++) {
    StructA.A[i*n] = StructA.A[i] + n;
    StructB.A[i*n] = StructA.A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);

  return StructB.A[0];
}

// CHECK: define weak void @_Z4testi_for.body.pjit.scop.1(i32, i64) #3 {
// CHECK-NEXT: polyjit.entry:
// CHECK-NEXT:   %params = alloca [4 x i8*]
// CHECK-NEXT:   %2 = alloca i32
// CHECK-NEXT:   store volatile i32 %0, i32* %2
// CHECK-NEXT:   %3 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 0
// CHECK-NEXT:   %4 = bitcast i32* %2 to i8*
// CHECK-NEXT:   store i8* %4, i8** %3
// CHECK-NEXT:   %5 = alloca i64
// CHECK-NEXT:   store volatile i64 %1, i64* %5
// CHECK-NEXT:   %6 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 1
// CHECK-NEXT:   %7 = bitcast i64* %5 to i8*
// CHECK-NEXT:   store i8* %7, i8** %6
// CHECK-NEXT:   %8 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 2
// CHECK-NEXT:   store i8* bitcast (%struct.TestA* @StructA to i8*), i8** %8
// CHECK-NEXT:   %9 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 3
// CHECK-NEXT:   store i8* bitcast (%struct.TestA* @StructB to i8*), i8** %9
// CHECK-NEXT:   %10 = bitcast [4 x i8*]* %params to i8*
// CHECK-NEXT:   call void @pjit_main(i8* getelementptr inbounds ([1784 x i8], [1784 x i8]* @_Z4testi_for.body.p
// CHECK-NEXT:   ret void
// CHECK-NEXT: }

