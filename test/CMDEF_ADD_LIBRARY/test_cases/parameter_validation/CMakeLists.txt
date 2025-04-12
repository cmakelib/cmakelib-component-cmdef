## Main
#
# Test CMDEF_ADD_LIBRARY parameter validation
#
# Tests various error conditions and parameter validation scenarios
# for the CMDEF_ADD_LIBRARY function.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_PARAMETER_VALIDATION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

TEST_RUN_AND_CHECK_OUTPUT("missing_library_group"
    FATAL_ERROR_MESSAGE "Key 'LIBRARY_GROUP' is not defined"
)

TEST_RUN_AND_CHECK_OUTPUT("missing_version"
    FATAL_ERROR_MESSAGE "Key 'VERSION' is not defined"
)

TEST_RUN_AND_CHECK_OUTPUT("invalid_type"
    FATAL_ERROR_MESSAGE "Invalid Type 'INVALID'"
)

TEST_RUN_AND_CHECK_OUTPUT("source_base_directory_non_interface"
    FATAL_ERROR_MESSAGE "SOURCE_BASE_DIRECTORY is not supported for non INTERFACE library"
)

TEST_RUN_AND_CHECK_OUTPUT("missing_sources_non_interface"
    FATAL_ERROR_MESSAGE "SOURCES is not defined."
)

TEST_RUN_AND_CHECK_OUTPUT("soversion_greater_than_version"
    FATAL_ERROR_MESSAGE "SOVERSION"
)
