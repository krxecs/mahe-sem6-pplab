#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <mpi.h>

int is_vowel(char c) {
  c = tolower(c);
  return (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u');
}

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  char *full_str = NULL;
  int len = 0;
  int local_len = 0;
  int *gathered_counts = NULL;

  if (rank == 0) {
    puts("Enter string length (must be divisible by number of processes):");
    scanf("%d", &len);
    
    full_str = malloc((len + 1) * sizeof(char));
    if (full_str) {
      puts("Enter the string:");
      scanf(" %[^\n]s", full_str);
    }
    local_len = len / size;
  }

  // Broadcast local length to all
  MPI_Bcast(&local_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

  char *local_str = malloc((local_len + 1) * sizeof(char));
  
  // Scatter the string chunks
  if (local_str) {
    MPI_Scatter(full_str, local_len, MPI_CHAR, local_str, local_len, MPI_CHAR, 0, MPI_COMM_WORLD);
    local_str[local_len] = '\0'; // Null terminate local chunk for safety
  }

  int local_non_vowels = 0;
  for (int i = 0; i < local_len; i++) {
    if (isalpha(local_str[i]) && !is_vowel(local_str[i]))
      local_non_vowels++;
  }
  printf("Process %d: Found %d non-vowels in '%s'\n", rank, local_non_vowels, local_str);

  if (rank == 0)
    gathered_counts = malloc(size * sizeof(int));

  // Gather counts
  MPI_Gather(&local_non_vowels, 1, MPI_INT, gathered_counts, 1, MPI_INT, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    int total_non_vowels = 0;
    puts("\nResults:");
    for (int i = 0; i < size; i++) {
      printf("Process %d found: %d\n", i, gathered_counts[i]);
      total_non_vowels += gathered_counts[i];
    }
    printf("Total non-vowels: %d\n", total_non_vowels);

    free(full_str);
    free(gathered_counts);
  }
  
  free(local_str);

  MPI_Finalize();
  return 0;
}
