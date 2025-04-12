## Test Fail Case - Non-Installed Dependency
#
# Test error condition when a CMDEF dependency is not installed
# This test is designed to fail and should only be run when CMDEF_TEST_FAIL_CASES is set
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_NON_INSTALLED_DEPENDENCY_FAIL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../cache_var.cmake")

##
# Test non-installed CMDEF dependency error.
#
# Creates a CMDEF dependency that is not installed and verifies that
# CMDEF_PACKAGE fails with appropriate error message.
#
# This test should FAIL with: "Dependency <target> is not installed"
#
# <function>()
#
FUNCTION(TEST_NON_INSTALLED_CMDEF_DEPENDENCY_FAIL)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP notinstalled
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP failmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(failmain-shared PUBLIC notinstalled-shared)

    # Install only the main target, NOT the dependency
    CMDEF_INSTALL(TARGET failmain-shared NAMESPACE failmain-shared::)

    # This should FAIL because notinstalled-shared is not installed
    MESSAGE(STATUS "Expected FATAL_ERROR: Dependency notinstalled-shared is not installed")
    
    CMDEF_PACKAGE(
        MAIN_TARGET failmain-shared
        VERSION 1.0.0
    )

    # If we reach here, the test failed to fail
    MESSAGE(FATAL_ERROR "TEST FAILURE: CMDEF_PACKAGE should have failed due to non-installed dependency")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

# This test is designed to fail with a specific error message
# It will be run by TEST_RUN_AND_CHECK_OUTPUT which expects the failure

TEST_NON_INSTALLED_CMDEF_DEPENDENCY_FAIL()
