set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  mcjit
  jit
  interpreter
  nativecodegen
  bitreader
  asmparser
  selectiondag
  native)

if( LLVM_USE_OPROFILE )
  set(LLVM_LINK_COMPONENTS
    ${LLVM_LINK_COMPONENTS}
    OProfileJIT
    )
endif( LLVM_USE_OPROFILE )

if( LLVM_USE_INTEL_JITEVENTS )
  set(LLVM_LINK_COMPONENTS
    ${LLVM_LINK_COMPONENTS}
    IntelJITEvents
    )
endif( LLVM_USE_INTEL_JITEVENTS )

add_polli_executable(polli
  polli.cpp
  PolyJIT.cpp
  RecordingMemoryManager.cpp
  RemoteTarget.cpp
  )

target_link_libraries(polli
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollySupport
  PollyJSON
  PollyTransform
)

add_dependencies(polli
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollySupport
  PollyJSON
  PollyTransform
  )

