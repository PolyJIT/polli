project(polli)
cmake_minimum_required(VERSION 2.8)

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

## Find LLVM
find_package(LLVM REQUIRED)
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
include_directories ( ${POLLY_INCLUDE_DIRS} )
link_directories( ${POLLY_LINK_DIRS} )
add_definitions( ${POLLY_DEFINITIONS} )

# Find PAPI
find_package(Papi REQUIRED)
include_directories(${PAPI_INCLUDE_DIR})
link_directories(${PAPI_LIBRARY})

# Add appropriate flags for GCC
if (CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common -Woverloaded-virtual -Wno-long-long -Wall -W -Wno-unused-parameter -Wwrite-strings")
endif ()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-rtti -std=c++0x")

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

add_definitions( -D_GNU_SOURCE )

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)
