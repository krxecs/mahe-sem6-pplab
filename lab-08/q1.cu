#include <stdio.h>
#include <iostream>
#include <vector>
#include <cuda_runtime.h>

__global__ void add_row(int *A, int *B, int *C, int M, int N) {
  int row = threadIdx.x;
  if (row < M) {
    for (int j = 0; j < N; j++)
      C[row * N + j] = A[row * N + j] + B[row * N + j];
  }
}

__global__ void add_col(int *A, int *B, int *C, int M, int N) {
  int col = threadIdx.x;
  if (col < N) {
    for (int i = 0; i < M; i++)
      C[i * N + col] = A[i * N + col] + B[i * N + col];
  }
}

__global__ void add_elem(int *A, int *B, int *C, int M, int N) {
  int col = threadIdx.x;
  int row = blockIdx.x;
  if (row < M && col < N)
    C[row * N + col] = A[row * N + col] + B[row * N + col];
}

int main() {
  int M, N;
  std::cout << "Enter number of rows (M) and columns (N): ";
  std::cin >> M >> N;

  std::vector<int> A(M * N), B(M * N), C(M * N);

  std::cout << "Enter elements of Matrix A:\n";
  for (int i = 0; i < M * N; i++)
    std::cin >> A[i];

  std::cout << "Enter elements of Matrix B:\n";
  for (int i = 0; i < M * N; i++)
    std::cin >> B[i];

  size_t size = M * N * sizeof(int);
  int *d_A, *d_B, *d_C;
  cudaMalloc(&d_A, size);
  cudaMalloc(&d_B, size);
  cudaMalloc(&d_C, size);

  if (d_A && d_B && d_C) {
    cudaMemcpy(d_A, A.data(), size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), size, cudaMemcpyHostToDevice);

    auto print_result = [&]() {
      cudaMemcpy(C.data(), d_C, M * N * sizeof(int), cudaMemcpyDeviceToHost);
      for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++)
          std::cout << C[i * N + j] << " ";

        std::cout << "\n";
      }
    };

    std::cout << "\n--- Row-wise addition ---\n";
    add_row<<<1, M>>>(d_A, d_B, d_C, M, N);
    print_result();

    std::cout << "\n--- Column-wise addition ---\n";
    add_col<<<1, N>>>(d_A, d_B, d_C, M, N);
    print_result();

    std::cout << "\n--- Element-wise addition ---\n";
    add_elem<<<M, N>>>(d_A, d_B, d_C, M, N);
    print_result();
  }

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  return 0;
}
