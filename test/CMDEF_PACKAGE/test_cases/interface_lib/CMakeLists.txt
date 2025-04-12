## Main
#
# Test CMDEF_PACKAGE with interface library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_INTERFACE_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test interface library packaging with complete verification.
#
# Creates an interface library, installs it, and packages it, verifying all
# INSTALL commands, file creation, and interface-specific properties.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()
    
    SET(original_build_type "${CMAKE_BUILD_TYPE}")
    SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP ilib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    
    CMDEF_INSTALL(TARGET ilib-interface NAMESPACE ilib-interface::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET ilib-interface
        VERSION 1.8.2
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/ilib-interface/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("ilib-interface" "1.8.2")
    
    IF(DEFINED original_build_type)
        SET(CMAKE_BUILD_TYPE "${original_build_type}" CACHE STRING "" FORCE)
    ELSE()
        UNSET(CMAKE_BUILD_TYPE CACHE)
    ENDIF()
    
    MESSAGE(STATUS "Interface library package test passed")
ENDFUNCTION()

##
# Test interface library packaging properties verification.
#
# Creates an interface library with sources and verifies all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()
    
    SET(original_build_type "${CMAKE_BUILD_TYPE}")
    SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP iplib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET iplib-interface NAMESPACE iplib-interface::)

    CMDEF_PACKAGE(
        MAIN_TARGET iplib-interface
        VERSION 0.9.1
    )

    TEST_PACKAGE_EXTENDED_CHECKS("iplib-interface" "0.9.1")
    
    IF(DEFINED original_build_type)
        SET(CMAKE_BUILD_TYPE "${original_build_type}" CACHE STRING "" FORCE)
    ELSE()
        UNSET(CMAKE_BUILD_TYPE CACHE)
    ENDIF()
ENDFUNCTION()

TEST_INTERFACE_LIBRARY_PACKAGE()
TEST_INTERFACE_LIBRARY_PACKAGE_PROPERTIES()
