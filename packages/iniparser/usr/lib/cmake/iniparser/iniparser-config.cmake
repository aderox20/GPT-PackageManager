#include(CMakeFindDependencyMacro)
#find_dependency(<there are none>)
set(_supported_components static shared)

# if the targets files exist it is save to include them, even if they are not
# demanded
include("${CMAKE_CURRENT_LIST_DIR}/iniparser-sharedTargets.cmake" OPTIONAL)
include("${CMAKE_CURRENT_LIST_DIR}/iniparser-staticTargets.cmake" OPTIONAL)

# if a specific component is explicitly demanded...
foreach(_comp ${iniparser_FIND_COMPONENTS})
  # ...check if it is supported and...
  if(NOT
     ";${_supported_components};"
     MATCHES
     ${_comp})
    set(iniparser_FOUND False)
    set(iniparser_NOT_FOUND_MESSAGE "Unsupported component: ${_comp}")
    continue()
  endif()
  # ...check if it is installed...
  include("${CMAKE_CURRENT_LIST_DIR}/iniparser-${_comp}Targets.cmake"
          OPTIONAL RESULT_VARIABLE included)
  if(NOT included)
    # ...and fail verbosely
    set(iniparser_FOUND False)
    set(iniparser_NOT_FOUND_MESSAGE
        "Requested component not installed: ${_comp}")
  endif()
endforeach()
