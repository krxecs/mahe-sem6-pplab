# Lab 5 - CUDA Programs

# Only build if CUDA is enabled
if(CMAKE_CUDA_COMPILER)
  # Question 1: Vector addition - two approaches
  add_executable(ppl5-q1 q1.cu)
  set_target_properties(ppl5-q1 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  # Question 2: Vector addition with fixed block size
  add_executable(ppl5-q2 q2.cu)
  set_target_properties(ppl5-q2 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  # Question 3: Sine computation
  add_executable(ppl5-q3 q3.cu)
  set_target_properties(ppl5-q3 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  message(STATUS "Lab 5 CUDA programs configured")
else()
  message(WARNING "Lab 5 requires CUDA - skipping")
endif()
