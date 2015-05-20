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
  RuntimeDyld
  ScalarOpts
  SelectionDAG
  Support
  Target
  X86Codegen
  TransformUtils
  Vectorize
)

add_polli_library(pjit
  libpjit.cpp
  )


if (BUILD_SHARED_LIBS)
  target_link_libraries(pjit PRIVATE
    PolyJIT
    likwid
    Polly
    pthread
  )
endif()
