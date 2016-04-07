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
  boost_system
  boost_thread
)

add_polli_library(pjit STATIC
  libpjit.cpp
  BlockingMap.cpp
  CodeGen.cpp
)

add_polli_library(pjit_shared SHARED
  libpjit.cpp
  BlockingMap.cpp
  CodeGen.cpp
)

add_dependencies(pjit PolyJIT_Runtime)
set_target_properties(pjit_shared PROPERTIES OUTPUT_NAME pjit)


