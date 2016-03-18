add_library(PolyJIT_Transform STATIC
#  AliasCheckCodeGen.cpp
  InstrumentRegions.cpp
  ScopMapper.cpp
  )

add_dependencies(PolyJIT_Transform
  PolyJIT_Analysis
  )
