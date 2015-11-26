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
)

set(LLVM_NO_RTTI 1)

add_polli_library(pjit
  ${POLLI_RUNTIME}
  ${POLLI_SUPPORT}
  libpjit.cpp
)

if (BUILD_SHARED_LIBS)
  target_link_libraries(pjit LINK_PRIVATE
    pprof
    likwid
    pthread
  )
endif()

if (TARGET intrinsics_gen)
  # Check if we are building as part of an LLVM build
  add_dependencies(pjit intrinsics_gen)
endif()
