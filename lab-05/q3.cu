/*
 * Lab 5 - Question 3
 * Process 1D array of angles (radians) to compute sine values
 */

#include <stdio.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256
#define PI 3.14159265358979323846

__global__ void computeSine(float *angles, float *sines, int n) {
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n) {
    // Use sinf() for single-precision floating point
    sines[idx] = sinf(angles[idx]);
  }
}

void checkCudaError(cudaError_t err, const char *msg) {
  if (err != cudaSuccess) {
    fprintf(stderr, "CUDA Error: %s - %s\n", msg, cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }
}

int main() {
  int n = 1000;
  size_t bytes = n * sizeof(float);
  
  // Calculate grid size
  int gridSize = (n + BLOCK_SIZE - 1) / BLOCK_SIZE;
  
  printf("Sine Computation on 1D Array\n");
  printf("N = %d elements\n", n);
  printf("Block size: %d\n", BLOCK_SIZE);
  printf("Grid size: %d\n\n", gridSize);
  
  // Host arrays
  float *h_angles = (float*)malloc(bytes);
  float *h_sines = (float*)malloc(bytes);
  float *h_sines_cpu = (float*)malloc(bytes);  // For verification
  
  // Initialize angles array (0 to 2*PI)
  for (int i = 0; i < n; i++) {
    h_angles[i] = (2.0f * PI * i) / n;
  }
  
  // Compute sine on CPU for verification
  for (int i = 0; i < n; i++) {
    h_sines_cpu[i] = sinf(h_angles[i]);
  }
  
  // Device arrays
  float *d_angles, *d_sines;
  checkCudaError(cudaMalloc(&d_angles, bytes), "cudaMalloc d_angles");
  checkCudaError(cudaMalloc(&d_sines, bytes), "cudaMalloc d_sines");
  
  // Copy angles to device
  checkCudaError(cudaMemcpy(d_angles, h_angles, bytes, cudaMemcpyHostToDevice), 
           "cudaMemcpy h_angles to d_angles");
  
  // Launch kernel
  computeSine<<<gridSize, BLOCK_SIZE>>>(d_angles, d_sines, n);
  checkCudaError(cudaGetLastError(), "Kernel launch");
  checkCudaError(cudaDeviceSynchronize(), "Kernel execution");
  
  // Copy result back to host
  checkCudaError(cudaMemcpy(h_sines, d_sines, bytes, cudaMemcpyDeviceToHost), 
           "cudaMemcpy d_sines to h_sines");
  
  // Display some results
  printf("Sample results (first 10 values):\n");
  printf("%-10s %-15s %-15s %-15s\n", "Index", "Angle (rad)", "sin(angle)", "CPU ref");
  printf("-----------------------------------------------------------\n");
  for (int i = 0; i < 10 && i < n; i++) {
    printf("%-10d %-15.6f %-15.6f %-15.6f\n", 
         i, h_angles[i], h_sines[i], h_sines_cpu[i]);
  }
  printf("\n");
  
  // Display some special angles
  printf("Special angles:\n");
  int special_indices[] = {0, n/4, n/2, 3*n/4};
  char *special_names[] = {"0", "π/2", "π", "3π/2"};
  for (int i = 0; i < 4; i++) {
    int idx = special_indices[i];
    if (idx < n) {
      printf("sin(%-4s) ≈ sin(%.6f) = %.6f\n", 
           special_names[i], h_angles[idx], h_sines[idx]);
    }
  }
  printf("\n");
  
  // Verify correctness
  bool correct = true;
  float max_error = 0.0f;
  for (int i = 0; i < n; i++) {
    float error = fabs(h_sines[i] - h_sines_cpu[i]);
    if (error > max_error) {
      max_error = error;
    }
    if (error > 1e-5) {
      correct = false;
      printf("Error at index %d: GPU=%.6f, CPU=%.6f, diff=%.6e\n", 
           i, h_sines[i], h_sines_cpu[i], error);
      break;
    }
  }
  
  printf("Maximum error: %.6e\n", max_error);
  printf("Result: %s\n", correct ? "CORRECT" : "INCORRECT");
  
  // Cleanup
  cudaFree(d_angles);
  cudaFree(d_sines);
  free(h_angles);
  free(h_sines);
  free(h_sines_cpu);
  
  return 0;
}
