##
# TEST.cmake are shared with CMLIB to avoid unnecesssary dependencies.
# TESTS.cmake is properly validated.
#

FIND_PACKAGE(CMLIB)

IF(NOT EXISTS "${CMLIB_DIR}")
	MESSAGE(FATAL_ERROR "Cannot find CMLIB_DIR '${CMLIB_DIR}'")
ENDIF()

INCLUDE("${CMLIB_DIR}/test/TEST.cmake")