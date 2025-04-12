## Main
#
# Test CMDEF_INSTALL with NO_INSTALL_CONFIG option
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_INSTALL_NO_CONFIG_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test installation with NO_INSTALL_CONFIG option.
#
# Creates a library and installs it with NO_INSTALL_CONFIG ON,
# verifying INSTALL(TARGETS) is called but INSTALL(EXPORT) is not.
#
# <function>()
#
FUNCTION(TEST_NO_INSTALL_CONFIG)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP nclib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET nclib-shared NO_INSTALL_CONFIG ON)
    
    TEST_INSTALL_TARGETS_EXPORT_EQUALS("nclib-shared")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("ARCHIVE" "${CMDEF_LIBRARY_INSTALL_DIR}")
    
    TEST_GET_INSTALL_EXPORT_CALLS(export_calls)
    IF(export_calls MATCHES "EXPORT;nclib-shared")
        MESSAGE(FATAL_ERROR "INSTALL(EXPORT) should not be called with NO_INSTALL_CONFIG ON")
    ENDIF()
    
    MESSAGE(STATUS "NO_INSTALL_CONFIG test passed")
ENDFUNCTION()

##
# Test NO_INSTALL_CONFIG installation with property verification.
#
# Creates a library with NO_INSTALL_CONFIG and verifies all target properties
# set by CMDEF_INSTALL are correctly configured, including NO_INSTALL_CONFIG property.
#
# <function>()
#
FUNCTION(TEST_NO_INSTALL_CONFIG_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP ncplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_INSTALL(TARGET ncplib-shared NO_INSTALL_CONFIG ON)

    TEST_CHECK_TARGET_PROPERTY(ncplib-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_PROPERTY(ncplib-shared CMDEF_NO_INSTALL_CONFIG ON)
ENDFUNCTION()

TEST_NO_INSTALL_CONFIG()
TEST_NO_INSTALL_CONFIG_PROPERTIES()
