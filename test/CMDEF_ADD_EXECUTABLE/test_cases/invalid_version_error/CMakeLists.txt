## Main
#
# Test error when VERSION parameter has invalid format
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_EXECUTABLE_INVALID_VERSION_ERROR_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

CMDEF_ADD_EXECUTABLE(
    TARGET test_invalid_version
    SOURCES "${MAIN_SOURCE_FILE}"
    VERSION "invalid.version.format"
)
