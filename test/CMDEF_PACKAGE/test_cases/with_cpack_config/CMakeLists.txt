## Main
#
# Test CMDEF_PACKAGE with custom CPACK_CONFIG_FILE parameter
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_WITH_CPACK_CONFIG_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test packaging with custom CPack config file.
#
# Creates a library, installs it, and packages it with a custom CPack config file,
# verifying that the custom config is used instead of the auto-generated one.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_CPACK_CONFIG_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP cclib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_INSTALL(TARGET cclib-shared NAMESPACE cclib-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET cclib-shared
        VERSION 1.9.5
        CPACK_CONFIG_FILE "${CUSTOM_CPACK_CONFIG_FILE}"
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/cclib-shared/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("cclib-shared" "1.9.5")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test custom CPack config packaging properties verification.
#
# Creates a library with custom CPack config and verifies all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_CPACK_CONFIG_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP ccplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET ccplib-shared NAMESPACE ccplib-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET ccplib-shared
        VERSION 3.7.1
        CPACK_CONFIG_FILE "${CUSTOM_CPACK_CONFIG_FILE}"
    )

    TEST_PACKAGE_EXTENDED_CHECKS("ccplib-shared" "3.7.1")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_CUSTOM_CPACK_CONFIG_PACKAGE()
TEST_CUSTOM_CPACK_CONFIG_PACKAGE_PROPERTIES()
