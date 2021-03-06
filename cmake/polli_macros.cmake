macro(add_polli_executable name)
  set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
  set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib)
  add_executable( ${name} ${ARGN} )

  if(POLLI_LINK_LIBS)
    foreach(lib ${POLLI_LINK_LIBS})
      target_link_libraries(${name} LINK_PRIVATE ${lib})
    endforeach(lib)
  endif(POLLI_LINK_LIBS)

  set_target_properties(${name} PROPERTIES FOLDER "Polli executables")
  install (TARGETS ${name}
    RUNTIME DESTINATION bin
  )
endmacro(add_polli_executable)

macro(add_polli_library name)
  set(srcs ${ARGN})
  if (MODULE)
    set(libkind MODULE)
  elseif (SHARED_LIBRARY)
    set(libkind SHARED)
  else()
    set(libkind)
  endif()
  add_library( ${name} ${libkind} ${srcs} )
  if( LLVM_COMMON_DEPENDS )
    add_dependencies( ${name} ${LLVM_COMMON_DEPENDS} )
  endif( LLVM_COMMON_DEPENDS )
  if( LLVM_USED_LIBS )
    foreach(lib ${LLVM_USED_LIBS})
      target_link_libraries( ${name} ${lib} )
    endforeach(lib)
  endif( LLVM_USED_LIBS )

  if( LLVM_LINK_COMPONENTS )
    llvm_config(${name} ${LLVM_LINK_COMPONENTS})
  endif( LLVM_LINK_COMPONENTS )
  if(POLLI_LINK_LIBS)
    foreach(lib ${POLLI_LINK_LIBS})
      target_link_libraries(${name} PUBLIC ${lib})
    endforeach(lib)
  endif(POLLI_LINK_LIBS)

  install(TARGETS ${name}
    EXPORT LLVMExports
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX})
  set_property(GLOBAL APPEND PROPERTY LLVM_EXPORTS ${name})
  set_output_directory(${name} LIBRARY_DIR ${POLLI_LIBRARY_OUTPUT_INTDIR})
  unset(POLLI_LINK_LIBS)
endmacro(add_polli_library)

macro(add_polli_loadable_module name)
  set(srcs ${ARGN})
  # klduge: pass different values for MODULE with multiple targets in same dir
  # this allows building shared-lib and module in same dir
  # there must be a cleaner way to achieve this....
  if (MODULE)
  else()
    set(GLOBAL_NOT_MODULE TRUE)
  endif()
  set(MODULE TRUE)
  add_polli_library(${name} ${srcs})
  if (GLOBAL_NOT_MODULE)
    unset (MODULE)
  endif()
  if (APPLE)
    # Darwin-specific linker flags for loadable modules.
    set_target_properties(${name} PROPERTIES
      LINK_FLAGS "-Wl,-flat_namespace -Wl,-undefined -Wl,suppress")
  endif()
endmacro(add_polli_loadable_module)
