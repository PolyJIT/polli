set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  jit
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

# We want a static binary
set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -static")

add_polli_executable(polli
  polli.cpp
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
  ffi
)

add_dependencies(polli
  PollyAnalysis
  PollyCodeGen
  PollyExchange
  PollySupport
  PollyJSON
  PollyTransform
  ffi
  )
