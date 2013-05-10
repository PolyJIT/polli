#include <stdio.h>
#include <stdlib.h>

int main() {
  int n = 10;
  int m = rand() % 100;
  int A[1024];

  for (int i=0;i<=n;i++) {
    A[i*i] = i+i;
  }
  
  for (int i=0;i<=n;i++) {
    A[m*i] = i+i;
  }
  
  for (int i=0;i<=n;i++) {
    A[m+i] = i+i;
  }

  for (int i=0;i<=n;i++) {
    printf("%d", A[i*i]);
  }

  return A[2];
}
