int main(int argc, char **argv) {
  int A[1024];
  for (int i=0; i<32; ++i) {
    for (int j=0; j<32; ++j) {
      A[i*j] = i+j;
    }
  }
}