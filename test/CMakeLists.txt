add_subdirectory(Catch)
add_subdirectory(Unit)

set(POLLI_TEST_DIRECTORIES
  "JitScops"
  "Globals"
  "Run"
  "pprof"
)

set(POLLI_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(LLVM_SHLIBEXT "${CMAKE_SHARED_MODULE_SUFFIX}")

if (NOT DEFINED LLVM_MAIN_SRC_DIR)
  set(POLLI_TEST_DEPENDS LLVMPolyJIT)

  set(LLVM_BINARY_DIR "${LLVM_INSTALL_ROOT}")
  set(LLVM_TOOLS_DIR "${LLVM_INSTALL_ROOT}/bin")
  set(LLVM_LIBS_DIR "${LLVM_INSTALL_ROOT}/lib")
  set(POLLI_LIB_DIR "${POLLI_BINARY_DIR}/lib")
  set(POLLI_BINARY_DIR "${POLLI_SOURCE_DIR}/bin")

  # We are building polli out of tree, adjust the settings.
  # FIXME: FileCheck is not available in llvm install directory at the moment.
  if(NOT LLVM_OBJ_ROOT)
    exec_program(${LLVM_INSTALL_ROOT}/bin/llvm-config
                 ARGS --obj-root
                 OUTPUT_VARIABLE LLVM_OBJ_ROOT)
  endif(NOT LLVM_OBJ_ROOT)
  set(LLVM_LIT ${LLVM_OBJ_ROOT}/bin/llvm-lit)

  include(FindPythonInterp)
  if(PYTHONINTERP_FOUND)
    option(POLLI_TEST_DISABLE_BAR "Run Polli tests with --no-progress-bar" OFF)
    set(POLLI_TEST_EXTRA_ARGS)
    if (MSVC OR XCODE OR POLLI_TEST_DISABLE_BAR)
      set(POLLI_TEST_EXTRA_ARGS "--no-progress-bar")
    endif()

    option(POLLI_TEST_USE_VG "Run Polli tests under Valgrind" OFF)
    if(POLLI_TEST_USE_VG)
      set(POLLI_TEST_EXTRA_ARGS ${POLLI_TEST_EXTRA_ARGS} "--vg")
    endif ()

    foreach(testdir ${POLLI_TEST_DIRECTORIES})
      add_custom_target(polli-test-${testdir}
        COMMAND ${LLVM_LIT}
                    --param polli_site_config=${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
                    --param build_config=${CMAKE_CFG_INTDIR}
                    -sv ${POLLI_TEST_EXTRA_ARGS}
                    ${CMAKE_CURRENT_BINARY_DIR}/${testdir}
                    DEPENDS ${POLLI_TEST_DEPENDS}
                    COMMENT "Running Polli regression tests in ${testdir}")
    endforeach()

    add_custom_target(check-polli
      COMMAND ${LLVM_LIT}
                  --param polli_site_config=${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
                  --param build_config=${CMAKE_CFG_INTDIR}
                  -sv ${POLLI_TEST_EXTRA_ARGS}
                  ${CMAKE_CURRENT_BINARY_DIR}
                  DEPENDS ${POLLI_TEST_DEPENDS}
                  COMMENT "Running Polli regression tests")
  endif()
else (NOT DEFINED LLVM_MAIN_SRC_DIR)
  set(LLVM_LIT ${LLVM_TOOLS_BINARY_DIR}/llvm-lit)
  set(POLLI_TEST_DEPS llvm-config opt LLVMPolyJIT FileCheck not)

  set(LLVM_BINARY_DIR "${LLVM_BINARY_DIR}")
  set(LLVM_TOOLS_DIR "${LLVM_TOOLS_BINARY_DIR}")
  set(LLVM_LIBS_DIR "${LLVM_BINARY_DIR}/lib")
  set(POLLI_LIB_DIR "${LLVM_LIBS_DIR}")

  add_lit_testsuite(check-polli "Running polli regression tests"
    ${CMAKE_CURRENT_BINARY_DIR}
    PARAMS polli_site_config=${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
    DEPENDS ${POLLI_TEST_DEPS}
    )

  set_target_properties(check-polli PROPERTIES FOLDER "polli tests")
endif (NOT DEFINED LLVM_MAIN_SRC_DIR)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg
)
