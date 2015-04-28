set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  Support
)

add_polli_executable(pprof-calibrate
  pprof-calibrate.cpp
)

target_link_libraries(pprof-calibrate
  pprof
  pqxx
)

add_dependencies(pprof-calibrate pprof)
