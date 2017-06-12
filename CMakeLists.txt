project(polli)
cmake_minimum_required(VERSION 3.2)

# Set our project paths
set(POLLI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(POLLI_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Add path for polli custom modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${POLLI_SOURCE_DIR}/cmake")

set(LLVM_INSTALL_ROOT "" CACHE PATH "Root of LLVM install.")
if( NOT EXISTS ${LLVM_INSTALL_ROOT}/include/llvm )
  message(FATAL_ERROR "LLVM_INSTALL_ROOT (${LLVM_INSTALL_ROOT}) is not a valid LLVM installation.")
endif(NOT EXISTS ${LLVM_INSTALL_ROOT}/include/llvm)

# Add LLVM's cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
  "${LLVM_INSTALL_ROOT}/lib/cmake/llvm"
  "${LLVM_INSTALL_ROOT}/share/llvm/cmake"
)

## Find LLVM
find_package(LLVM REQUIRED PATHS
  "${LLVM_INSTALL_ROOT}/lib/cmake/llvm"
  "${LLVM_INSTALL_ROOT}/share/llvm/cmake"
  NO_DEFAULT_PATH
)

include(AddLLVM)

include_directories(${LLVM_INCLUDE_DIRS} )
link_directories( ${LLVM_LIBRARY_DIRS} )
add_definitions( ${LLVM_DEFINITIONS} )

## Find Polly
find_package(Polly REQUIRED)
include_directories (${POLLY_INCLUDE_DIRS} )
link_directories( ${POLLY_LIBRARY_DIRS} )
add_definitions( ${POLLY_DEFINITIONS} )

# Get the system librarys that will link into LLVM.
function(get_system_libs return_var)
  # Returns in `return_var' a list of system libraries used by LLVM.
  if( NOT MSVC )
    if( MINGW )
      set(system_libs ${system_libs} imagehlp psapi)
    elseif( CMAKE_HOST_UNIX )
      if( HAVE_LIBDL )
        set(system_libs ${system_libs} ${CMAKE_DL_LIBS})
      endif()
      if( LLVM_ENABLE_THREADS AND HAVE_LIBPTHREAD )
        set(system_libs ${system_libs} pthread)
      endif()
    endif( MINGW )
  endif( NOT MSVC )
  set(${return_var} ${system_libs} PARENT_SCOPE)
endfunction(get_system_libs)

# Now set the header paths.
execute_process(COMMAND "${LLVM_INSTALL_ROOT}/bin/llvm-config" --includedir
                OUTPUT_VARIABLE LLVM_INCLUDE_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE)
include_directories( ${LLVM_INCLUDE_DIR} )

# Get the TARGET_TRIPLE
execute_process(COMMAND "${LLVM_INSTALL_ROOT}/bin/llvm-config" --host-target
                OUTPUT_VARIABLE TARGET_TRIPLE
                OUTPUT_STRIP_TRAILING_WHITESPACE)

# And then set the cxx flags.
execute_process(COMMAND "${LLVM_INSTALL_ROOT}/bin/llvm-config" --cxxflags
                OUTPUT_VARIABLE LLVM_CXX_FLAGS
                OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${LLVM_CXX_FLAGS})

# Check LLVM_ENABLE_ASSERTIONS
execute_process(COMMAND "${LLVM_INSTALL_ROOT}/bin/llvm-config" --assertion-mode
                OUTPUT_VARIABLE LLVM_ENABLE_ASSERTIONS
                OUTPUT_STRIP_TRAILING_WHITESPACE)
# Copied from LLVM's HandleLLVMOptions.cmake
if( LLVM_ENABLE_ASSERTIONS )
  # MSVC doesn't like _DEBUG on release builds. See PR 4379.
  if( NOT MSVC )
    add_definitions( -D_DEBUG )
  endif()
  # On non-Debug builds cmake automatically defines NDEBUG, so we
  # explicitly undefine it:
  if( NOT uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG" )
    add_definitions( -UNDEBUG )
    # Also remove /D NDEBUG to avoid MSVC warnings about conflicting defines.
    foreach (flags_var_to_scrub
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS_MINSIZEREL
        CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS_MINSIZEREL)
      string (REGEX REPLACE "(^| )[/-]D *NDEBUG($| )" " "
        "${flags_var_to_scrub}" "${${flags_var_to_scrub}}")
    endforeach()
  endif()
endif()

include("polli_macros")

find_package(Isl REQUIRED)
include_directories(${ISL_INCLUDE_DIR})

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
find_package(Boost ${BOOST_MIN_VERSION} REQUIRED COMPONENTS system thread)
include_directories(BEFORE ${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

option(POLLI_ENABLE_TRACING "Trace critical parts of polli with performance counters" OFF)
option(POLLI_ENABLE_LIKWID "Enable tracing via Likwid Tools" OFF)
option(POLLI_ENABLE_PAPI "Enable tracing via libPAPI" OFF)
option(POLLI_ENABLE_BASE_POINTERS "Enable SubExpression modelling" OFF)
option(POLLI_STORE_OUTPUT "Store intermediate SCoPs as IR" OFF)

string(REPLACE "-fno-exceptions" "-fexceptions" NEW_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "${NEW_CMAKE_CXX_FLAGS} -std=c++14 -fno-omit-frame-pointer -fPIC -fno-rtti -pthread -Wall")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/include/pprof/Config.h.cmake
  ${POLLI_BINARY_DIR}/include/pprof/Config.h )

FILE(GLOB_RECURSE PolliHeaderFiles "include/polli/*.h")
FILE(GLOB_RECURSE PprofHeaderFiles "include/pprof/*.h")
add_custom_target(headers SOURCES ${PolliHeaderFiles} ${PprofHeaderFiles})

install(DIRECTORY include/ DESTINATION include
  FILES_MATCHING PATTERN "*.h" PATTERN ".svn" EXCLUDE
  )

install(DIRECTORY external/isl DESTINATION include/isl
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )

install(DIRECTORY external/catch/include DESTINATION include
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )

install(DIRECTORY ${POLLI_BINARY_DIR}/include/ DESTINATION include
  FILES_MATCHING PATTERN "*.h"
  PATTERN "CMakeFiles" EXCLUDE
  PATTERN ".svn" EXCLUDE
  )

include_directories(AFTER
  ${CMAKE_CURRENT_SOURCE_DIR}/external/spdlog/include
  ${CMAKE_CURRENT_SOURCE_DIR}/external/catch/include
  ${CMAKE_CURRENT_SOURCE_DIR}/external/
  ${CMAKE_CURRENT_SOURCE_DIR}/include/
  ${CMAKE_CURRENT_BINARY_DIR}/include/
)

set(POLLI_BINARY_OUTPUT_INTDIR ${POLLI_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(POLLI_LIBRARY_OUTPUT_INTDIR ${POLLI_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib)

add_definitions( -D_GNU_SOURCE -DFMT_HEADER_ONLY)

add_subdirectory(tools)
add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
