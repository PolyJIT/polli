set(SHARED_LIBRARY ${POLLI_BUILD_SHARED_LIB})
add_polli_library(pprof
  Tracing.cpp
  libpprof.cpp
  pprof.cpp
)

target_link_libraries(pprof
  likwid
  papi
  pthread
)

set_target_properties(pprof
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib"
)
