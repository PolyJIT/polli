set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")

add_polli_library(PolyJIT_Analysis STATIC
  NonAffineSCEVs.cpp
  ScopDetection.cpp
  )
