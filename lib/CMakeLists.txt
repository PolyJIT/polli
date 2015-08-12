add_subdirectory(pprof)

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

set(LLVM_NO_RTTI 1)

set(POLLI_ANALYSIS
  Analysis/JitScopDetection.cpp
  Analysis/ScopDetectionCheckers.cpp
)

set(POLLI_EXTRACT
  Extract/ModuleExtraction.cpp
)

set(POLLI_RUNTIME
  Runtime/FunctionDispatcher.cpp
  Runtime/LikwidMarker.cpp
  Runtime/RuntimeOptimizer.cpp
  Runtime/VariantFunction.cpp
)
set(POLLI_SUPPORT
  Support/Options.cpp
  Support/Utils.cpp
)
set(POLLI_TRANSFORM
  Transform/ScopMapper.cpp
  Transform/InstrumentRegions.cpp
)

add_polli_library(pjit
  ${POLLI_RUNTIME}
  ${POLLI_SUPPORT}
  libpjit.cpp
)


add_polli_loadable_module(LLVMPolyJIT
  ${POLLI_ANALYSIS}
  ${POLLI_EXTRACT}
  ${POLLI_SUPPORT}
  ${POLLI_TRANSFORM}
  ${POLLI_COMPILER_LIB}
  RegisterCompilationPasses.cpp
  PolyJIT.cpp
)


if (BUILD_SHARED_LIBS)
  target_link_libraries(pjit PRIVATE
    pprof
    Polly
    likwid
    pthread
  )
  target_link_libraries(LLVMPolyJIT PRIVATE
    Polly
    likwid
    pthread
  )
endif()

if (TARGET intrinsics_gen)
  # Check if we are building as part of an LLVM build
  add_dependencies(pjit intrinsics_gen)
  add_dependencies(LLVMPolyJIT intrinsics_gen)
endif()

set_target_properties(LLVMPolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "")
