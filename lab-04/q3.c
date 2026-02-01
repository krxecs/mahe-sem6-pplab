#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (size != 4) {
    if (rank == 0)
      puts("Error: This program requires exactly 4 processes.");

    MPI_Finalize();
    return 1;
  }

  int matrix[4][4];
  int input_row[4];
  int output_row[4];
  int result_matrix[4][4];

  if (rank == 0) {
    puts("Enter the 4x4 matrix elements:");
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++)
        scanf("%d", &matrix[i][j]);
  }

  // 1. Scatter the rows: Process i gets row i
  // We send 4 integers to each process
  MPI_Scatter(matrix, 4, MPI_INT, input_row, 4, MPI_INT, 0, MPI_COMM_WORLD);

  // 2. Perform Prefix Sum (Scan)
  // MPI_Scan with count=4 performs element-wise addition across ranks.
  // Rank 0 result: Row 0
  // Rank 1 result: Row 0 + Row 1
  // ...
  // Rank 3 result: Row 0 + Row 1 + Row 2 + Row 3
  MPI_Scan(input_row, output_row, 4, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

  // 3. Gather the calculated rows back to the root
  MPI_Gather(output_row, 4, MPI_INT, result_matrix, 4, MPI_INT, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    puts("Output Matrix:");
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++)
        printf("%d ", result_matrix[i][j]);

      puts("");
    }
  }

  MPI_Finalize();
  return 0;
}
