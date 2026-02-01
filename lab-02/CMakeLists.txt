add_executable(ppl2-q1 q1.c)
target_link_libraries(ppl2-q1 MPI::MPI_C)

add_executable(ppl2-q2 q2.c)
target_link_libraries(ppl2-q2 MPI::MPI_C)

add_executable(ppl2-q3 q3.c)
target_link_libraries(ppl2-q3 MPI::MPI_C)

add_executable(ppl2-q4 q4.c)
target_link_libraries(ppl2-q4 MPI::MPI_C)
