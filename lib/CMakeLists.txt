set(LLVM_NO_RTTI 1)
set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  asmparser
  bitreader
  codegen
  executionengine
  interpreter
  instrumentation
  ipo
  jit
  linker
  mcjit
  native
  nativecodegen
  objcarcopts
  scalarOpts
  selectiondag
  support
  transformutils
  vectorize
)

add_polli_library(PolyJIT
  InstrumentRegions.cpp
  NonAffineScopDetection.cpp
  PapiProfiling.cpp
  PolyJIT.cpp
  RuntimeOptimizer.cpp
  ScopMapper.cpp
  Utils.cpp
  )

add_dependencies(PolyJIT
  Polly
  )

set_target_properties(PolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib")
