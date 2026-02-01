#include <tgmath.h>
#include <mpi.h>
#include <stdio.h>

int main (int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int x = 2;
  printf("Process %i of %i: pow(x, rank) = %i, %s\n", rank, size, (int)pow(x, rank), rank % 2 ? "World" : "Hello");
  return 0;
}

