set(POLYJIT_COMPILETIME_SOURCES
  Analysis/NonAffineSCEVs.cpp
  Analysis/ScopDetection.cpp
  Extract/ModuleExtraction.cpp
  Persist/Schema.cpp
  PolyJIT.cpp
  RegisterCompilationPasses.cpp
  Support/FuncTools.cpp
  Support/Log.cpp
  Support/Options.cpp
  Support/Stats.cpp
  Support/Tasks.cpp
  Support/TypeMapper.cpp
  Support/Utils.cpp
  Transform/InstrumentRegions.cpp
  Transform/ProfileScops.cpp
)

set(POLLI_LINK_LIBS
  likwid
  pthread
  pqxx
  pq
)

add_polli_loadable_module(LLVMPolyJIT
  ${POLYJIT_COMPILETIME_SOURCES}
)

target_link_libraries(LLVMPolyJIT INTERFACE LLVMPolly)
target_compile_features(LLVMPolyJIT PUBLIC cxx_std_17)
set_target_properties(LLVMPolyJIT
  PROPERTIES
  LINKER_LANGUAGE CXX
  PREFIX "")

add_subdirectory(LibPJIT)
add_subdirectory(LibPPROF)
