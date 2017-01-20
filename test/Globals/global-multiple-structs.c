// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polli-process-unprofitable -o /dev/stderr %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

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
// CHECK: @StructA = common local_unnamed_addr global %struct.TestA zeroinitializer, align 4
// CHECK: @StructB = common local_unnamed_addr global %struct.TestA zeroinitializer, align 4

// CHECK: polyjit.entry:
// CHECK-NEXT:   %params = alloca [3 x i8*], align 8
// CHECK-NEXT:   %2 = alloca i32, align 4
// CHECK-NEXT:   store volatile i32 %n, i32* %2, align 4
// CHECK-NEXT:   %3 = bitcast [3 x i8*]* %params to i32**
// CHECK-NEXT:   store i32* %2, i32** %3, align 8
// CHECK-NEXT:   %4 = alloca i64, align 8
// CHECK-NEXT:   store volatile i64 %0, i64* %4, align 8
// CHECK-NEXT:   %5 = getelementptr [3 x i8*], [3 x i8*]* %params, i64 0, i64 1
// CHECK-NEXT:   %6 = bitcast i8** %5 to i64**
// CHECK-NEXT:   store i64* %4, i64** %6, align 8
// CHECK-NEXT:   %7 = alloca i64, align 8
// CHECK-NEXT:   store volatile i64 %1, i64* %7, align 8
// CHECK-NEXT:   %8 = getelementptr [3 x i8*], [3 x i8*]* %params, i64 0, i64 2
// CHECK-NEXT:   %9 = bitcast i8** %8 to i64**
// CHECK-NEXT:   store i64* %7, i64** %9, align 8
// CHECK-NEXT:   %10 = bitcast [3 x i8*]* %params to i8*
// CHECK-NEXT:   %11 = call i1 @pjit_main(i8* getelementptr inbounds ([2157 x i8], [2157 x i8]* @test_0.pjit.scop.prototype, i64 0, i64 0), i64* getelementptr inbounds ({ i64, i64, i64, i1, i64, i64 }, { i64, i64, i64, i1, i64, i64 }* @polyjit.stats.test_0.pjit.scop.1, i64 0, i32 0), i32 3, i8* %10) #3