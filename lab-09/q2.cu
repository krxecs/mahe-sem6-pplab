/**
 * Lab 9, Q2:
 * Write a program in CUDA to read MXN matrix A and replace 1st row of this
 * matrix by same elements, 2nd row elements by square of each element and 3rd
 * row elements by cube of each element and so on.
 */
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "matrix_utils.hpp"

__global__ void replace_row_powers(int *A, int *B, int M, int N) {
  int col = threadIdx.x + blockIdx.x * blockDim.x;
  int row = threadIdx.y + blockIdx.y * blockDim.y;

  if (row < M && col < N) {
    int val = A[row * N + col];
    int res = 1;
    for (int i = 0; i <= row; i++)
      res *= val;

    B[row * N + col] = res;
  }
}

int main() {
  int M = 3, N = 3;
  int A[] = {
    2, 3, 4,
    2, 3, 4,
    2, 3, 4
  };
  int B[9] = {0};

  int *d_A, *d_B;
  cudaMalloc((void**)&d_A, M * N * sizeof(int));
  cudaMalloc((void**)&d_B, M * N * sizeof(int));

  if (d_A && d_B) {
    cudaMemcpy(d_A, A, M * N * sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(3, 3);
    dim3 numBlocks(1, 1);
    replace_row_powers<<<numBlocks, threadsPerBlock>>>(d_A, d_B, M, N);

    cudaMemcpy(B, d_B, M * N * sizeof(int), cudaMemcpyDeviceToHost);

    print_matrix(B, M, N, "Output Matrix B:");
  }

  cudaFree(d_A);
  cudaFree(d_B);

  return 0;
}
