cmake_minimum_required(VERSION 3.17 FATAL_ERROR)
project(mahe-sem6-pplab)

include(cmake/DefaultConfig.cmake)

# Optional CUDA support using modern CMake (3.8+)
include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
  message(STATUS "CUDA support enabled (CUDA Compiler: ${CMAKE_CUDA_COMPILER})")

  # Set CUDA standard
  if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 14)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
  endif()

  # Auto-detect GPU architectures (CMake 3.24+)
  # For older CMake, specify architectures manually:
  set(CMAKE_CUDA_ARCHITECTURES 50 72)
  # set(CMAKE_CUDA_ARCHITECTURES native)
else()
  message(STATUS "CUDA not found, building without CUDA support")
endif()

find_package(MPI REQUIRED COMPONENTS C)

add_subdirectory(lab-01)
add_subdirectory(lab-02)
add_subdirectory(lab-03)
add_subdirectory(lab-04)
add_subdirectory(lab-05)
add_subdirectory(lab-06)
add_subdirectory(lab-07)
add_subdirectory(lab-08)
