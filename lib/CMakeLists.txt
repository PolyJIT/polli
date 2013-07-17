set(LLVM_NO_RTTI 1)
set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  asmparser
  bitreader
  codegen
  executionengine
  interpreter
  ipo
  jit 
  linker 
  mcjit 
  native
  nativecodegen
  scalarOpts
  selectiondag
  support
  transformutils
  vectorize
)

set(LLVM_USED_LIBS
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollyJSON
  PollyTransform
  PollySupport
  )

add_polli_library(PolyJIT
  PolyJIT.cpp
  )

add_dependencies(PolyJIT
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollySupport
  PollyJSON
  PollyTransform
  )

set_target_properties(PolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib")
