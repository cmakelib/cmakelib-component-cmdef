## Main
#
# Test missing SOURCES for non-INTERFACE library error
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_MISSING_SOURCES_ERROR_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")

# This should fail because SOURCES is required for non-INTERFACE libraries
CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP testlib
    TYPE SHARED
    VERSION 1.0.0
)
