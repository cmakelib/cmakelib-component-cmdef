## Main
#
# Test missing VERSION parameter error
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_MISSING_VERSION_ERROR_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")

# This should fail because VERSION is required
CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP testlib
    TYPE SHARED
    SOURCES "${LIBRARY_SOURCE_FILE}"
)
