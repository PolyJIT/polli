set(SHARED_LIBRARY ${POLLI_BUILD_SHARED_LIB})
add_polli_library(pprof
  libpprof.cpp
)

target_link_libraries(pprof
  papi
)

set_target_properties(pprof
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib"
)
