if (NOT DEFINED LLVM_MAIN_SRC_DIR)
  project(polli)
  cmake_minimum_required(VERSION 2.8)

  option(POLLI_BUILD_SHARED_LIB "Build a shared libPolyJIT" ON)
  set(POLLI_USE_SANITIZER "" CACHE STRING "Specify the sanitizer to use during build" )

  ## Find LLVM
  find_package(LLVM REQUIRED HINTS ${LLVM_INSTALL_ROOT})
  include_directories( ${LLVM_INCLUDE_DIRS} )
  link_directories( ${LLVM_LIBRARY_DIRS} )
  add_definitions( ${LLVM_DEFINITIONS} )

  # Add LLVM's cmake modules
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_DIR}")
  include(AddLLVM)

  ## Find Polly
  find_package(Polly REQUIRED)
  include_directories ( BEFORE ${POLLY_INCLUDE_DIR} )
  link_directories( ${POLLY_LINK_DIR} )
  add_definitions( ${POLLY_DEFINITIONS} )
endif()


# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Add path for polli custom modules
set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  "${POLLI_SOURCE_DIR}/cmake"
  )

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

find_package(Boost 1.54.0 REQUIRED COMPONENTS system thread)
include_directories(BEFORE ${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

option(POLLI_ENABLE_TRACING "Trace critical parts of polli with performance counters" ON)
option(POLLI_ENABLE_LIKWID "Enable tracing via Likwid Tools" OFF)
option(POLLI_ENABLE_PAPI "Enable tracing via libPAPI" ON)

string(REPLACE "-fno-exceptions" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
if (CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -fexceptions")
else ()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -fexceptions")
endif ()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/include/pprof/Config.h.cmake
  ${POLLI_BINARY_DIR}/include/pprof/Config.h )

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_BINARY_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/external/
  ${CMAKE_CURRENT_BINARY_DIR}/external/
)

install(DIRECTORY include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY external/
  DESTINATION include
  FILES_MATCHING
  PATTERN "cppformat/*.h"
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN "CMakeFiles" EXCLUDE
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/external/
  DESTINATION include
  FILES_MATCHING
  PATTERN "cppformat/*.h"
  PATTERN ".svn" EXCLUDE
  )

add_definitions( -DFMT_HEADER_ONLY )
add_definitions( -D_GNU_SOURCE )

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)
