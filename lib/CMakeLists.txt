add_subdirectory(Analysis)
add_subdirectory(Extract)
add_subdirectory(Persist)
add_subdirectory(Runtime)
add_subdirectory(Support)
add_subdirectory(Transform)

add_subdirectory(pprof)
add_subdirectory(pjit)

set(POLLI_LINK_LIBS
  PolyJIT_Analysis
  PolyJIT_Extract
  PolyJIT_Persist
  PolyJIT_Runtime
  PolyJIT_Support
  PolyJIT_Transform
  likwid
  pthread
  pqxx
  boost_system
)

#if(NOT LINK_POLLY_INTO_TOOLS)
#  set(POLLI_LINK_LIBS
#    Polly
#    ${POLLI_LINK_LIBS}
#  )
#endif(NOT LINK_POLLY_INTO_TOOLS)

add_polli_loadable_module(LLVMPolyJIT
  RegisterCompilationPasses.cpp
  PolyJIT.cpp
)

set_target_properties(LLVMPolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "")
