#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int M;
  int *full_array = NULL;
  double *gathered_avgs = NULL;

  if (rank == 0) {
    puts("Enter value for M (elements per process):");
    scanf("%d", &M);
  }

  // Broadcast M to all processes so they know how much to receive
  MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    int total_elements = size * M;
    full_array = malloc(total_elements * sizeof(int));
    gathered_avgs = malloc(size * sizeof(double));
    
    if (full_array && gathered_avgs) {
      printf("Enter %d elements:\n", total_elements);
      for (int i = 0; i < total_elements; i++)
        scanf("%d", &full_array[i]);
    }
  }

  int *local_arr = (int*)malloc(M * sizeof(int));
  
  // Scatter M integers to each process
  if (local_arr)
    MPI_Scatter(full_array, M, MPI_INT, local_arr, M, MPI_INT, 0, MPI_COMM_WORLD);

  double local_sum = 0;
  for (int i = 0; i < M; i++)
    local_sum += local_arr[i];

  double local_avg = local_sum / M;
  printf("Process %d: Average = %.2f\n", rank, local_avg);

  // Gather averages to root
  MPI_Gather(&local_avg, 1, MPI_DOUBLE, gathered_avgs, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    double total_avg_sum = 0;
    for (int i = 0; i < size; i++)
      total_avg_sum += gathered_avgs[i];

    double final_avg = total_avg_sum / size;
    printf("Total average of all averages: %.2f\n", final_avg);

    free(full_array);
    free(gathered_avgs);
  }

  free(local_arr);

  MPI_Finalize();
  return 0;
}
