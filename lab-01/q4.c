#include <mpi.h>
#include <stdio.h>

int factorial(int n) {
  int r = 1;
  for (int i = 1; i <= n; ++i)
    r *= i;

  return r;
}

int fib(int n) {
  if (n <= 1)
    return n;

  return fib(n - 1) + fib(n - 2);
}

int main (int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (rank % 2)
    printf("Process %i of %i: fib(rank) = %i\n", rank, size, fib(rank));
  else
    printf("Process %i of %i: factorial(rank) = %i\n", rank, size, factorial(rank));

  MPI_Finalize();
  return 0;
}

