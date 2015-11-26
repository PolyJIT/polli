add_library(PolyJIT_Persist STATIC
  Schema.cpp
)

target_link_libraries(PolyJIT_Persist
  pqxx
  pprof
)
