add_polli_library(PolyJIT_Transform STATIC
  InstrumentRegions.cpp
  )

add_dependencies(PolyJIT_Transform
  PolyJIT_Analysis
  )
