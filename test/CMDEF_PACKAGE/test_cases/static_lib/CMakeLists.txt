## Main
#
# Test CMDEF_PACKAGE with static library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_STATIC_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test static library packaging with complete verification.
#
# Creates a static library, installs it, and packages it, verifying all
# INSTALL commands, file creation, and package name suffix.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP slib
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET slib-static NAMESPACE slib-static::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET slib-static
        VERSION 1.5.0
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/slib-static/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("slib-static" "1.5.0")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)

    MESSAGE(STATUS "Static library package test passed")
ENDFUNCTION()

##
# Test static library packaging properties verification.
#
# Creates a static library with include directories and verifies all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP splib
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET splib-static NAMESPACE splib-static::)

    CMDEF_PACKAGE(
        MAIN_TARGET splib-static
        VERSION 3.1.4
    )

    TEST_PACKAGE_EXTENDED_CHECKS("splib-static" "3.1.4")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_STATIC_LIBRARY_PACKAGE()
TEST_STATIC_LIBRARY_PACKAGE_PROPERTIES()
