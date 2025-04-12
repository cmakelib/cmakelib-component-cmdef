## Main
#
# Test CMDEF_PACKAGE invalid argument combinations
#
# Tests various error conditions and invalid parameter combinations
# for the CMDEF_PACKAGE function.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_INVALID_ARGUMENTS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

TEST_RUN_AND_CHECK_OUTPUT("missing_main_target"
    FATAL_ERROR_MESSAGE "MAIN_TARGET"
)

TEST_RUN_AND_CHECK_OUTPUT("missing_version"
    FATAL_ERROR_MESSAGE "VERSION"
)

TEST_RUN_AND_CHECK_OUTPUT("invalid_main_target"
    FATAL_ERROR_MESSAGE "Not a valid CMake target:"
)

TEST_RUN_AND_CHECK_OUTPUT("main_target_not_cmake_target"
    FATAL_ERROR_MESSAGE "Not a valid CMake target:"
)

TEST_RUN_AND_CHECK_OUTPUT("invalid_version_format"
    FATAL_ERROR_MESSAGE "not in valid format"
)
