set(SHARED_LIBRARY ${POLLI_BUILD_SHARED_LIB})
set(POLLI_SOURCES
  pprof.cpp
  libpprof.cpp
  libpprof-pgsql.cpp
  libpprof-file.cpp
)

# for pqxx
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")

add_polli_library(pprof
  ${POLLI_SOURCES}
)

target_link_libraries(pprof
  likwid
  papi
  pqxx
  pthread
)

set_target_properties(pprof
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib"
)
