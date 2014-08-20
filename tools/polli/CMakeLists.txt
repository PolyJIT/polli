set(LLVM_LINK_COMPONENTS
  ${LLVM_LINK_COMPONENTS}
  BitReader
  BitWriter
  ExecutionEngine
  IRReader
  Interpreter
  JIT
  linker
  MCJIT
  native
  SelectionDAG
  Support
  ${LLVM_TARGETS_TO_BUILD}
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

add_polli_executable(polli
  polli.cpp
)

target_link_libraries(polli PolyJIT)
add_dependencies(polli PolyJIT)
