#include <stdio.h>
#include <mpi.h>

// Calculates factorial of a number
long long factorial(int n) {
  long long fact = 1;
  for (int i = 1; i <= n; i++)
    fact *= i;

  return fact;
}

int main(int argc, char* argv[]) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int send_buf[size];
  int recv_val;
  long long gathered_facts[size];

  if (rank == 0) {
    printf("Enter %d values:\n", size);
    for (int i = 0; i < size; i++)
      scanf("%d", &send_buf[i]);
  }

  // Scatter 1 integer to each process
  MPI_Scatter(send_buf, 1, MPI_INT, &recv_val, 1, MPI_INT, 0, MPI_COMM_WORLD);

  // Calculate factorial locally
  long long local_fact = factorial(recv_val);
  printf("Process %d: calculated factorial of %d is %lld\n", rank, recv_val, local_fact);

  // Gather factorials back to root
  MPI_Gather(&local_fact, 1, MPI_LONG_LONG_INT, gathered_facts, 1, MPI_LONG_LONG_INT, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    long long total_sum = 0;
    puts("Gathered factorials in root:");
    for (int i = 0; i < size; i++) {
      printf("%lld ", gathered_facts[i]);
      total_sum += gathered_facts[i];
    }
    printf("\nSum of all factorials: %lld\n", total_sum);
  }

  MPI_Finalize();
  return 0;
}
