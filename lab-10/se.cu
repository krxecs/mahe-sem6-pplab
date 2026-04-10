#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void MatMulElementThreadShared(int *a, int *b, int *c, int width, int tileWidth) {
  extern __shared__ char sharedMem[];
  int *MDs = (int *)sharedMem;
  int *NDs = (int *)(sharedMem + tileWidth * tileWidth * sizeof(int));

  int bx = blockIdx.x;
  int by = blockIdx.y;
  int tx = threadIdx.x;
  int ty = threadIdx.y;

  int Row = by * tileWidth + ty;
  int Col = bx * tileWidth + tx;

  int Pvalue = 0;

  for (int m = 0; m < width / tileWidth; m++) {
    MDs[ty * tileWidth + tx] = a[Row * width + m * tileWidth + tx];
    NDs[ty * tileWidth + tx] = b[(m * tileWidth + ty) * width + Col];

    __syncthreads();

    for (int k = 0; k < tileWidth; k++) {
      Pvalue += MDs[ty * tileWidth + k] * NDs[k * tileWidth + tx];
    }

    __syncthreads();
  }
  c[Row * width + Col] = Pvalue;
}

int main() {
  int width, tileWidth;
  printf("Enter the matrix size (e.g., 4 for 4x4): ");
  scanf("%d", &width);
  printf("Enter the tile width (block size, e.g., 2): ");
  scanf("%d", &tileWidth);

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

    int sharedMemSize = 2 * tileWidth * tileWidth * sizeof(int);
    dim3 dimGrid(width / tileWidth, width / tileWidth);
    dim3 dimBlock(tileWidth, tileWidth);

    MatMulElementThreadShared<<<dimGrid, dimBlock, sharedMemSize>>>(da, db, dc, width, tileWidth);

    cudaMemcpy(matProd, dc, size, cudaMemcpyDeviceToHost);

    puts("Result of Tiled Matrix Multiplication:");
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
