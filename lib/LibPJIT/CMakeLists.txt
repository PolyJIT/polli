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
  Polly
  PollyISL
  dl
  likwid
  papi
  pthread
  pqxx
  absl::base
  absl::optional
  absl::strings
  absl::variant
  spdlog
)

set(POLYJIT_RUNTIME_SOURCES
  libpjit.cpp
  Compiler.cpp
  #Db.cpp
  ExportMetrics.cpp
  Jit.cpp
  RunValues.cpp
  ../Runtime/LikwidMarker.cpp
  ../Runtime/RuntimeOptimizer.cpp
  ../Runtime/VariantFunction.cpp
  ../Support/FuncTools.cpp
  ../Support/Log.cpp
  ../Support/Options.cpp
  ../Support/Stats.cpp
  ../Support/Tasks.cpp
  ../Support/TypeMapper.cpp
  ../Support/Utils.cpp
)

add_definitions(
  -DSPDLOG_NO_DATETIME
  -DSPDLOG_NO_THREAD_ID
  -DSPDLOG_NO_NAME
  -DSPDLOG_NO_ATOMIC_LEVELS
)
add_polli_library(pjit SHARED
  ${POLYJIT_RUNTIME_SOURCES}
)
target_compile_features(pjit PUBLIC cxx_std_14)
