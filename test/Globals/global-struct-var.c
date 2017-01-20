// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolyJIT.so -mllvm -polli -mllvm -jitable -mllvm -polli-process-unprofitable -o /dev/stderr %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s

// Check that we can handle a single global variable during compilation.

typedef struct {
  int A[10240];
} TestA;
static TestA StructA;

void test(int n) {
  #pragma nounroll
  for (int i = 0; i < 1024; i++) {
    StructA.A[i*n] = StructA.A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);

  return StructA.A[0];
}
// CHECK: @StructA = weak local_unnamed_addr global %struct.TestA zeroinitializer, align 4

// CHECK: polyjit.entry:
// CHECK-NEXT:   %params = alloca [2 x i8*], align 8
// CHECK-NEXT:   %1 = alloca i32, align 4
// CHECK-NEXT:   store volatile i32 %n, i32* %1, align 4
// CHECK-NEXT:   %2 = bitcast [2 x i8*]* %params to i32**
// CHECK-NEXT:   store i32* %1, i32** %2, align 8
// CHECK-NEXT:   %3 = alloca i64, align 8
// CHECK-NEXT:   store volatile i64 %0, i64* %3, align 8
// CHECK-NEXT:   %4 = getelementptr [2 x i8*], [2 x i8*]* %params, i64 0, i64 1
// CHECK-NEXT:   %5 = bitcast i8** %4 to i64**
// CHECK-NEXT:   store i64* %3, i64** %5, align 8
// CHECK-NEXT:   %6 = bitcast [2 x i8*]* %params to i8*
// CHECK-NEXT:   %7 = call i1 @pjit_main(i8* getelementptr inbounds ([1701 x i8], [1701 x i8]* @test_0.pjit.scop.prototype, i64 0, i64 0), i64* getelementptr inbounds ({ i64, i64, i64, i1, i64, i64 }, { i64, i64, i64, i1, i64, i64 }* @polyjit.stats.test_0.pjit.scop.1, i64 0, i32 0), i32 2, i8* %6) #3