/**
 * Lab 9, Q3:
 * Write a CUDA program that reads a matrix A of size MXN and produce an output
 * matrix B of same size such that it replaces all the non-border elements
 * (numbers in bold) of A with its equivalent 1’s complement and remaining
 * elements same as matrix A.
 */
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "matrix_utils.hpp"

// Calculates binary 1's complement and formats it as an integer literal
__device__ int custom_ones_comp(int num) {
  if (num == 0) return 1;
  int temp = num;
  int bits = 0;
  for (; temp > 0; temp /= 2)
    bits++;

  int mask = (1 << bits) - 1;
  int comp = (~num) & mask;

  int res = 0;
  int mult = 1;
  for (int i = 0; i < bits; i++) {
    int bit = comp % 2;
    res += bit * mult;
    mult *= 10;
    comp /= 2;
  }
  return res;
}

__global__ void replace_inner_ones_comp(int *A, int *B, int M, int N) {
  int col = threadIdx.x + blockIdx.x * blockDim.x;
  int row = threadIdx.y + blockIdx.y * blockDim.y;

  if (row < M && col < N) {
    if (row == 0 || row == M - 1 || col == 0 || col == N - 1)
      B[row * N + col] = A[row * N + col];
    else
      B[row * N + col] = custom_ones_comp(A[row * N + col]);
  }
}

int main() {
  int M = 4, N = 4;
  int A[] = {
    1, 2,  3, 4,
    6, 5,  8, 3,
    2, 4, 10, 1,
    9, 1,  2, 5
  };
  int B[16] = {0};

  int *d_A, *d_B;
  cudaMalloc((void**)&d_A, M * N * sizeof(int));
  cudaMalloc((void**)&d_B, M * N * sizeof(int));

  if (d_A && d_B) {
    cudaMemcpy(d_A, A, M * N * sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(4, 4);
    dim3 numBlocks(1, 1);
    replace_inner_ones_comp<<<numBlocks, threadsPerBlock>>>(d_A, d_B, M, N);

    cudaMemcpy(B, d_B, M * N * sizeof(int), cudaMemcpyDeviceToHost);

    print_matrix(B, M, N, "Output Matrix B:");
  }

  cudaFree(d_A);
  cudaFree(d_B);

  return 0;
}
