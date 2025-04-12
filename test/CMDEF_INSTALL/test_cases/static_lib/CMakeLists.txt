## Main
#
# Test CMDEF_INSTALL with static library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_INSTALL_STATIC_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../library_tests.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test static library installation with complete INSTALL command verification.
#
# Creates a static library and verifies all INSTALL commands are called
# with correct destinations and parameters.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP alib
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET alib-static)
    LIBRARY_TESTS("alib-static")
ENDFUNCTION()

##
# Test static library installation with property verification.
#
# Creates a static library with include directories and verifies all target
# properties set by CMDEF_INSTALL are correctly configured.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP stlib
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET stlib-static)

    TEST_CHECK_TARGET_PROPERTY(stlib-static CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS(stlib-static INTERFACE "$<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>")
ENDFUNCTION()

##
# Test static library property dependencies.
#
# Verifies that CMDEF_INSTALL correctly reads and uses target properties
# to control its behavior for static libraries.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_PROPERTY_DEPENDENCIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP stpdlib
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    TEST_CHECK_TARGET_HAS_PROPERTY(stpdlib-static CMDEF_INSTALL_INCLUDE_DIRECTORIES)
    TEST_CHECK_TARGET_PROPERTY(stpdlib-static TYPE "STATIC_LIBRARY")

    CMDEF_INSTALL(TARGET stpdlib-static)

    TEST_CHECK_TARGET_PROPERTY(stpdlib-static CMDEF_INSTALL ON)
    TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS(stpdlib-static INTERFACE "$<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>")
ENDFUNCTION()

TEST_STATIC_LIBRARY_INSTALL()
TEST_STATIC_LIBRARY_PROPERTIES()
TEST_STATIC_LIBRARY_PROPERTY_DEPENDENCIES()
