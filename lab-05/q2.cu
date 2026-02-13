/*
 * Lab 5 - Question 2
 * Vector addition with fixed block size of 256 threads
 * Variable number of blocks to handle N elements
 */

#include <stdio.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

__global__ void vectorAdd(float *a, float *b, float *c, int n) {
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n) {
    c[idx] = a[idx] + b[idx];
  }
}

void checkCudaError(cudaError_t err, const char *msg) {
  if (err != cudaSuccess) {
    fprintf(stderr, "CUDA Error: %s - %s\n", msg, cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }
}

int main() {
  int n = 10000;  // Try various sizes
  size_t bytes = n * sizeof(float);
  
  // Calculate grid size (number of blocks)
  int gridSize = (n + BLOCK_SIZE - 1) / BLOCK_SIZE;
  
  printf("Vector Addition with Fixed Block Size\n");
  printf("N = %d elements\n", n);
  printf("Block size (threads per block): %d\n", BLOCK_SIZE);
  printf("Grid size (number of blocks): %d\n", gridSize);
  printf("Total threads launched: %d\n\n", gridSize * BLOCK_SIZE);
  
  // Host arrays
  float *h_a = (float*)malloc(bytes);
  float *h_b = (float*)malloc(bytes);
  float *h_c = (float*)malloc(bytes);
  
  // Initialize input arrays
  for (int i = 0; i < n; i++) {
    h_a[i] = i * 0.5f;
    h_b[i] = i * 1.5f;
  }
  
  // Device arrays
  float *d_a, *d_b, *d_c;
  checkCudaError(cudaMalloc(&d_a, bytes), "cudaMalloc d_a");
  checkCudaError(cudaMalloc(&d_b, bytes), "cudaMalloc d_b");
  checkCudaError(cudaMalloc(&d_c, bytes), "cudaMalloc d_c");
  
  // Copy data to device
  checkCudaError(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice), "cudaMemcpy h_a to d_a");
  checkCudaError(cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice), "cudaMemcpy h_b to d_b");
  
  // Launch kernel with calculated grid size and fixed block size
  vectorAdd<<<gridSize, BLOCK_SIZE>>>(d_a, d_b, d_c, n);
  checkCudaError(cudaGetLastError(), "Kernel launch");
  checkCudaError(cudaDeviceSynchronize(), "Kernel execution");
  
  // Copy result back to host
  checkCudaError(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost), "cudaMemcpy d_c to h_c");
  
  // Verify results
  printf("First 10 results:\n");
  for (int i = 0; i < 10 && i < n; i++) {
    printf("c[%d] = %.1f + %.1f = %.1f\n", i, h_a[i], h_b[i], h_c[i]);
  }
  printf("\n");
  
  // Check correctness
  bool correct = true;
  for (int i = 0; i < n; i++) {
    if (fabs(h_c[i] - (h_a[i] + h_b[i])) > 1e-5) {
      correct = false;
      printf("Error at index %d: expected %.1f, got %.1f\n", i, h_a[i] + h_b[i], h_c[i]);
      break;
    }
  }
  printf("Result: %s\n", correct ? "CORRECT" : "INCORRECT");
  
  // Cleanup
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  free(h_a);
  free(h_b);
  free(h_c);
  
  return 0;
}
