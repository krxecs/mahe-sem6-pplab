/*
 * Lab 5 - Question 1
 * Vector addition using CUDA
 * a) Block size as N (all threads in one block)
 * b) N threads (one thread per block)
 */

#include <stdio.h>
#include <cuda_runtime.h>

// Kernel for approach (a): block size as N
__global__ void vectorAddBlockSizeN(float *a, float *b, float *c, int n) {
  int idx = threadIdx.x;
  if (idx < n) {
    c[idx] = a[idx] + b[idx];
  }
}

// Kernel for approach (b): N threads (1 thread per block)
__global__ void vectorAddNThreads(float *a, float *b, float *c, int n) {
  int idx = blockIdx.x;
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
  int n = 1024;
  size_t bytes = n * sizeof(float);
  
  // Host arrays
  float *h_a = (float*)malloc(bytes);
  float *h_b = (float*)malloc(bytes);
  float *h_c = (float*)malloc(bytes);
  
  // Initialize input arrays
  for (int i = 0; i < n; i++) {
    h_a[i] = i * 1.0f;
    h_b[i] = i * 2.0f;
  }
  
  // Device arrays
  float *d_a, *d_b, *d_c;
  checkCudaError(cudaMalloc(&d_a, bytes), "cudaMalloc d_a");
  checkCudaError(cudaMalloc(&d_b, bytes), "cudaMalloc d_b");
  checkCudaError(cudaMalloc(&d_c, bytes), "cudaMalloc d_c");
  
  // Copy data to device
  checkCudaError(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice), "cudaMemcpy h_a to d_a");
  checkCudaError(cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice), "cudaMemcpy h_b to d_b");
  
  printf("Vector Addition - N = %d\n\n", n);
  
  // Approach (a): Block size as N
  printf("Approach (a): Block size as N (1 block, %d threads)\n", n);
  vectorAddBlockSizeN<<<1, n>>>(d_a, d_b, d_c, n);
  checkCudaError(cudaGetLastError(), "Kernel launch (a)");
  checkCudaError(cudaDeviceSynchronize(), "Kernel execution (a)");
  
  // Copy result back to host
  checkCudaError(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost), "cudaMemcpy d_c to h_c");
  
  // Verify results (first 5 elements)
  printf("First 5 results: ");
  for (int i = 0; i < 5; i++) {
    printf("%.1f ", h_c[i]);
  }
  printf("\n\n");
  
  // Approach (b): N threads (1 thread per block)
  printf("Approach (b): N threads (%d blocks, 1 thread each)\n", n);
  vectorAddNThreads<<<n, 1>>>(d_a, d_b, d_c, n);
  checkCudaError(cudaGetLastError(), "Kernel launch (b)");
  checkCudaError(cudaDeviceSynchronize(), "Kernel execution (b)");
  
  // Copy result back to host
  checkCudaError(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost), "cudaMemcpy d_c to h_c");
  
  // Verify results (first 5 elements)
  printf("First 5 results: ");
  for (int i = 0; i < 5; i++) {
    printf("%.1f ", h_c[i]);
  }
  printf("\n\n");
  
  // Verify correctness
  bool correct = true;
  for (int i = 0; i < n; i++) {
    if (h_c[i] != h_a[i] + h_b[i]) {
      correct = false;
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
