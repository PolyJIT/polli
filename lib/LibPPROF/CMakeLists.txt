set(POLYJIT_PPROF_SOURCES
  pprof.cpp
  libpprof.cpp
  libpprof-pgsql.cpp
  libpprof-file.cpp
  Tracing.cpp
  ../Support/Log.cpp
  ../Support/Options.cpp
)

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
  OrcJIT
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
  papi
  pqxx
  pq
)

add_polli_library(pprof SHARED
  ${POLYJIT_PPROF_SOURCES}
)
