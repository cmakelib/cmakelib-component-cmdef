## Main
#
# Test invalid VERSION format error
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_INVALID_VERSION_FORMAT_ERROR_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")

CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP testlib
    TYPE SHARED
    VERSION 1.0.0
    SOURCES "${LIBRARY_SOURCE_FILE}"
)

CMDEF_INSTALL(TARGET testlib-shared NAMESPACE testlib-shared::)

CMDEF_PACKAGE(
    MAIN_TARGET testlib-shared
    VERSION "invalid_version_format"
)
