## Main Orchestrator
#
# Test CMDEF_PACKAGE dependency inclusion - Orchestrator for focused test cases
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_DEPENDENCY_INCLUSION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/basic_dependency_inclusion")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/dependency_exclusion")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/transitive_dependencies")


TEST_RUN_AND_CHECK_OUTPUT(
    "${CMAKE_CURRENT_LIST_DIR}/test_fail/non_installed_dependency"
    "Dependency notinstalled-shared is not installed"
)

TEST_RUN_AND_CHECK_OUTPUT(
    "${CMAKE_CURRENT_LIST_DIR}/test_fail/namespace_mismatch"
    "NAMESPACE of target \"nsdep-shared\" is not the same as the main target's"
)

TEST_RUN_AND_CHECK_OUTPUT(
    "${CMAKE_CURRENT_LIST_DIR}/test_fail/multiple_errors"
    "Dependency notinstalleddep-shared is not installed"
)


