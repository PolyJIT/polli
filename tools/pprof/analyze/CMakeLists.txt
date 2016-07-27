set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  Support
)

add_polli_executable(pprof-analyze
  pprof-analyze.cpp
)

target_link_libraries(pprof-analyze
  pprof
  pqxx
)
add_dependencies(pprof-analyze pprof)
