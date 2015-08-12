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

if (NOT DEFINED PAPI_FOUND)
  find_package(Papi REQUIRED)
  include_directories(BEFORE ${PAPI_INCLUDE_DIR})
  link_directories(${PAPI_LIBRARY})
endif ()

add_library(papi SHARED IMPORTED)
set_target_properties(papi
  PROPERTIES IMPORTED_LOCATION ${PAPI_LIBRARY})

if (NOT DEFINED PTHREAD_FOUND)
  find_package(Pthread REQUIRED)
  include_directories(BEFORE ${PTHREAD_INCLUDE_DIR})
  link_directories(${PTHREAD_LIBRARY})
endif ()

add_library(pthread SHARED IMPORTED)
set_target_properties(pthread
  PROPERTIES IMPORTED_LOCATION ${PTHREAD_LIBRARY})

if (NOT DEFINED LIKWID_FOUND)
  find_package(Likwid REQUIRED)
  include_directories(BEFORE ${LIKWID_INCLUDE_DIR})
  link_directories(${LIKWID_LIBRARY})
endif ()

add_library(likwid SHARED IMPORTED)
set_target_properties(likwid PROPERTIES IMPORTED_LOCATION ${LIKWID_LIBRARY})

if (NOT DEFINED PQXX_FOUND)
  find_package(Pqxx REQUIRED)
  include_directories(BEFORE ${PQXX_INCLUDE_DIR})
  link_directories(${PQXX_LIBRARY})
endif ()

add_library(pqxx SHARED IMPORTED)
set_target_properties(pqxx PROPERTIES IMPORTED_LOCATION ${PQXX_LIBRARY})

option(POLLI_ENABLE_TRACING "Trace critical parts of polli with performance counters" ON)
option(POLLI_ENABLE_LIKWID "Enable tracing via Likwid Tools" OFF)
option(POLLI_ENABLE_PAPI "Enable tracing via libPAPI" ON)

# Add appropriate flags for GCC
if (CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions -fno-common -Woverloaded-virtual -Wno-long-long -Wall -W -Wwrite-strings")
endif ()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions -pthread -fno-rtti")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/include/pprof/Config.h.cmake
  ${POLLI_BINARY_DIR}/include/pprof/Config.h )

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_BINARY_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/external/
  ${CMAKE_CURRENT_BINARY_DIR}/external/
  ${CMAKE_CURRENT_SOURCE_DIR}/external/spdlog/include
  ${CMAKE_CURRENT_BINARY_DIR}/external/spdlog/include
)

install(DIRECTORY include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY external/spdlog/include/
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

install(DIRECTORY ${POLLI_BINARY_DIR}/external/spdlog/include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/external/
  DESTINATION include
  FILES_MATCHING
  PATTERN "cppformat/*.h"
  PATTERN ".svn" EXCLUDE
  )

add_definitions( -D_GNU_SOURCE )

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)
