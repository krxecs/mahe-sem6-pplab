#include <cuda_runtime.h>
#include <iostream>

__global__ void generate_pattern(const char *S, char *RS, int N) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  if (tid < N) {
    // Calculate the starting index in RS for this thread's substring
    int start_idx = tid * N - (tid - 1) * tid / 2;
    int copy_len = N - tid;

    // Copy the required number of characters from S to RS
    for (int i = 0; i < copy_len; i++)
      RS[start_idx + i] = S[i];

    // Let the first thread set the null terminator for the final string
    if (tid == 0) {
      int total_len = N * (N + 1) / 2;
      RS[total_len] = '\0';
    }
  }
}

int main() {
  std::string h_S;

  std::cout << "Enter string S: ";
  std::getline(std::cin, h_S);

  int N = h_S.length();
  int total_len = N * (N + 1) / 2;

  char *d_S, *d_RS;
  cudaMalloc((void **)&d_S, N + 1);
  cudaMalloc((void **)&d_RS, total_len + 1);

  if (d_S && d_RS) {
    cudaMemcpy(d_S, h_S.c_str(), N + 1, cudaMemcpyHostToDevice);

    int threads_per_block = 256;
    int blocks = (N + threads_per_block - 1) / threads_per_block;

    generate_pattern<<<blocks, threads_per_block>>>(d_S, d_RS, N);
    cudaDeviceSynchronize();

    char h_RS[256];
    cudaMemcpy(h_RS, d_RS, total_len + 1, cudaMemcpyDeviceToHost);

    std::cout << "Output String RS: " << h_RS << std::endl;
  }

  cudaFree(d_S);
  cudaFree(d_RS);

  return 0;
}
