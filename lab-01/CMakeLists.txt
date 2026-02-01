add_executable(ppl1-hello hello_world.c)
target_link_libraries(ppl1-hello MPI::MPI_C)

add_executable(ppl1-q1 q1.c)
target_link_libraries(ppl1-q1 MPI::MPI_C)

add_executable(ppl1-q2 q2.c)
target_link_libraries(ppl1-q2 MPI::MPI_C)

add_executable(ppl1-q3 q3.c)
target_link_libraries(ppl1-q3 MPI::MPI_C)

add_executable(ppl1-q4 q4.c)
target_link_libraries(ppl1-q4 MPI::MPI_C)
