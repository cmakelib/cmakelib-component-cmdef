## Main
#
# Tests for CMDEF_PACKAGE module
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/executable")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/static_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/shared_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/interface_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/with_configs")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/with_cpack_config")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/multiconfig_build")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/dependency_inclusion")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/invalid_arguments")
