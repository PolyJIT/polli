set(LLVM_LINK_COMPONENTS
  ${LLVM_LINK_COMPONENTS}
  ${LLVM_TARGETS_TO_BUILD}
  ${POLLI_DEPS}
  BitWriter
  Support
)

if ( POLLI_BUILD_SHARED_LIB )
  message(STATUS "LLVM components: ${LLVM_LINK_COMPONENTS}")
endif( POLLI_BUILD_SHARED_LIB )

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
