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
find_package(LLVM CONFIG REQUIRED)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${LLVM_CMAKE_DIR})
include(HandleLLVMOptions)
include(AddLLVM)

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

find_package(Papi REQUIRED)
add_library(papi UNKNOWN IMPORTED)
set_target_properties(papi PROPERTIES IMPORTED_LOCATION ${PAPI_LIBRARY})
include_directories(BEFORE ${PAPI_INCLUDE_DIR})
get_filename_component(PAPI_LIBDIR ${PAPI_LIBRARY} DIRECTORY)
link_directories(${PAPI_LIBDIR})

find_package(Pthread REQUIRED)
add_library(pthread UNKNOWN IMPORTED)
set_target_properties(pthread PROPERTIES IMPORTED_LOCATION ${PTHREAD_LIBRARY})
include_directories(BEFORE ${PTHREAD_INCLUDE_DIR})
get_filename_component(PTHREAD_LIBDIR ${PTHREAD_LIBRARY} DIRECTORY)
link_directories(${PTHREAD_LIBDIR})

find_package(Likwid REQUIRED)
add_library(likwid UNKNOWN IMPORTED)
set_target_properties(likwid PROPERTIES IMPORTED_LOCATION ${LIKWID_LIBRARY})
include_directories(BEFORE ${LIKWID_INCLUDE_DIR})
get_filename_component(LIKWID_LIBDIR ${LIKWID_LIBRARY} DIRECTORY)
link_directories(${LIKWID_LIBDIR})

find_package(Pqxx REQUIRED)
add_library(pqxx UNKNOWN IMPORTED)
set_target_properties(pqxx PROPERTIES IMPORTED_LOCATION ${PQXX_LIBRARY})
include_directories(BEFORE ${PQXX_INCLUDE_DIR})
get_filename_component(PQXX_LIBDIR ${PQXX_LIBRARY} DIRECTORY)
link_directories(${PQXX_LIBDIR})

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
string(REPLACE "-O3" "-O2" NEW_CMAKE_CXX_FLAGS "${NEW_CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "${NEW_CMAKE_CXX_FLAGS} -DNDEBUG -g -fno-inline -std=c++14 -fno-omit-frame-pointer -fPIC -fno-rtti -pthread -Wall")

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
