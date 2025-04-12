## Main
#
# Test CMDEF_INSTALL with multiple targets
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_INSTALL_MULTIPLE_CALLS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test multiple CMDEF_INSTALL calls work independently.
#
# Creates two targets and installs them separately, verifying
# each gets its own INSTALL commands without interference.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_INSTALL_CALLS)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mlib1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mlib2
        TYPE STATIC
        VERSION 2.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET mlib1-shared)
    CMDEF_INSTALL(TARGET mlib2-static)
    
    TEST_GET_INSTALL_TARGETS_CALLS(targets_calls)

    IF(NOT targets_calls MATCHES "TARGETS;mlib1-shared")
        MESSAGE(FATAL_ERROR "INSTALL(TARGETS) not found for mlib1-shared")
    ENDIF()
    IF(NOT targets_calls MATCHES "TARGETS;mlib2-static")
        MESSAGE(FATAL_ERROR "INSTALL(TARGETS) not found for mlib2-static")
    ENDIF()

    TEST_GET_INSTALL_EXPORT_CALLS(export_calls)
    IF(NOT export_calls MATCHES "EXPORT;mlib1-shared")
        MESSAGE(FATAL_ERROR "INSTALL(EXPORT) not found for mlib1-shared")
    ENDIF()
    IF(NOT export_calls MATCHES "EXPORT;mlib2-static")
        MESSAGE(FATAL_ERROR "INSTALL(EXPORT) not found for mlib2-static")
    ENDIF()
    
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("ARCHIVE" "${CMDEF_LIBRARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("LIBRARY" "${CMDEF_LIBRARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("RUNTIME" "${CMDEF_BINARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("BUNDLE" "${CMDEF_BINARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("PUBLIC_HEADER" "${CMDEF_INCLUDE_INSTALL_DIR}")
ENDFUNCTION()

##
# Test multiple CMDEF_INSTALL calls with property verification.
#
# Creates two targets and installs them separately, verifying all target
# properties set by CMDEF_INSTALL are correctly configured for both targets.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_INSTALL_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mplib1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mplib2
        TYPE STATIC
        VERSION 2.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_INSTALL(TARGET mplib1-shared)
    CMDEF_INSTALL(TARGET mplib2-static)

    TEST_CHECK_TARGET_PROPERTY(mplib1-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_PROPERTY(mplib2-static CMDEF_INSTALL ON)

    TEST_CHECK_TARGET_PROPERTY(mplib1-shared TYPE "SHARED_LIBRARY")
    TEST_CHECK_TARGET_PROPERTY(mplib2-static TYPE "STATIC_LIBRARY")

    TEST_CHECK_TARGET_LACKS_PROPERTY(mplib1-shared CMDEF_NAMESPACE)
    TEST_CHECK_TARGET_LACKS_PROPERTY(mplib2-static CMDEF_NAMESPACE)
    TEST_CHECK_TARGET_LACKS_PROPERTY(mplib1-shared CMDEF_NO_INSTALL_CONFIG)
    TEST_CHECK_TARGET_LACKS_PROPERTY(mplib2-static CMDEF_NO_INSTALL_CONFIG)
ENDFUNCTION()

TEST_MULTIPLE_INSTALL_CALLS()
TEST_MULTIPLE_INSTALL_PROPERTIES()
