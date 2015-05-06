// RUN: %clang_cc1 -O3 -emit-llvm -load LLVMPolyJIT.so -mllvm -polli -mllvm jitable -mllvm polly-detect-keep-going %s -o /dev/null
static int A[10240];

void test(int n) {
  for (int i = 0; i < 1024; i++) {
    A[i*n] = A[i] + n;
  }
}

int main(int argc, char **argv) {
  test(10);
  test(1);

  return A[0];
}
