#include <stdio.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  // Ensure we run with exactly 3 processes as per the problem statement
  if (size != 3) {
    if (rank == 0)
      puts("Error: This program requires exactly 3 processes.");

    MPI_Finalize();
    return 1;
  }

  int matrix[9]; // 3x3 matrix flattened
  int search_key;

  if (rank == 0) {
    puts("Enter the 3x3 matrix elements:");
    for (int i = 0; i < 9; i++)
      scanf("%d", &matrix[i]);

    puts("Enter the element to be searched:");
    scanf("%d", &search_key);
  }

  // Broadcast the search key to all processes so they know what to count
  MPI_Bcast(&search_key, 1, MPI_INT, 0, MPI_COMM_WORLD);

  // Buffer to hold one row (3 elements) per process
  int row_chunk[3];
  
  // Scatter 3 integers to each process
  // Process 0 gets row 0, Process 1 gets row 1, Process 2 gets row 2
  MPI_Scatter(matrix, 3, MPI_INT, row_chunk, 3, MPI_INT, 0, MPI_COMM_WORLD);

  int local_count = 0;
  for (int i = 0; i < 3; i++)
    if (row_chunk[i] == search_key)
      local_count++;
  
  // Optional: Print local findings for verification
  printf("Process %d found %d occurrence(s).\n", rank, local_count);

  // Reduce all local counts into a total count at the root
  int total_occurrences = 0;
  MPI_Reduce(&local_count, &total_occurrences, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

  if (rank == 0)
    printf("Total occurrences of %d in the matrix: %d\n", search_key, total_occurrences);

  MPI_Finalize();
  return 0;
}