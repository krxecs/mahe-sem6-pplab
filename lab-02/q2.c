#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);

  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  int size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (size < 2) {
    if (rank == 0)
      puts("Error: This program requires at least 2 processes.");

    MPI_Finalize();
    return 1;
  }

  static const int TAG = 0;

  if (rank == 0) {
    int number_to_send = 42;
    printf("Master (Rank 0): Sending number %d to %d slaves.\n", number_to_send, size - 1);

    for (int i = 1; i < size; i++)
      MPI_Send(&number_to_send, 1, MPI_INT, i, TAG, MPI_COMM_WORLD);

  } else {
    int received_number;
    MPI_Recv(&received_number, 1, MPI_INT, 0, TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    
    printf("Slave (Rank %d): Received number %d.\n", rank, received_number);
  }

  MPI_Finalize();
  return 0;
}