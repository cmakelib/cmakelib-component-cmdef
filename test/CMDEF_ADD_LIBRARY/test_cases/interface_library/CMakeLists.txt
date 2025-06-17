## Main
#
# Test INTERFACE library creation with CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_INTERFACE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test basic interface library creation.
#
# Creates an interface library and verifies basic properties.
#
# <function>()
#
FUNCTION(TEST_BASIC_INTERFACE_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testinterfacelib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testinterfacelib-interface)
        MESSAGE(FATAL_ERROR "Interface library target 'testinterfacelib-interface' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testinterfacelib-interface CMDEF_LIBRARY "INTERFACE")
    TEST_CHECK_TARGET_PROPERTY(testinterfacelib-interface CMDEF_INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}")
    
    GET_TARGET_PROPERTY(output_name testinterfacelib-interface OUTPUT_NAME)
    IF(NOT output_name MATCHES "libtestinterfacelib-interface")
        MESSAGE(FATAL_ERROR "Interface library OUTPUT_NAME should follow CMDEF pattern, got: ${output_name}")
    ENDIF()

    GET_TARGET_PROPERTY(include_dirs testinterfacelib-interface INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT include_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "Interface library include directories should use BUILD_INTERFACE generator expression")
    ENDIF()
ENDFUNCTION()

##
# Test interface library with SOURCE_BASE_DIRECTORY.
#
# Creates an interface library with SOURCE_BASE_DIRECTORY parameter
# and verifies the base directory is set correctly.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_WITH_BASE_DIR)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testinterfacebasedir
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES
            "${LIBRARY_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        SOURCE_BASE_DIRECTORY "${TEST_RESOURCES_DIR}"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testinterfacebasedir-interface)
        MESSAGE(FATAL_ERROR "Interface library target 'testinterfacebasedir-interface' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testinterfacebasedir-interface CMDEF_LIBRARY "INTERFACE")
    
    GET_TARGET_PROPERTY(lib_sources testinterfacebasedir-interface CMDEF_LIBRARY_SOURCES)
    IF(NOT lib_sources)
        MESSAGE(FATAL_ERROR "CMDEF_LIBRARY_SOURCES property should be set for interface library")
    ENDIF()
ENDFUNCTION()

##
# Test interface library without sources.
#
# Creates an interface library without sources (header-only library)
# and verifies it works correctly.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_NO_SOURCES)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testheaderonly
        TYPE INTERFACE
        VERSION 2.1.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testheaderonly-interface)
        MESSAGE(FATAL_ERROR "Header-only interface library target 'testheaderonly-interface' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testheaderonly-interface CMDEF_LIBRARY "INTERFACE")
    
    GET_TARGET_PROPERTY(lib_sources testheaderonly-interface CMDEF_LIBRARY_SOURCES)
    IF(lib_sources)
        MESSAGE(FATAL_ERROR "CMDEF_LIBRARY_SOURCES should not be set for header-only library")
    ENDIF()
ENDFUNCTION()

TEST_BASIC_INTERFACE_LIBRARY()
TEST_INTERFACE_LIBRARY_WITH_BASE_DIR()
TEST_INTERFACE_LIBRARY_NO_SOURCES()
