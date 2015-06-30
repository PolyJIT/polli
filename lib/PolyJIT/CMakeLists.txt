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
  TransformUtils
  Vectorize
)

add_polli_library(PolyJIT
  #  AliasCheckCodeGen.cpp
  FunctionDispatcher.cpp
  InstrumentRegions.cpp
  JitScopDetection.cpp
  LikwidMarker.cpp
  PolyJIT.cpp
  Options.cpp
  RuntimeOptimizer.cpp
  ScopMapper.cpp
  ScopDetectionCheckers.cpp
  Utils.cpp
  VariantFunction.cpp
  RegisterCompilationPasses.cpp
  ModuleExtraction.cpp
  )

if (BUILD_SHARED_LIBS)
  target_link_libraries(PolyJIT PRIVATE
    likwid
    Polly
    pthread
  )
endif()

set_target_properties(PolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "lib"
)
