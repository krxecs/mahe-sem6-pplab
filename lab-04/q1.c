#include <stdio.h>
#include <mpi.h>

// Helper to check error codes
void check_error(int error_code, const char* msg) {
  if (error_code != MPI_SUCCESS) {
    char error_string[MPI_MAX_ERROR_STRING];
    int length_of_error_string;
    MPI_Error_string(error_code, error_string, &length_of_error_string);
    printf("Error during %s: %s\n", msg, error_string);
  }
}

int main(int argc, char* argv[]) {
  // Initialize MPI environment
  MPI_Init(&argc, &argv);

  // Set the error handler to return errors instead of aborting (ERRORS_ARE_FATAL is default)
  MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);

  int rank, size;
  check_error(MPI_Comm_rank(MPI_COMM_WORLD, &rank), "MPI_Comm_rank");
  check_error(MPI_Comm_size(MPI_COMM_WORLD, &size), "MPI_Comm_size");

  // Calculate factorial for the current process (rank + 1)!
  int local_fact = 1;
  for (int i = 1; i <= rank + 1; i++)
    local_fact *= i;

  int partial_sum = 0;
  
  // MPI_Scan performs a prefix reduction.
  // Process i receives the sum of factorials from process 0 to i.
  int err = MPI_Scan(&local_fact, &partial_sum, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
  check_error(err, "MPI_Scan");

  // The last process holds the sum of all factorials (1! + ... + N!)
  if (rank == size - 1)
    printf("Sum of factorials (1! + ... + %d!) = %d\n", size, partial_sum);

  MPI_Finalize();
  return 0;
}