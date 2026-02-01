#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int puts_e(const char *s) {
  return fputs(s, stderr);
}

int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int received_val;

  if (rank == 0) {
    puts("Enter elements equal to the number of processes:");
    
    int *data = malloc(sizeof(int) * size);
    if (!data) {
      puts_e("Memory allocation failed");
      MPI_Abort(MPI_COMM_WORLD, 1);
    }

    for (int i = 0; i < size; i++)
      scanf("%d", &data[i]);

    int buffer_size = (size - 1) * (sizeof(int) + MPI_BSEND_OVERHEAD);
    void *buffer = malloc(buffer_size);
    if (!buffer) {
      free(data);
      puts_e("Buffer allocation failed");
      MPI_Abort(MPI_COMM_WORLD, 1);
    }
    
    MPI_Buffer_attach(buffer, buffer_size);

    for (int i = 1; i < size; i++)
      MPI_Bsend(&data[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);

    received_val = data[0];
    
    int size_returned;
    void *buffer_ptr;
    MPI_Buffer_detach(&buffer_ptr, &size_returned);
    
    free(buffer);
    free(data);
  } else {
    MPI_Recv(&received_val, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  }

  int result;
  if (rank % 2 == 0) {
    result = received_val * received_val;
    printf("Rank %d (Even): Square of %d is %d\n", rank, received_val, result);
  } else {
    result = received_val * received_val * received_val;
    printf("Rank %d (Odd): Cube of %d is %d\n", rank, received_val, result);
  }

  MPI_Finalize();
  return 0;
}
