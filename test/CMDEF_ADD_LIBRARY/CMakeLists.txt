## Main
#
# Test CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF-ADD-LIBRARY-TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../CMDEFConfig.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/interface_library")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/check_function")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/generator_expressions")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/multiple_include_directories")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/version_validation")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/parameter_validation")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/cache_variables_validation")

IF(CMDEF_OS_WINDOWS)
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/windows_specific")
ENDIF()

IF(CMDEF_OS_POSIX)
    TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/posix_specific")
    TEST_RUN_AND_CHECK_OUTPUT("test_cases/soversion"
        FATAL_ERROR_MESSAGE "SOVERSION should not be set for static libraries, got: 1.0.0"
    )
ENDIF()
