#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define MAX_MASK_WIDTH 21

// Constant memory declaration
__constant__ int d_M[MAX_MASK_WIDTH];

__global__ void convolution_1D_constant_kernel(int *N, int *P, int width, int maskWidth) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;

  if (i < width) {
    int Pvalue = 0;
    int start_point = i - (maskWidth / 2);

    for (int j = 0; j < maskWidth; j++) {
      if (start_point + j >= 0 && start_point + j < width) {
        Pvalue += N[start_point + j] * d_M[j];
      }
    }
    P[i] = Pvalue;
  }
}

int main() {
  int width, maskWidth;
  printf("Enter the size of the input array: ");
  scanf("%d", &width);
  printf("Enter the size of the mask (should be odd): ");
  scanf("%d", &maskWidth);

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

  int *d_N, *d_P;

  cudaMalloc((void**)&d_N, width * sizeof(int));
  cudaMalloc((void**)&d_P, width * sizeof(int));

  if (d_N && d_P) {
    cudaMemcpy(d_N, N, width * sizeof(int), cudaMemcpyHostToDevice);

    // Copy mask to constant memory
    cudaMemcpyToSymbol(d_M, M, maskWidth * sizeof(int));

    convolution_1D_constant_kernel<<<(width + 255) / 256, 256>>>(d_N, d_P, width, maskWidth);

    cudaMemcpy(P, d_P, width * sizeof(int), cudaMemcpyDeviceToHost);

    puts("Resultant Array P (Constant Memory):");
    for (int i = 0; i < width; i++) {
      printf("%d ", P[i]);
    }
    puts("");
  }

  cudaFree(d_N);
  cudaFree(d_P);

  free(N);
  free(M);
  free(P);

  return 0;
}
