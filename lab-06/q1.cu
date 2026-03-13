#include <cuda_runtime.h>
#include <stdio.h>

constexpr int WIDTH = 8, MASK_WIDTH = 5, HALF_MASK = MASK_WIDTH / 2;

__constant__ float d_M[MASK_WIDTH];

__global__ void convolution1D(float *N, float *P, int width, int mask_width) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i >= width)
    return;

  float sum = 0.0f;
  int half = mask_width / 2;

  for (int j = 0; j < mask_width; j++) {
    int idx = i - half + j;
    if (idx >= 0 && idx < width)
      sum += N[idx] * d_M[j];
  }
  P[i] = sum;
}

int main() {
  float h_N[WIDTH] = {1, 2, 3, 4, 5, 6, 7, 8};
  float h_M[MASK_WIDTH] = {1, 2, 3, 2, 1};
  float h_P[WIDTH] = {0};

  float *d_N, *d_P;
  cudaMalloc(&d_N, sizeof h_N);
  cudaMalloc(&d_P, sizeof h_P);

  cudaMemcpy(d_N, h_N, sizeof h_N, cudaMemcpyHostToDevice);
  cudaMemcpyToSymbol(d_M, h_M, sizeof h_M);

  constexpr int threadsPerBlock = 256, blocks = (WIDTH + threadsPerBlock - 1) / threadsPerBlock;
  convolution1D<<<blocks, threadsPerBlock>>>(d_N, d_P, WIDTH, MASK_WIDTH);
  cudaDeviceSynchronize();

  cudaMemcpy(h_P, d_P, sizeof h_P, cudaMemcpyDeviceToHost);

  printf("Input  N: ");
  for (float x : h_N)
    printf("%.0f ", x);

  printf("\nMask   M: ");
  for (float x : h_M)
    printf("%.0f ", x);

  printf("\nOutput P: ");
  for (float x : h_P)
    printf("%.0f ", x);
  puts("");

  cudaFree(d_N);
  cudaFree(d_P);
  return 0;
}
