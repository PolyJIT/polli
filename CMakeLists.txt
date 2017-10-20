project(polli)
cmake_minimum_required(VERSION 3.8)

include(ExternalProject)

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

set(POLLI_EXT_SPDLOG_DIR "${POLLI_SOURCE_DIR}/external/spdlog")
set(POLLI_EXT_CATCH_DIR "${POLLI_SOURCE_DIR}/external/catch")
set(POLLI_EXT_HDATE_DIR "${POLLI_SOURCE_DIR}/external/hdate")
set(POLLI_EXT_SQLPP11_DIR "${POLLI_SOURCE_DIR}/external/sqlpp11")
set(POLLI_EXT_SQLPP11_PG_DIR "${POLLI_SOURCE_DIR}/external/sqlpp11-postgres")

ExternalProject_Add(sqlpp11
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  SOURCE_DIR ${POLLI_EXT_SQLPP11_DIR}
  CMAKE_ARGS
    -DHinnantDate_ROOT_DIR=${POLLI_EXT_HDATE_DIR}/include
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)

ExternalProject_Add(sqlpp11-postgres
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  SOURCE_DIR ${POLLI_EXT_SQLPP11_PG_DIR}
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DDATE_INCLUDE_DIR=${POLLI_EXT_HDATE_DIR}/include/date
)

include_directories(AFTER
  ${POLLI_EXT_CATCH_DIR}/include
  ${POLLI_EXT_SPDLOG_DIR}/include
  ${POLLI_EXT_HDATE_DIR}/include
  ${POLLI_SOURCE_DIR}/external/
  ${POLLI_SOURCE_DIR}/include/
  ${POLLI_BINARY_DIR}/include/
)

# Add path for polli custom modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${POLLI_SOURCE_DIR}/cmake)
include("polli_macros")

find_package(LLVM CONFIG REQUIRED)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${LLVM_CMAKE_DIR})
include(HandleLLVMOptions)
include(AddLLVM)

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${LLVM_CXX_FLAGS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})
add_definitions(${LLVM_DEFINITIONS})

find_package(Polly REQUIRED)
include_directories (${POLLY_INCLUDE_DIRS} )
include_directories (${POLLY_ISL_INCLUDE_DIRS} )
link_directories( ${POLLY_LIBRARY_DIRS} )
add_definitions( ${POLLY_DEFINITIONS} )

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

#find_package(Pqxx REQUIRED)
#add_library(pqxx UNKNOWN IMPORTED)
#set_target_properties(pqxx PROPERTIES IMPORTED_LOCATION ${PQXX_LIBRARY})
#include_directories(BEFORE ${PQXX_INCLUDE_DIR})
#get_filename_component(PQXX_LIBDIR ${PQXX_LIBRARY} DIRECTORY)
#link_directories(${PQXX_LIBDIR})

set(BOOST_MIN_VERSION "1.58.0")
find_package(Boost ${BOOST_MIN_VERSION} REQUIRED)
include_directories(BEFORE ${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

option(POLLI_ENABLE_TRACING "Trace critical parts of polli with performance counters" OFF)
option(POLLI_ENABLE_LIKWID "Enable tracing via Likwid Tools" OFF)
option(POLLI_ENABLE_PAPI "Enable tracing via libPAPI" OFF)
option(POLLI_ENABLE_BASE_POINTERS "Enable SubExpression modelling" OFF)
option(POLLI_STORE_OUTPUT "Store intermediate SCoPs as IR" OFF)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -fexceptions -fno-rtti")

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

add_definitions(-DFMT_HEADER_ONLY)

add_subdirectory(tools)
add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
