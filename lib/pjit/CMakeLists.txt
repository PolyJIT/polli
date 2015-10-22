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
  IPO
  Linker
  MC
  MCJIT
  native
  objcarcopts
  RuntimeDyld
  ScalarOpts
  SelectionDAG
  Support
  Target
  TransformUtils
  Vectorize
)

set(POLLI_LINK_LIBS
  Polly
  PolyJIT_Runtime
  PolyJIT_Support
  likwid
  pthread
  pfm
  papi
  pprof
)

set(SHARED_LIBRARY On)
add_polli_library(pjit SHARED
  libpjit.cpp
)
