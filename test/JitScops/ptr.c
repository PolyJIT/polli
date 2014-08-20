#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

void foo(int argc, void *((*argv)[3])) {
  void **params = *argv;

  int *val0 =  (int *)params[0];
  int *val1 =  (int *)params[1];
  double *val2 =  (double *)params[2];

  for (int i=0;i<5;++i) {
    val1[i] = (int)i*random();
  }

  fprintf(stderr, "foo: %d,   %g,   %d,   %d,   %d,   %d,   %d\n",
          *val0, *val2, val1[0], val1[1], val1[2], val1[3], val1[4]);
}

void pack(int _n, double _m, int _A[5]) {
  void *params[3];

  params[0] = &_n;
  params[1] = _A;
  params[2] = &_m;

  int* nptr           =  params[0]; 
  int* Aptr           =  params[1];
  int* mptr           =  params[2]; 

  int    n    = *(int *)nptr;
  double m    = *(double *)mptr;
  
  fprintf(stderr, "pack: %d,   %g,   %d,   %d,   %d,   %d,   %d\n",
          n, m, Aptr[0], Aptr[1], Aptr[2], Aptr[3], Aptr[4]);

  foo(3, &params);
}

int main(int argc, char **argv) {
  int A[]    = { 1, 2, 3, 4, 5};
  int n      = 5;
  double m   = 10.5;

  fprintf(stderr, "main: %d,   %g,   %d,   %d,   %d,   %d,   %d\n",
                          n, m, A[0], A[1], A[2], A[3], A[4]);
  pack(n, m, A);
}
