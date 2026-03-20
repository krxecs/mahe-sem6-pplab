#include <stdio.h>
#include <iostream>
#include <vector>
#include <cuda_runtime.h>

// a. Each row computed by one thread
__global__ void mul_row(int *A, int *B, int *C, int M, int N, int P) {
  int row = threadIdx.x;
  if (row < M) {
    for (int j = 0; j < P; j++) {
      int sum = 0;
      for (int k = 0; k < N; k++)
        sum += A[row * N + k] * B[k * P + j];

      C[row * P + j] = sum;
    }
  }
}

// b. Each column computed by one thread
__global__ void mul_col(int *A, int *B, int *C, int M, int N, int P) {
  int col = threadIdx.x;
  if (col < P) {
    for (int i = 0; i < M; i++) {
      int sum = 0;
      for (int k = 0; k < N; k++)
        sum += A[i * N + k] * B[k * P + col];

      C[i * P + col] = sum;
    }
  }
}

// c. Each element computed by one thread
__global__ void mul_elem(int *A, int *B, int *C, int M, int N, int P) {
  int col = threadIdx.x;
  int row = blockIdx.x;
  if (row < M && col < P) {
    int sum = 0;
    for (int k = 0; k < N; k++)
      sum += A[row * N + k] * B[k * P + col];

    C[row * P + col] = sum;
  }
}

int main() {
  int M, N, P;
  std::cout << "Enter M (rows of A), N (cols of A / rows of B), and P (cols of B): ";
  std::cin >> M >> N >> P;

  std::vector<int> A(M * N), B(N * P), C(M * P);

  std::cout << "Enter elements of Matrix A:\n";
  for (int i = 0; i < M * N; i++)
    std::cin >> A[i];

  std::cout << "Enter elements of Matrix B:\n";
  for (int i = 0; i < N * P; i++)
    std::cin >> B[i];

  int *d_A, *d_B, *d_C;
  cudaMalloc(&d_A, M * N * sizeof(int));
  cudaMalloc(&d_B, N * P * sizeof(int));
  cudaMalloc(&d_C, M * P * sizeof(int));

  if (d_A && d_B && d_C) {
    cudaMemcpy(d_A, A.data(), M * N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), N * P * sizeof(int), cudaMemcpyHostToDevice);

    auto print_result = [&]() {
      cudaMemcpy(C.data(), d_C, M * P * sizeof(int), cudaMemcpyDeviceToHost);
      for (int i = 0; i < M; i++) {
        for (int j = 0; j < P; j++)
          std::cout << C[i * P + j] << " ";

        std::cout << "\n";
      }
    };

    std::cout << "\n--- Row-wise multiplication ---\n";
    mul_row<<<1, M>>>(d_A, d_B, d_C, M, N, P);
    print_result();

    std::cout << "\n--- Col-wise multiplication ---\n";
    mul_col<<<1, P>>>(d_A, d_B, d_C, M, N, P);
    print_result();

    std::cout << "\n--- Element-wise multiplication ---\n";
    mul_elem<<<M, P>>>(d_A, d_B, d_C, M, N, P);
    print_result();
  }

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  return 0;
}
