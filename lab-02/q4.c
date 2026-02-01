#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int value;
    int next_rank = (rank + 1) % size;
    int prev_rank = (rank == 0) ? size - 1 : rank - 1;

    if (rank == 0) {
        puts("Enter an integer value:");
        scanf("%d", &value);
        
        value++;
        MPI_Send(&value, 1, MPI_INT, next_rank, 0, MPI_COMM_WORLD);
        printf("Rank %d sent value %d to Rank %d\n", rank, value, next_rank);

        MPI_Recv(&value, 1, MPI_INT, prev_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Rank %d received final value %d from Rank %d\n", rank, value, prev_rank);
    } else {
        MPI_Recv(&value, 1, MPI_INT, prev_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Rank %d received value %d from Rank %d\n", rank, value, prev_rank);

        value++;
        MPI_Send(&value, 1, MPI_INT, next_rank, 0, MPI_COMM_WORLD);
        printf("Rank %d sent value %d to Rank %d\n", rank, value, next_rank);
    }

    MPI_Finalize();
    return 0;
}
