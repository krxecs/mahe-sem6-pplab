# Only build if CUDA is enabled
if(CMAKE_CUDA_COMPILER)
  add_executable(ppl10-se se.cu)
  set_target_properties(ppl10-se PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl10-q1 q1.cu)
  set_target_properties(ppl10-q1 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl10-q2 q2.cu)
  set_target_properties(ppl10-q2 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  add_executable(ppl10-q3 q3.cu)
  set_target_properties(ppl10-q3 PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON)

  message(STATUS "Lab 10 CUDA programs configured")
else()
  message(WARNING "Lab 10 requires CUDA - skipping")
endif()
