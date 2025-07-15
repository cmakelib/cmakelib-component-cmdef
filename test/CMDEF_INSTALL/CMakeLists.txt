## Main
#
# Test CMDEF_INSTALL
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_INSTALL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../CMDEFConfig.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/shared_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/static_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/interface_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/executable")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/with_namespace")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/with_configs")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/include_dirs")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/no_config")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/multiple_calls")
