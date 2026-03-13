#include <cuda_runtime.h>
#include <stdio.h>

__global__ void selectionSort(int *arr, int *out, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i >= n)
    return;

  int val = arr[i];
  int rank = 0;

  for (int j = 0; j < n; j++) {
    if (arr[j] < val || (arr[j] == val && j < i))
      rank++;
  }
  out[rank] = val;
}

int main() {
  constexpr int SS_N = 8;
  int h_arr[SS_N] = {64, 25, 12, 22, 11, 90, 45, 33};
  int h_out[SS_N] = {0};

  int *d_arr, *d_out;
  cudaMalloc(&d_arr, sizeof h_arr);
  cudaMalloc(&d_out, sizeof h_out);

  cudaMemcpy(d_arr, h_arr, sizeof h_arr, cudaMemcpyHostToDevice);

  selectionSort<<<1, SS_N>>>(d_arr, d_out, SS_N);
  cudaDeviceSynchronize();

  cudaMemcpy(h_out, d_out, sizeof h_out, cudaMemcpyDeviceToHost);

  printf("Input: ");
  for (int x : h_arr)
    printf("%d ", x);
  printf("\nSorted: ");
  for (int x : h_out)
    printf("%d ", x);
  puts("");

  cudaFree(d_arr);
  cudaFree(d_out);
  return 0;
}
