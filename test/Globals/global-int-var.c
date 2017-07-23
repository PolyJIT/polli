// RUN: %clang_cc1 -emit-llvm -O2 -load LLVMPolly.so -load LLVMPolyJIT.so -mllvm -polli -mllvm -polli-process-unprofitable -o /dev/stderr %s -mllvm -polli-analyze -mllvm -stats 2>&1 | FileCheck %s
// Check that we can handle a single global variable during compilation.

static int A[10240];

void test(int n) {
  #pragma nounroll
  for (int i = 0; i < 1024; i++) {
    A[i*n] = A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);

  return A[0];
}
// CHECK: @A_POLYJIT_GLOBAL_{{[0-9]+}} = local_unnamed_addr global [10240 x i32] zeroinitializer, align 16

// CHECK: polyjit.entry:
// CHECK-NEXT:   %params = alloca [2 x i8*], align 8
// CHECK-NEXT:   %pjit.stack.param = alloca i32, align 4
// CHECK-NEXT:   store i32 %n, i32* %pjit.stack.param, align 4
// CHECK-NEXT:   %1 = bitcast [2 x i8*]* %params to i32**
// CHECK-NEXT:   store i32* %pjit.stack.param, i32** %1, align 8
// CHECK-NEXT:   %pjit.stack.param1 = alloca i64, align 8
// CHECK-NEXT:   store i64 %0, i64* %pjit.stack.param1, align 8
// CHECK-NEXT:   %2 = getelementptr inbounds [2 x i8*], [2 x i8*]* %params, i64 0, i64 1
// CHECK-NEXT:   %3 = bitcast i8** %2 to i64**
// CHECK-NEXT:   store i64* %pjit.stack.param1, i64** %3, align 8
// CHECK-NEXT:   %4 = bitcast [2 x i8*]* %params to i8*
// CHECK-NEXT:   %5 = call i1 @pjit_main(i8* getelementptr inbounds ([{{[0-9]+}} x i8], [{{[0-9]+}} x i8]* @test_0.pjit.scop.prototype, i64 0, i64 0), i64* getelementptr inbounds ({ i64, i64, i64, i1, i64, i64 }, { i64, i64, i64, i1, i64, i64 }* @polyjit.stats.test_0.pjit.scop.1, i64 0, i32 0), i32 2, i8* nonnull %4) #3
