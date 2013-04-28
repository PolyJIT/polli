project(polli)
cmake_minimum_required(VERSION 2.8)

# Where is LLVM installed?
set(LLVM_INSTALL_ROOT "" CACHE PATH "Root of LLVM install.")

# Check if the LLVM_INSTALL_ROOT valid.
if( NOT EXISTS ${LLVM_INSTALL_ROOT}/include/llvm )
  message(FATAL_ERROR "LLVM_INSTALL_ROOT (${LLVM_INSTALL_ROOT}) is not a valid LLVM installation.")
endif(NOT EXISTS ${LLVM_INSTALL_ROOT}/include/llvm)

# FileCheck is not install by default, warn the user to Copy FileCheck
if( NOT EXISTS ${LLVM_INSTALL_ROOT}/bin/FileCheck
    OR NOT EXISTS ${LLVM_INSTALL_ROOT}/bin/not)
  message(WARNING "FileCheck or not are required by running regress tests, "
                  "but they are not installed! Please copy it to "
                  "${LLVM_INSTALL_ROOT}/bin.")
endif(NOT EXISTS ${LLVM_INSTALL_ROOT}/bin/FileCheck
      OR NOT EXISTS ${LLVM_INSTALL_ROOT}/bin/not)

# Add LLVM CMake features
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_INSTALL_ROOT}/share/llvm/cmake")
include(LLVMConfig)
include(AddLLVM)

include_directories( ${LLVM_INCLUDE_DIRS} )
link_directories( ${LLVM_LIBRARY_DIRS} )
add_definitions( ${LLVM_DEFINITIONS} )

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Add path for polli custom modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${POLLI_SOURCE_DIR}/cmake")
include("polli_macros")

# Add appropriate flags for GCC
if (CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common -Woverloaded-virtual -Wno-long-long -Wall -W -Wno-unused-parameter -Wwrite-strings")
endif ()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-rtti")

include_directories(
  ${POLLI_SOURCE_DIR}/include
  ${POLLI_BINARY_DIR}/include
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
#add_subdirectory(test)
add_subdirectory(tools)
