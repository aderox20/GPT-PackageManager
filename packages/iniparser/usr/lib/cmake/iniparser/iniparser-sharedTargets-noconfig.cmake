#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "iniparser-shared" for configuration ""
set_property(TARGET iniparser-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(iniparser-shared PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libiniparser.so.4.2.6"
  IMPORTED_SONAME_NOCONFIG "libiniparser.so.4"
  )

list(APPEND _cmake_import_check_targets iniparser-shared )
list(APPEND _cmake_import_check_files_for_iniparser-shared "${_IMPORT_PREFIX}/lib/libiniparser.so.4.2.6" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
