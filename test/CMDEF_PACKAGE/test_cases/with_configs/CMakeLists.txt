## Main
#
# Test CMDEF_PACKAGE with CONFIGURATIONS parameter
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_WITH_CONFIGS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test packaging with specific configurations.
#
# Creates a library, installs it with specific configurations, and packages it
# with the same configurations, verifying configuration handling.
#
# <function>()
#
FUNCTION(TEST_CONFIGURATIONS_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP clib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET clib-shared CONFIGURATIONS Debug Release NAMESPACE clib-shared::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET clib-shared
        VERSION 1.3.7
        CONFIGURATIONS Debug Release
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/clib-shared/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("clib-shared" "1.3.7")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)

    MESSAGE(STATUS "Configurations package test passed")
ENDFUNCTION()

##
# Test configurations packaging properties verification.
#
# Creates a library with specific configurations and verifies all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_CONFIGURATIONS_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP cplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET cplib-shared CONFIGURATIONS Debug MinSizeRel NAMESPACE cplib-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET cplib-shared
        VERSION 2.4.6
        CONFIGURATIONS Debug MinSizeRel
    )

    TEST_PACKAGE_EXTENDED_CHECKS("cplib-shared" "2.4.6")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_CONFIGURATIONS_PACKAGE()
TEST_CONFIGURATIONS_PACKAGE_PROPERTIES()
