set(LLVM_LINK_COMPONENTS
  ${LLVM_LINK_COMPONENTS}
  ${LLVM_TARGETS_TO_BUILD}
  ${POLLI_DEPS}
  BitWriter
  Support
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
