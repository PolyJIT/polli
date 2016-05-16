add_polli_library(PolyJIT_Transform STATIC
#  AliasCheckCodeGen.cpp
  InstrumentRegions.cpp
  )

add_dependencies(PolyJIT_Transform
  PolyJIT_Analysis
  )
