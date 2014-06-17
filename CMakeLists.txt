project(polli)
cmake_minimum_required(VERSION 2.8)

option(POLLI_BUILD_SHARED_LIB "Build a shared libPolyJIT" ON)
set(POLLI_USE_SANITIZER "" CACHE STRING "Specify the sanitizer to use during build" )

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Provide option for finding LLVM
set(LLVM_INSTALL_ROOT "" CACHE STRING "Location of LLVM installation")

## Find LLVM
find_package(LLVM REQUIRED HINTS ${LLVM_INSTALL_ROOT})
include_directories( ${LLVM_INCLUDE_DIRS} )
link_directories( ${LLVM_LIBRARY_DIRS} )
add_definitions( ${LLVM_DEFINITIONS} )

# Add LLVM's cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_DIR}")
include(AddLLVM)

# Add path for polli custom modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${POLLI_SOURCE_DIR}/cmake")
include(polli_macros)

## Find Polly
find_package(Polly REQUIRED)
include_directories ( ${POLLY_INCLUDE_DIR} )
link_directories( ${POLLY_LINK_DIR} )
add_definitions( ${POLLY_DEFINITIONS} )

# Find PAPI
find_package(Papi REQUIRED)
include_directories(${PAPI_INCLUDE_DIR})
link_directories(${PAPI_LIBRARY})

# Add appropriate flags for GCC
if (CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common -Woverloaded-virtual -Wno-long-long -Wall -W -Wwrite-strings")
endif ()

if (NOT POLLI_USE_SANITIZER STREQUAL "")
  set(SANITIZER_OPTS "-fsanitize=${POLLI_USE_SANITIZER}")
endif ()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SANITIZER_OPTS} -fno-exceptions -fno-rtti -std=c++0x")

include_directories(
  ${POLLI_SOURCE_DIR}/include
)

install(DIRECTORY include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/include/
  DESTINATION include
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN "CMakeFiles" EXCLUDE
  PATTERN ".svn" EXCLUDE
  )

add_library(papi SHARED IMPORTED)
set_target_properties(papi PROPERTIES IMPORTED_LOCATION ${PAPI_LIBRARY})

add_definitions( -D_GNU_SOURCE )

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)
