#include <mpi.h>
#include <stdio.h>

int main (int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int a = 10, b = 2;
  if (size < 4) {
    puts("Specify size >= 4");
    MPI_Finalize();
    return 1;
  }

  printf("Process %i of %i: ", rank, size);
  switch (rank % 4) {
  case 0:
    printf("a + b = %i\n", a + b);
    break;
  case 1:
    printf("a - b = %i\n", a - b);
    break;
  case 2:
    printf("a * b = %i\n", a * b);
    break;
  default:
    printf("a / b = %f\n", (double)a / b);
  }

  MPI_Finalize();
  return 0;
}

