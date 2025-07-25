## Main
#
# Test CMDEF_ADD_EXECUTABLE function
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../CMDEFConfig.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/minimal_executable")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/executable_with_includes")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/custom_output_name")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/check_function")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/debug_suffix_build_type")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/generator_expression_suffix")

IF(CMDEF_OS_WINDOWS)
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/win32_flag")
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/windows_msvc_runtime")
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/windows_resource_generation")
ENDIF()

IF(CMDEF_OS_MACOS)
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/macos_bundle")
ENDIF()

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/multiple_sources")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/all_parameters")

TEST_RUN_AND_CHECK_OUTPUT("test_cases/missing_target_error"
    FATAL_ERROR_MESSAGE "Key 'TARGET' is not defined"
)

TEST_RUN_AND_CHECK_OUTPUT("test_cases/missing_sources_error"
    FATAL_ERROR_MESSAGE "Key 'SOURCES' is not defined"
)

TEST_RUN_AND_CHECK_OUTPUT("test_cases/missing_version_error"
    FATAL_ERROR_MESSAGE "Key 'VERSION' is not defined"
)

TEST_RUN_AND_CHECK_OUTPUT("test_cases/invalid_target_name_warning"
    WARNING_MESSAGE "Target name contains separator:"
)

TEST_RUN_AND_CHECK_OUTPUT("test_cases/invalid_version_error"
    FATAL_ERROR_MESSAGE "not in valid format"
)
