#include <mpi.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_LEN 100
#define TAG 0

int rank0(void) {
  char message[MAX_LEN] = "HelloMPI";

  printf("Rank 0: Sending message '%s' to Rank 1...\n", message);

  MPI_Ssend(message, strlen(message) + 1, MPI_CHAR, 1, TAG, MPI_COMM_WORLD);

  char received_buffer[MAX_LEN];
  MPI_Status status;

  MPI_Recv(received_buffer, MAX_LEN, MPI_CHAR, 1, TAG, MPI_COMM_WORLD, &status);

  printf("Rank 0: Received modified message back: '%s'\n", received_buffer);

  MPI_Finalize();
  return 0;
}

int rank1(void) {
  char buffer[MAX_LEN];
  MPI_Status status;

  MPI_Recv(buffer, MAX_LEN, MPI_CHAR, 0, TAG, MPI_COMM_WORLD, &status);

  printf("Rank 1: Received '%s'. Toggling case...\n", buffer);

  for (int i = 0; buffer[i]; i++) {
    if (isupper(buffer[i]))
      buffer[i] = tolower(buffer[i]);
    else if (islower(buffer[i]))
      buffer[i] = toupper(buffer[i]);
  }

  MPI_Ssend(buffer, strlen(buffer) + 1, MPI_CHAR, 0, TAG, MPI_COMM_WORLD);

  MPI_Finalize();
  return 0;
}

int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (size != 2) {
    if (rank == 0)
      puts("Error: This program requires exactly 2 processes.");

    MPI_Finalize();
    return 1;
  }

  return rank ? rank1() : rank0();
}