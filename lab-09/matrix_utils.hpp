#ifndef MATRIX_UTILS_HPP
#define MATRIX_UTILS_HPP

#include <stdio.h>

/**
 * Print a matrix in row-major order
 * @param matrix Pointer to matrix data
 * @param M Number of rows
 * @param N Number of columns
 * @param label Label to print before the matrix
 */
inline void print_matrix(int *matrix, int M, int N, const char *label) {
  puts(label);
  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++)
      printf("%d ", matrix[i * N + j]);
    puts("");
  }
}

/**
 * Print a vector (single column)
 * @param vector Pointer to vector data
 * @param size Number of elements
 * @param label Label to print before the vector
 */
inline void print_vector(int *vector, int size, const char *label) {
  puts(label);
  for (int i = 0; i < size; i++)
    printf("%d\n", vector[i]);
}

#endif // MATRIX_UTILS_HPP
