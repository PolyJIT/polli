#include <stdlib.h>

int main(int argc, char **argv) {
  int A[128];

  for (int i=0;i<32;++i) {
    A[i] = A[rand() % 1024];
  }
}