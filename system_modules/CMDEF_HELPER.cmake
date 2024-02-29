## Main
#
# Contains helper functions for CMDEF modules
#

IF(DEFINED CMDEF_HELPER_MODULE)
    RETURN()
ENDIF()
SET(CMDEF_HELPER_MODULE 1)

FIND_PACKAGE(CMLIB)

##
# It checks if target name contains SEPARATOR character defined in CMDEF_ENV
#
# <function>(
#   <target_name>
# )
FUNCTION(CMDEF_HELPERS_IS_TARGET_NAME_VALID target_name)
    IF(NOT target_name)
        MESSAGE(FATAL_ERROR "target_name is not set")
    ENDIF()
    STRING(FIND "${target_name}" ${CMDEF_ENV_NAME_SEPARATOR} separator_position)
    IF(NOT separator_position EQUAL -1)
        MESSAGE(WARNING "Target name contains separator: \"${CMDEF_ENV_NAME_SEPARATOR}\". It is forbidden to use this character in target name")
    ENDIF()
ENDFUNCTION()