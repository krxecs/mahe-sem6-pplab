#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void MatMulStandard(int *a, int *b, int *c, int width) {
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  if (row < width && col < width) {
    int Pvalue = 0;
    for (int k = 0; k < width; k++) {
      Pvalue += a[row * width + k] * b[k * width + col];
    }
    c[row * width + col] = Pvalue;
  }
}

int main() {
  int width;
  printf("Enter the matrix size (e.g., 4 for 4x4): ");
  scanf("%d", &width);

  // Allocate memory for matrices
  int *matA = (int *)malloc(sizeof(int) * width * width);
  int *matB = (int *)malloc(sizeof(int) * width * width);
  int *matProd = (int *)malloc(sizeof(int) * width * width);

  printf("Enter elements of Matrix A (%d elements):\n", width * width);
  for (int i = 0; i < width * width; i++) {
    scanf("%d", &matA[i]);
  }

  printf("Enter elements of Matrix B (%d elements):\n", width * width);
  for (int i = 0; i < width * width; i++) {
    scanf("%d", &matB[i]);
  }

  int size = sizeof(int) * width * width;
  int *da, *db, *dc;

  cudaMalloc((void **) &da, size);
  cudaMalloc((void **) &db, size);
  cudaMalloc((void **) &dc, size);

  if (da && db && dc) {
    cudaMemcpy(da, matA, size, cudaMemcpyHostToDevice);
    cudaMemcpy(db, matB, size, cudaMemcpyHostToDevice);

    int blockSize = 2;
    dim3 dimBlock(blockSize, blockSize);
    dim3 dimGrid((width + blockSize - 1) / blockSize, (width + blockSize - 1) / blockSize);

    MatMulStandard<<<dimGrid, dimBlock>>>(da, db, dc, width);

    cudaMemcpy(matProd, dc, size, cudaMemcpyDeviceToHost);

    puts("Result of Standard Matrix Multiplication:");
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < width; j++) {
        printf("%d\t", matProd[i * width + j]);
      }
      puts("");
    }
  }

  cudaFree(da);
  cudaFree(db);
  cudaFree(dc);

  free(matA);
  free(matB);
  free(matProd);

  return 0;
}
