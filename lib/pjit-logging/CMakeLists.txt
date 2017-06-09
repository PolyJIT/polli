add_polli_library(pjit-logging STATIC
  Log.cpp
)

add_polli_library(pjit-logging_shared SHARED
  Log.cpp
)

set_target_properties(pjit-logging_shared PROPERTIES OUTPUT_NAME pjit-logging)
