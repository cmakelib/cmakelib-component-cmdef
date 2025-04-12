## Test Fail Case - Multiple Dependency Errors
#
# Test error condition with multiple types of dependency errors
# This test is designed to fail and should only be run when CMDEF_TEST_FAIL_CASES is set
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_MULTIPLE_ERRORS_FAIL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../cache_var.cmake")

##
# Test multiple dependency errors.
#
# Creates a scenario with multiple types of errors to verify
# that CMDEF_PACKAGE fails appropriately.
#
# This test should FAIL with the first error encountered
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_DEPENDENCY_ERRORS_FAIL)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    # Create dependencies with various issues
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP installeddep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP notinstalleddep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP wrongnamespacedep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    # Create main library
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multierror
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(multierror-shared PUBLIC
        installeddep-shared
        notinstalleddep-shared
        wrongnamespacedep-shared
    )

    # Install some targets with correct namespace
    CMDEF_INSTALL(TARGET installeddep-shared NAMESPACE multierror-shared::)
    CMDEF_INSTALL(TARGET multierror-shared NAMESPACE multierror-shared::)

    # Install one with wrong namespace
    CMDEF_INSTALL(TARGET wrongnamespacedep-shared NAMESPACE wrong::)

    # Don't install notinstalleddep-shared

    MESSAGE(STATUS "Expected FATAL_ERROR: Multiple dependency errors")

    # This should FAIL due to dependency issues
    CMDEF_PACKAGE(
        MAIN_TARGET multierror-shared
        VERSION 1.0.0
    )

    # If we reach here, the test failed to fail
    MESSAGE(FATAL_ERROR "TEST FAILURE: CMDEF_PACKAGE should have failed due to dependency errors")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

# This test is designed to fail with a specific error message
# It will be run by TEST_RUN_AND_CHECK_OUTPUT which expects the failure

TEST_MULTIPLE_DEPENDENCY_ERRORS_FAIL()
