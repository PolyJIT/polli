add_subdirectory(pjit)
add_subdirectory(pprof)
add_subdirectory(PolyJIT)

add_polli_loadable_module(LLVMPolyJIT
  PolyJIT.cpp
)

target_link_libraries(LLVMPolyJIT
  PolyJIT
)
set_target_properties(LLVMPolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "")
