set(LLVM_NO_RTTI 1)
set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  Analysis
  AsmParser
  BitReader
  BitWriter
  CodeGen
  Core
  ExecutionEngine
  IRReader
  Interpreter
  InstCombine
  Instrumentation
  IPA
  IPO
  Linker
  MC
  MCJIT
  native
  objcarcopts
  ScalarOpts
  SelectionDAG
  Support
  Target
  TransformUtils
  Vectorize
)

set(SHARED_LIBRARY ${POLLI_BUILD_SHARED_LIB})
add_polli_library(PolyJIT
  AliasCheckCodeGen.cpp
  FunctionDispatcher.cpp
  InstrumentRegions.cpp
  JitScopDetection.cpp
  PapiProfiling.cpp
  PolyJIT.cpp
  RuntimeOptimizer.cpp
  ScopMapper.cpp
  Utils.cpp
  VariantFunction.cpp
  )

target_link_libraries(PolyJIT
  papi
  isl
  isl-cxx
  Polly
  pprof
)

set_target_properties(PolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib"
)
