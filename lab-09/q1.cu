/**
 * Lab 9, Q1:
 * Write a program in CUDA to perform parallel Sparse Matrix - Vector
 * multiplication using compressed sparse row (CSR) storage format. Represent
 * the input sparse matrix in CSR format in the host code.
 */
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "matrix_utils.hpp"

__global__ void spmv_csr(int *data, int *col_index, int *row_ptr, int *X, int *Y, int num_rows) {
  int row = threadIdx.x + blockIdx.x * blockDim.x;
  if (row < num_rows) {
    int start = row_ptr[row];
    int end = row_ptr[row + 1];
    int sum = 0;
    for (int i = start; i < end; i++)
      sum += data[i] * X[col_index[i]];

    Y[row] = sum;
  }
}

int main() {
  int num_rows = 3;
  int num_elements = 6;

  int data[] = {2, 3, 4, 5, 6, 7};
  int col_index[] = {0, 2, 0, 1, 2, 2};
  int row_ptr[] = {0, 2, 5, 6};

  int X[] = {1, 2, 3};
  int Y[3] = {0};

  int *d_data, *d_col_index, *d_row_ptr, *d_X, *d_Y;
  cudaMalloc((void**)&d_data, num_elements * sizeof(int));
  cudaMalloc((void**)&d_col_index, num_elements * sizeof(int));
  cudaMalloc((void**)&d_row_ptr, (num_rows + 1) * sizeof(int));
  cudaMalloc((void**)&d_X, 3 * sizeof(int));
  cudaMalloc((void**)&d_Y, num_rows * sizeof(int));

  if (d_data && d_col_index && d_row_ptr && d_X && d_Y) {
    cudaMemcpy(d_data, data, num_elements * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_index, col_index, num_elements * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr, row_ptr, (num_rows + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_X, X, 3 * sizeof(int), cudaMemcpyHostToDevice);

    spmv_csr<<<1, num_rows>>>(d_data, d_col_index, d_row_ptr, d_X, d_Y, num_rows);
    cudaMemcpy(Y, d_Y, num_rows * sizeof(int), cudaMemcpyDeviceToHost);

    print_vector(Y, num_rows, "Resultant Vector Y:");
  }

  cudaFree(d_data);
  cudaFree(d_col_index);
  cudaFree(d_row_ptr);
  cudaFree(d_X);
  cudaFree(d_Y);

  return 0;
}
