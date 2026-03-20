# Only build if CUDA is enabled
if(CMAKE_CUDA_COMPILER)
  add_executable(ppl8-q1 q1.cu)
  set_target_properties(ppl8-q1 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl8-q2 q2.cu)
  set_target_properties(ppl8-q2 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  message(STATUS "Lab 8 CUDA programs configured")
else()
  message(WARNING "Lab 8 requires CUDA - skipping")
endif()
