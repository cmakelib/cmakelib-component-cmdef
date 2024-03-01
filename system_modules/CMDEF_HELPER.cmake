## Main
#
# Contains helper functions for CMDEF modules
#

INCLUDE_GUARD(GLOBAL)

FIND_PACKAGE(CMLIB REQUIRED)



##
# It checks if target name contains ${CMDEF_ENV_NAME_SEPARATOR} character defined by CMDEF_ENV
#
# <function>(
#   <target_name>
# )
FUNCTION(CMDEF_HELPER_IS_TARGET_NAME_VALID target_name)
    IF(NOT target_name)
        MESSAGE(FATAL_ERROR "target_name is not set")
    ENDIF()
    STRING(FIND "${target_name}" ${CMDEF_ENV_NAME_SEPARATOR} separator_position)
    IF(NOT separator_position EQUAL -1)
        MESSAGE(WARNING "Target name contains separator: \"${CMDEF_ENV_NAME_SEPARATOR}\". It is forbidden to use this character in target name")
    ENDIF()
ENDFUNCTION()