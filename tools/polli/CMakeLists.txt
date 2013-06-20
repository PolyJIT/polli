set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  jit
  mcjit
  codegen
  executionengine
  interpreter
  nativecodegen
  bitreader
  asmparser
  selectiondag
  native
  support)

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
  RecordingMemoryManager.cpp
  RemoteTarget.cpp
  )

target_link_libraries(polli
  PolyJIT
  ffi
)

add_dependencies(polli
  PolyJIT
  ffi
  )
