set(POLYJIT_COMPILETIME_SOURCES
  Analysis/NonAffineSCEVs.cpp
  Analysis/ScopDetection.cpp
  Extract/ModuleExtraction.cpp
  Persist/Schema.cpp
  Support/Tasks.cpp
  Support/FuncTools.cpp
  Support/Options.cpp
  Support/Stats.cpp
  Support/Utils.cpp
  Support/TypeMapper.cpp
  Transform/InstrumentRegions.cpp
  pjit-logging/Log.cpp
  RegisterCompilationPasses.cpp
  PolyJIT.cpp
)

set(POLYJIT_RUNTIME_SOURCES
  pjit/libpjit.cpp
  pjit/BlockingMap.cpp
  pjit/CodeGen.cpp
  pjit/Jit.cpp
  pjit/RunValues.cpp
  pjit/Db.cpp
  pjit-logging/Log.cpp
  Runtime/LikwidMarker.cpp
  Runtime/RuntimeOptimizer.cpp
  Runtime/VariantFunction.cpp
  Support/Tasks.cpp
  Support/FuncTools.cpp
  Support/Options.cpp
  Support/Stats.cpp
  Support/Utils.cpp
  Support/TypeMapper.cpp
)

set(POLYJIT_PPROF_SOURCES
  pprof/Tracing.cpp
  pprof/pprof.cpp
  pprof/libpprof.cpp
  pprof/libpprof-pgsql.cpp
  pprof/libpprof-file.cpp
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
  Polly
  likwid
  pthread
  papi
  pqxx
  boost_system
  boost_thread
)

add_polli_library(pjit SHARED
  ${POLYJIT_RUNTIME_SOURCES}
)

set(POLLI_LINK_LIBS
  papi
)

add_polli_library(pprof SHARED
  ${POLYJIT_PPROF_SOURCES}
)

set(POLLI_LINK_LIBS
  Polly
  likwid
  pthread
  pqxx
  boost_system
)

add_polli_loadable_module(LLVMPolyJIT
  ${POLYJIT_COMPILETIME_SOURCES}
)

set_target_properties(LLVMPolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "")
