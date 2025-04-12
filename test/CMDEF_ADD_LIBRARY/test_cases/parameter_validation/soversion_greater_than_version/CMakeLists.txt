## Main
#
# Test SOVERSION greater than VERSION error
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_SOVERSION_ERROR_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")

IF(NOT CMDEF_OS_POSIX)
    MESSAGE(STATUS "Skipping SOVERSION validation test - not on POSIX system")
    RETURN()
ENDIF()

# This should fail because SOVERSION (2.0.0) is greater than VERSION (1.0.0)
CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP testlib
    TYPE SHARED
    SOURCES "${LIBRARY_SOURCE_FILE}"
    VERSION 1.0.0
    SOVERSION 2.0.0
)
