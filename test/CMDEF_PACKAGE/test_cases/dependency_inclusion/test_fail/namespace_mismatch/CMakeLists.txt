## Test Fail Case - Namespace Mismatch
#
# Test error condition when dependencies have mismatched namespaces
# This test is designed to fail and should only be run when CMDEF_TEST_FAIL_CASES is set
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_NAMESPACE_MISMATCH_FAIL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../cache_var.cmake")

##
# Test namespace mismatch error.
#
# Creates libraries with mismatched namespaces and verifies that
# CMDEF_PACKAGE fails with appropriate error message.
#
# This test should FAIL with namespace mismatch error
#
# <function>()
#
FUNCTION(TEST_NAMESPACE_MISMATCH_FAIL)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP nsdep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP nsmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(nsmain-shared PUBLIC nsdep-shared)

    # Install with DIFFERENT namespaces (this should cause error)
    CMDEF_INSTALL(TARGET nsdep-shared NAMESPACE different-namespace::)
    CMDEF_INSTALL(TARGET nsmain-shared NAMESPACE nsmain-shared::)

    # Verify the namespace properties are different for this test
    GET_TARGET_PROPERTY(main_ns nsmain-shared CMDEF_NAMESPACE)
    GET_TARGET_PROPERTY(dep_ns nsdep-shared CMDEF_NAMESPACE)

    IF(main_ns STREQUAL dep_ns)
        MESSAGE(FATAL_ERROR "Test setup error: namespaces should be different for this test")
    ENDIF()

    MESSAGE(STATUS "Expected FATAL_ERROR: Namespace mismatch between '${main_ns}' and '${dep_ns}'")

    # This should FAIL due to namespace mismatch
    CMDEF_PACKAGE(
        MAIN_TARGET nsmain-shared
        VERSION 1.0.0
    )

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_NAMESPACE_MISMATCH_FAIL()
