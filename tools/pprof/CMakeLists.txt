add_polli_executable(pprof-analyze
  pprof-analyze.cpp
)

target_link_libraries(pprof-analyze
  pprof
)
add_dependencies(pprof-analyze pprof)
