#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  char *str1 = NULL, *str2 = NULL, *result_str = NULL;
  int len = 0;
  int chunk_len = 0;

  if (rank == 0) {
    puts("Enter length of strings (must be divisible by number of processes):");
    scanf("%d", &len);
    chunk_len = len / size;

    str1 = malloc((len + 1) * sizeof(char));
    str2 = malloc((len + 1) * sizeof(char));
    result_str = malloc((2 * len + 1) * sizeof(char));

    if (str1 && str2) {
      puts("Enter String 1:");
      scanf(" %[^\n]s", str1);
      puts("Enter String 2:");
      scanf(" %[^\n]s", str2);
    }
  }

  // Broadcast chunk length
  MPI_Bcast(&chunk_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

  char *local_s1 = malloc(chunk_len * sizeof(char));
  char *local_s2 = malloc(chunk_len * sizeof(char));
  char *local_res = malloc((2 * chunk_len) * sizeof(char));

  if (local_s1 && local_s2) {
    // Scatter both strings
    MPI_Scatter(str1, chunk_len, MPI_CHAR, local_s1, chunk_len, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(str2, chunk_len, MPI_CHAR, local_s2, chunk_len, MPI_CHAR, 0, MPI_COMM_WORLD);
  }

  // Interleave locally
  for (int i = 0; i < chunk_len; i++) {
    local_res[2 * i] = local_s1[i];
    local_res[2 * i + 1] = local_s2[i];
  }

  // Gather result (note: we gather 2*chunk_len characters per process)
  MPI_Gather(local_res, 2 * chunk_len, MPI_CHAR, result_str, 2 * chunk_len, MPI_CHAR, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    result_str[2 * len] = '\0'; // Null terminate result
    printf("Resultant String: %s\n", result_str);
    
    free(str1);
    free(str2);
    free(result_str);
  }

  free(local_s1);
  free(local_s2);
  free(local_res);

  MPI_Finalize();
  return 0;
}