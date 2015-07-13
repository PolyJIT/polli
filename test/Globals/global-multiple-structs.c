// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going -o /dev/null -x c++ %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

// Check that we can handle a single global variable during compilation.

typedef struct {
  int A[10240];
} TestA;
TestA StructA;
TestA StructB;

void test(int n) {
  for (int i = 0; i < 1024; i++) {
    StructA.A[i*n] = StructA.A[i] + n;
    StructB.A[i*n] = StructA.A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);

  return StructB.A[0];
}

// CHECK: define void @_Z4testi_for.body.pjit.scop.1(i32, i64, i64) #3 {
// CHECK-NEXT: polyjit.entry:
// CHECK-NEXT:   %params = alloca [5 x i8*]
// CHECK-NEXT:   %3 = alloca i32
// CHECK-NEXT:   store volatile i32 %0, i32* %3
// CHECK-NEXT:   %4 = getelementptr [5 x i8*], [5 x i8*]* %params, i32 0, i32 0
// CHECK-NEXT:   %5 = bitcast i32* %3 to i8*
// CHECK-NEXT:   store i8* %5, i8** %4
// CHECK-NEXT:   %6 = alloca i64
// CHECK-NEXT:   store volatile i64 %1, i64* %6
// CHECK-NEXT:   %7 = getelementptr [5 x i8*], [5 x i8*]* %params, i32 0, i32 1
// CHECK-NEXT:   %8 = bitcast i64* %6 to i8*
// CHECK-NEXT:   store i8* %8, i8** %7
// CHECK-NEXT:   %9 = alloca i64
// CHECK-NEXT:   store volatile i64 %2, i64* %9
// CHECK-NEXT:   %10 = getelementptr [5 x i8*], [5 x i8*]* %params, i32 0, i32 2
// CHECK-NEXT:   %11 = bitcast i64* %9 to i8*
// CHECK-NEXT:   store i8* %11, i8** %10
// CHECK-NEXT:   %12 = getelementptr [5 x i8*], [5 x i8*]* %params, i32 0, i32 3
// CHECK-NEXT:   store i8* bitcast (%struct.TestA* @StructA to i8*), i8** %12
// CHECK-NEXT:   %13 = getelementptr [5 x i8*], [5 x i8*]* %params, i32 0, i32 4
// CHECK-NEXT:   store i8* bitcast (%struct.TestA* @StructB to i8*), i8** %13
// CHECK-NEXT:   %14 = bitcast [5 x i8*]* %params to i8*
// CHECK-NEXT:   call void @pjit_main(i8* getelementptr inbounds ([1844 x i8], [1844 x i8]* @_Z4testi_for.body.pjit.scop.prototype, i32 0, i32 0), i32 5, i8* %14)
// CHECK-NEXT:   ret void
// CHECK-NEXT: }
