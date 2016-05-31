set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
string(REPLACE "-fno-exceptions" "-fexceptions" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

set(POLLI_LINK_LIBS
  papi
  pprof
  pjit
  likwid
  LLVMCore
  LLVMSupport
)

remove_definitions(-DPOLLI_ENABLE_TRACING)
add_polli_executable(test-polyjit
  CatchTests.cpp
  test_RunValues.cpp
)

set(EXTRA_CATCH_FLAGS "-fexceptions")

get_target_property(FLAGS test-polyjit COMPILE_FLAGS)
if (FLAGS STREQUAL "FLAGS-NOTFOUND")
  set(FLAGS "")
else()
  set(FLAGS "${FLAGS} ")
endif()
set (FLAGS "${FLAGS} ${EXTRA_CATCH_FLAGS}") 

set_target_properties(test-polyjit
  PROPERTIES
  COMPILE_FLAGS
  ${FLAGS}
)
