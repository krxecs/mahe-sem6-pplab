// Lab 7, Q1:
// Write a program in CUDA to count the number of times a given word is repeated
// in a sentence. (Use Atomic functions)
#include <cuda_runtime.h>
#include <iostream>

// Helper device function to check for word boundaries (spaces, punctuation,
// null)
__device__ bool is_delimiter(char c) {
  return c == ' ' || c == '\t' || c == '\n' || c == '\0' || c == '.' ||
         c == ',';
}

__global__ void count_word_kernel(const char *sentence, const char *word,
                                  int word_len, int sentence_len, int *count) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  // Ensure we don't read out of bounds
  if (tid <= sentence_len - word_len) {
    // Check if the current position is a valid start of a word
    bool start_boundary = (tid == 0) || is_delimiter(sentence[tid - 1]);
    bool end_boundary = is_delimiter(sentence[tid + word_len]);

    if (start_boundary && end_boundary) {
      bool match = true;
      for (int i = 0; i < word_len; i++) {
        if (sentence[tid + i] != word[i]) {
          match = false;
          break;
        }
      }

      // Increment the counter atomically if the word matches
      if (match)
        atomicAdd(count, 1);
    }
  }
}

int main() {
  std::string h_sentence, h_word;

  std::cout << "Enter sentence: ";
  std::getline(std::cin, h_sentence);
  std::cout << "Enter word to count: ";
  std::getline(std::cin, h_word);

  char *d_sentence, *d_word;
  cudaMalloc((void **)&d_sentence, h_sentence.length() + 1);
  cudaMalloc((void **)&d_word, h_word.length() + 1);

  if (d_sentence && d_word) {
    cudaMemcpy(d_sentence, h_sentence.c_str(), h_sentence.length() + 1,
               cudaMemcpyHostToDevice);
    cudaMemcpy(d_word, h_word.c_str(), h_word.length() + 1,
               cudaMemcpyHostToDevice);
  }

  int h_count = 0;
  int *d_count;
  cudaMalloc((void **)&d_count, sizeof(int));

  if (d_count)
    cudaMemcpy(d_count, &h_count, sizeof(int), cudaMemcpyHostToDevice);

  int threads_per_block = 256;
  int blocks =
      (h_sentence.length() + threads_per_block - 1) / threads_per_block;

  count_word_kernel<<<blocks, threads_per_block>>>(
      d_sentence, d_word, h_word.length(), h_sentence.length(), d_count);
  cudaDeviceSynchronize();

  cudaMemcpy(&h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

  std::cout << "\nTotal occurrences: " << h_count << std::endl;

  cudaFree(d_sentence);
  cudaFree(d_word);
  cudaFree(d_count);

  return 0;
}
