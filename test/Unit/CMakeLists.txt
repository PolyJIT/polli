add_custom_target(PolliUnitTests)
set_target_properties(PolliUnitTests PROPERTIES FOLDER "Tests")
set(CMAKE_INSTALL_RPATH "\$ORIGIN/../../../../../../lib${LLVM_LIBDIR_SUFFIX}")

set(LLVM_LINK_COMPONENTS
  Core
  Support
)

function(add_polli_unittest test_dirname)
  add_unittest(PolliUnitTests ${test_dirname} ${ARGN})
endfunction()

add_polli_unittest(PolyJIT_SchemaTest
  Schema.cpp
)
target_link_libraries(PolyJIT_SchemaTest
  PolyJIT_Persist
)
