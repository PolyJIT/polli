set(LLVM_NO_RTTI 1)
set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  jit
  codegen
  executionengine
  interpreter
  nativecodegen
  bitreader
  asmparser
  selectiondag
  native
  scalarOpts
  support)

add_polli_library(PolyJIT
  PolyJIT.cpp
  )

target_link_libraries(PolyJIT
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollySupport
  PollyJSON
  PollyTransform
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
  PREFIX "")
