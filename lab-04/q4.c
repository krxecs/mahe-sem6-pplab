#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  char *input_word = NULL;

  if (rank == 0) {
    // Allocate generous buffer for input
    input_word = malloc(100);
    puts("Enter the word:");
    scanf("%s", input_word);

    int N = strlen(input_word);
    
    // Ensure the word length matches the number of processes
    if (N != size) {
      printf("Error: Word length (%d) must match number of processes (%d).\n", N, size);
      MPI_Abort(MPI_COMM_WORLD, 1);
    }
  }

  char recv_char;
  // Scatter 1 character to each process
  MPI_Scatter(input_word, 1, MPI_CHAR, &recv_char, 1, MPI_CHAR, 0, MPI_COMM_WORLD);

  // Each process creates a string repeating the char (rank + 1) times
  int repeat_count = rank + 1;
  char *local_str = malloc(repeat_count);
  
  // Check malloc success
  if (!local_str)
    MPI_Abort(MPI_COMM_WORLD, 1);

  for (int i = 0; i < repeat_count; i++)
    local_str[i] = recv_char;

  // Prepare for Gatherv in root
  char *result_str = NULL;
  int *recvcounts = NULL;
  int *displs = NULL;

  if (rank == 0) {
    // Total length = 1 + 2 + ... + N = N(N+1)/2
    int total_len = (size * (size + 1)) / 2;
    
    result_str = malloc((total_len + 1));
    recvcounts = malloc(size * sizeof(int));
    displs = malloc(size * sizeof(int));

    if (!result_str || !recvcounts || !displs)
      MPI_Abort(MPI_COMM_WORLD, 1);

    int current_disp = 0;
    for (int i = 0; i < size; i++) {
      recvcounts[i] = i + 1;    // Process i sends i+1 chars
      displs[i] = current_disp;   // Displacement
      current_disp += recvcounts[i];
    }
    result_str[total_len] = '\0'; // Null terminator
  }

  // Use Gatherv because each process sends a different amount of data
  MPI_Gatherv(local_str, repeat_count, MPI_CHAR,
        result_str, recvcounts, displs, MPI_CHAR,
        0, MPI_COMM_WORLD);

  if (rank == 0) {
    printf("Output: %s\n", result_str);
    
    // Cleanup
    free(recvcounts);
    free(displs);
    free(result_str);
    free(input_word);
  }

  free(local_str);
  MPI_Finalize();
  return 0;
}