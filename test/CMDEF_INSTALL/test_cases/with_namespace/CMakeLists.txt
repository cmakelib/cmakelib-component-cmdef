## Main
#
# Test CMDEF_INSTALL with namespace parameter
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_INSTALL_NAMESPACE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test installation with namespace parameter.
#
# Creates a library and installs it with a namespace, verifying
# INSTALL(EXPORT) is called with correct NAMESPACE and DESTINATION.
#
# <function>()
#
FUNCTION(TEST_NAMESPACE_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP nlib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET nlib-shared NAMESPACE nlib::)
    
    TEST_INSTALL_TARGETS_EXPORT_EQUALS("nlib-shared")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("ARCHIVE" "${CMDEF_LIBRARY_INSTALL_DIR}")
    
    TEST_INSTALL_EXPORT_NAMESPACE_EQUALS("nlib::")
    TEST_INSTALL_EXPORT_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/nlib/")
    
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("DEBUG")
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("RELEASE")
ENDFUNCTION()

##
# Test namespace installation with property verification.
#
# Creates a library with namespace and verifies all target properties
# set by CMDEF_INSTALL are correctly configured, including namespace property.
#
# <function>()
#
FUNCTION(TEST_NAMESPACE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP nplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET nplib-shared NAMESPACE nplib::)

    TEST_CHECK_TARGET_PROPERTY(nplib-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_PROPERTY(nplib-shared CMDEF_NAMESPACE "nplib")
    TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS(nplib-shared INTERFACE "$<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>")

    GET_TARGET_PROPERTY(namespace_value nplib-shared CMDEF_NAMESPACE)
    IF(namespace_value MATCHES "::")
        MESSAGE(FATAL_ERROR "CMDEF_NAMESPACE should be stripped of '::' suffix but contains '::': ${namespace_value}")
    ENDIF()
ENDFUNCTION()

##
# Test namespace property edge cases.
#
# Verifies namespace handling with different namespace formats and
# that properties are set correctly.
#
# <function>()
#
FUNCTION(TEST_NAMESPACE_EDGE_CASES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP neclib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET neclib-shared NAMESPACE "MyCompany::MyLib::")

    TEST_CHECK_TARGET_PROPERTY(neclib-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_PROPERTY(neclib-shared CMDEF_NAMESPACE "MyCompany::MyLib")

    GET_TARGET_PROPERTY(complex_namespace neclib-shared CMDEF_NAMESPACE)
    IF(complex_namespace MATCHES "::$")
        MESSAGE(FATAL_ERROR "CMDEF_NAMESPACE should not end with '::' but does: ${complex_namespace}")
    ENDIF()
ENDFUNCTION()

TEST_NAMESPACE_INSTALL()
TEST_NAMESPACE_PROPERTIES()
TEST_NAMESPACE_EDGE_CASES()
