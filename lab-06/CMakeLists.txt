# Only build if CUDA is enabled
if(CMAKE_CUDA_COMPILER)
  add_executable(ppl6-q1 q1.cu)
  set_target_properties(ppl6-q1 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl6-q2 q2.cu)
  set_target_properties(ppl6-q2 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl6-q3 q3.cu)
  set_target_properties(ppl6-q3 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  message(STATUS "Lab 6 CUDA programs configured")
else()
  message(WARNING "Lab 6 requires CUDA - skipping")
endif()
