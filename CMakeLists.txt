project(polli)
cmake_minimum_required(VERSION 3.8)

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

include_directories(AFTER
  ${POLLI_SOURCE_DIR}/external/spdlog/include
  ${POLLI_SOURCE_DIR}/external/catch/include
  ${POLLI_SOURCE_DIR}/external/
  ${POLLI_SOURCE_DIR}/include/
  ${POLLI_BINARY_DIR}/include/
)

# Add path for polli custom modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${POLLI_SOURCE_DIR}/cmake")

# Where is LLVM installed?
find_package(LLVM 6.0 CONFIG REQUIRED)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${LLVM_CMAKE_DIR})
include(HandleLLVMOptions)
include(AddLLVM)

macro(add_pjit_dependency name Name NAME)
  find_package(${Name} REQUIRED)
  add_library(${name} UNKNOWN IMPORTED)
  set_target_properties(${name} PROPERTIES IMPORTED_LOCATION ${${NAME}_LIBRARY})
  include_directories(BEFORE ${${NAME}_INCLUDE_DIR})
  get_filename_component(${NAME}_LIBDIR ${${NAME}_LIBRARY} DIRECTORY)
  link_directories(${${NAME}_LIBDIR})
endmacro(add_pjit_dependency)

# Add the llvm header path.
include_directories(${LLVM_INCLUDE_DIRS})

include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})
add_definitions(${LLVM_DEFINITIONS})

## Find Polly
find_package(Polly REQUIRED)
include_directories (${POLLY_INCLUDE_DIRS} )
include_directories (${POLLY_ISL_INCLUDE_DIRS} )
link_directories( ${POLLY_LIBRARY_DIRS} )
add_definitions( ${POLLY_DEFINITIONS} )

include("polli_macros")

add_pjit_dependency(papi Papi PAPI)
add_pjit_dependency(pthread Pthread PTHREAD)
add_pjit_dependency(likwid Likwid LIKWID)
add_pjit_dependency(pqxx Pqxx PQXX)

set(BOOST_MIN_VERSION "1.58.0")
find_package(Boost ${BOOST_MIN_VERSION} REQUIRED)
include_directories(BEFORE ${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

option(POLLI_ENABLE_TRACING "Trace critical parts of polli with performance counters" OFF)
option(POLLI_ENABLE_LIKWID "Enable tracing via Likwid Tools" OFF)
option(POLLI_ENABLE_PAPI "Enable tracing via libPAPI" OFF)
option(POLLI_ENABLE_BASE_POINTERS "Enable SubExpression modelling" OFF)
option(POLLI_STORE_OUTPUT "Store intermediate SCoPs as IR" OFF)

string(REPLACE "-fno-exceptions" "-fexceptions" NEW_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "${NEW_CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -fno-rtti")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/include/pprof/Config.h.cmake
  ${POLLI_BINARY_DIR}/include/pprof/Config.h )

FILE(GLOB_RECURSE PolliHeaderFiles "include/polli/*.h")
FILE(GLOB_RECURSE PprofHeaderFiles "include/pprof/*.h")
add_custom_target(headers SOURCES ${PolliHeaderFiles} ${PprofHeaderFiles})

install(DIRECTORY include/ DESTINATION include
  FILES_MATCHING PATTERN "*.h" PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY external/catch/include DESTINATION include
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/include/ DESTINATION include
  FILES_MATCHING PATTERN "*.h"
  PATTERN "CMakeFiles" EXCLUDE
  PATTERN ".svn" EXCLUDE
  )

set(POLLI_BINARY_OUTPUT_INTDIR ${POLLI_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(POLLI_LIBRARY_OUTPUT_INTDIR ${POLLI_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib)

add_definitions( -D_GNU_SOURCE -DFMT_HEADER_ONLY)

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
