#include <mpi.h>
#include <stdio.h>
//#include <stdlib.h>

int main (int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  printf("Processor %i of %i: Hello World!\n", rank, size);

  MPI_Finalize();
  return 0;
}

