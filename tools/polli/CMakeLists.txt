set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  asmparser
  bitreader
  codegen
  executionengine
  interpreter
  ipo
  irreader
  jit
  mcjit
  native
  nativecodegen
  selectiondag
  support
  transformutils
  vectorize
  )

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

set(LLVM_USED_LIBS
  PolyJIT
  )

add_polli_executable(polli
  polli.cpp
  )

target_link_libraries(polli PolyJIT)
