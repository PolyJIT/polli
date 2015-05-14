// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polly-detect-keep-going -o /dev/null -x c++ %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

// Check that we can handle a single global variable during compilation.

typedef struct {
  int A[10240];
} TestA;
static TestA StructA;
static TestA StructB;

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

// CHECK: define internal void @_Z4testi_.pjit.scop1(i32, %struct.TestA*) #2 {
// CHECK-NEXT: polyjit.entry:
// CHECK-NEXT:   %params = alloca [4 x i8*]
// CHECK-NEXT:   %2 = alloca i32
// CHECK-NEXT:   store volatile i32 %0, i32* %2
// CHECK-NEXT:   %3 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 0
// CHECK-NEXT:   %4 = bitcast i32* %2 to i8*
// CHECK-NEXT:   store i8* %4, i8** %3
// CHECK-NEXT:   %5 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 1
// CHECK-NEXT:   %6 = bitcast %struct.TestA* %1 to i8*
// CHECK-NEXT:   store i8* %6, i8** %5
// CHECK-NEXT:   %7 = getelementptr [4 x i8*], [4 x i8*]* %params, i32 0, i32 2
// CHECK-NEXT:   store i8* bitcast (%struct.TestA* @_ZL7StructB to i8*), i8** %7
// CHECK-NEXT:   %8 = bitcast [4 x i8*]* %params to i8*
// CHECK-NEXT:   call void @pjit_main(i8* getelementptr inbounds ([{{[0-9]+}} x i8], [{{[0-9]+}} x i8]* @_Z4testi_.pjit.scop.prototype, i32 0, i32 0), i32 4, i8* %8)
// CHECK-NEXT:   ret void
// CHECK-NEXT: }
