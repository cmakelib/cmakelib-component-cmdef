## Main
#
# Test CMDEF_PACKAGE with shared library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_SHARED_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test shared library packaging with complete verification.
#
# Creates a shared library, installs it, and packages it, verifying all
# INSTALL commands, file creation, and package properties.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP shlib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET shlib-shared NAMESPACE shlib-shared::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET shlib-shared
        VERSION 2.1.0
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/shlib-shared/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("shlib-shared" "2.1.0")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)

    MESSAGE(STATUS "Shared library package test passed")
ENDFUNCTION()

##
# Test shared library packaging properties verification.
#
# Creates a shared library with include directories and verifies all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP shplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET shplib-shared NAMESPACE shplib-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET shplib-shared
        VERSION 4.2.1
    )

    TEST_PACKAGE_EXTENDED_CHECKS("shplib-shared" "4.2.1")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_SHARED_LIBRARY_PACKAGE()
TEST_SHARED_LIBRARY_PACKAGE_PROPERTIES()
