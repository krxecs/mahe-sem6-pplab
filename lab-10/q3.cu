#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define MAX_TILE_SIZE 256

__global__ void convolution_1D_tiled_kernel(int *N, int *M, int *P, int width, int maskWidth, int tileSize) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;

  extern __shared__ int N_s[];

  int n = maskWidth / 2;
  int halo_left = (blockIdx.x * blockDim.x) - n + threadIdx.x;

  // Load regular tile elements + left halo
  if (halo_left >= 0 && halo_left < width) {
    N_s[threadIdx.x] = N[halo_left];
  } else {
    N_s[threadIdx.x] = 0;
  }

  // Load right halo elements
  if (threadIdx.x < maskWidth - 1) {
    int halo_right = (blockIdx.x * blockDim.x) + tileSize + threadIdx.x;
    if (halo_right >= 0 && halo_right < width) {
      N_s[threadIdx.x + tileSize] = N[halo_right];
    } else {
      N_s[threadIdx.x + tileSize] = 0;
    }
  }

  __syncthreads();

  if (i < width) {
    int Pvalue = 0;
    for (int j = 0; j < maskWidth; j++) {
      Pvalue += N_s[threadIdx.x + j] * M[j];
    }
    P[i] = Pvalue;
  }
}

int main() {
  int width, maskWidth, tileSize;
  printf("Enter the size of the input array: ");
  scanf("%d", &width);
  printf("Enter the size of the mask (should be odd): ");
  scanf("%d", &maskWidth);
  printf("Enter the tile size (block size): ");
  scanf("%d", &tileSize);

  int *N = (int *)malloc(sizeof(int) * width);
  int *M = (int *)malloc(sizeof(int) * maskWidth);
  int *P = (int *)malloc(sizeof(int) * width);

  printf("Enter %d elements of the input array:\n", width);
  for (int i = 0; i < width; i++) {
    scanf("%d", &N[i]);
  }

  printf("Enter %d elements of the mask:\n", maskWidth);
  for (int i = 0; i < maskWidth; i++) {
    scanf("%d", &M[i]);
  }

  int *d_N, *d_M, *d_P;

  cudaMalloc((void**)&d_N, width * sizeof(int));
  cudaMalloc((void**)&d_M, maskWidth * sizeof(int));
  cudaMalloc((void**)&d_P, width * sizeof(int));

  if (d_N && d_M && d_P) {
    cudaMemcpy(d_N, N, width * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, maskWidth * sizeof(int), cudaMemcpyHostToDevice);

    int sharedMemSize = (tileSize + maskWidth - 1) * sizeof(int);
    dim3 dimGrid((width + tileSize - 1) / tileSize);
    dim3 dimBlock(tileSize);
    convolution_1D_tiled_kernel<<<dimGrid, dimBlock, sharedMemSize>>>(d_N, d_M, d_P, width, maskWidth, tileSize);

    cudaMemcpy(P, d_P, width * sizeof(int), cudaMemcpyDeviceToHost);

    puts("Resultant Array P (Tiled Shared Memory):");
    for (int i = 0; i < width; i++) {
      printf("%d ", P[i]);
    }
    puts("");
  }

  cudaFree(d_N);
  cudaFree(d_M);
  cudaFree(d_P);

  free(N);
  free(M);
  free(P);

  return 0;
}
