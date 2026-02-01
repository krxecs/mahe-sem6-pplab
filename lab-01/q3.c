#include <ctype.h>
#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main (int argc, char *argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  char str[] = "HELLO";

  if (strlen(str) < size) {
    puts("Specify size >= strlen(str)");
    MPI_Finalize();
    return 1;
  }

  str[rank] = isupper(str[rank]) ? tolower(str[rank]) : toupper(str[rank]);

  printf("Process %i of %i: New string = %s\n", rank, size, str);

  MPI_Finalize();
  return 0;
}

