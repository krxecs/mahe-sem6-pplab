#include <stdio.h>
#include <cuda_runtime.h>

__global__ void oddEvenPhase(int *arr, int n, int phase) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;

  int start = (i * 2) + phase;
  int next = start + 1;

  if (next < n && arr[start] > arr[next]) {
    int tmp = arr[start];
    arr[start] = arr[next];
    arr[next] = tmp;
  }
}

int main() {
  constexpr int OE_N = 8;
  int h_arr[OE_N] = {5, 3, 8, 1, 9, 2, 7, 4};

  int *d_arr;
  cudaMalloc(&d_arr, sizeof h_arr);
  cudaMemcpy(d_arr, h_arr, sizeof h_arr, cudaMemcpyHostToDevice);

  int threads = OE_N / 2, blocks = 1;

  printf("Input:  ");
  for (int x : h_arr)
    printf("%d ", x);
  puts("");

  for (int pass = 0; pass < OE_N; pass++) {
    int phase = pass % 2; // 0 = even phase, 1 = odd phase
    oddEvenPhase<<<blocks, threads>>>(d_arr, OE_N, phase);
    cudaDeviceSynchronize();
  }

  cudaMemcpy(h_arr, d_arr, sizeof h_arr, cudaMemcpyDeviceToHost);

  printf("Sorted: ");
  for (int x : h_arr)
    printf("%d ", x);
  puts("");

  cudaFree(d_arr);
  return 0;
}
