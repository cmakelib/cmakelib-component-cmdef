## Main
#
# Test CMDEF_INSTALL with shared library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_INSTALL_SHARED_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../library_tests.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test shared library installation with complete INSTALL command verification.
#
# Creates a shared library and verifies all INSTALL commands are called
# with correct destinations and parameters.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP slib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET slib-shared)

    LIBRARY_TESTS("slib-shared")

    TEST_CHECK_TARGET_PROPERTY(slib-shared CMDEF_INSTALL ON)
ENDFUNCTION()

##
# Test shared library installation with property verification.
#
# Creates a shared library with include directories and verifies all target
# properties set by CMDEF_INSTALL are correctly configured.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP splib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET splib-shared)

    TEST_CHECK_TARGET_PROPERTY(splib-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS(splib-shared INTERFACE "$<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>")
ENDFUNCTION()

##
# Test shared library installation without include directories.
#
# Creates a shared library without INSTALL_INCLUDE_DIRECTORIES and verifies
# that INSTALL_INTERFACE generator expression is NOT added.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_NO_INSTALL_INCLUDES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP snilib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET snilib-shared)

    TEST_CHECK_TARGET_PROPERTY(snilib-shared CMDEF_INSTALL ON)

    TEST_CHECK_TARGET_LACKS_PROPERTY(snilib-shared CMDEF_INSTALL_INCLUDE_DIRECTORIES)

    GET_TARGET_PROPERTY(include_dirs snilib-shared INTERFACE_INCLUDE_DIRECTORIES)
    IF(include_dirs AND include_dirs MATCHES "INSTALL_INTERFACE")
        MESSAGE(FATAL_ERROR "INTERFACE_INCLUDE_DIRECTORIES should not contain INSTALL_INTERFACE when no INSTALL_INCLUDE_DIRECTORIES. Got: ${include_dirs}")
    ENDIF()
ENDFUNCTION()

##
# Test shared library property dependencies.
#
# Verifies that CMDEF_INSTALL correctly reads and uses target properties
# to control its behavior.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_PROPERTY_DEPENDENCIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP spdlib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    TEST_CHECK_TARGET_HAS_PROPERTY(spdlib-shared CMDEF_INSTALL_INCLUDE_DIRECTORIES)
    TEST_CHECK_TARGET_PROPERTY(spdlib-shared TYPE "SHARED_LIBRARY")

    CMDEF_INSTALL(TARGET spdlib-shared)

    TEST_CHECK_TARGET_PROPERTY(spdlib-shared CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS(spdlib-shared INTERFACE "$<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>")
ENDFUNCTION()

TEST_SHARED_LIBRARY_INSTALL()
TEST_SHARED_LIBRARY_PROPERTIES()
TEST_SHARED_LIBRARY_NO_INSTALL_INCLUDES()
TEST_SHARED_LIBRARY_PROPERTY_DEPENDENCIES()
