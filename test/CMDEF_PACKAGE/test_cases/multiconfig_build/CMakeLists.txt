## Main
#
# Test CMDEF_PACKAGE with multiconfig build (CMAKE_BUILD_TYPE not set)
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_MULTICONFIG_BUILD_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Verify that PACKAGE custom target exists.
#
# Checks that ADD_CUSTOM_TARGET created the PACKAGE target for multiconfig builds.
# This target should only exist when CMAKE_BUILD_TYPE is not set.
#
# <macro>()
#
MACRO(TEST_PACKAGE_CUSTOM_TARGET_EXISTS)
    IF(NOT TARGET PACKAGE)
        MESSAGE(FATAL_ERROR "PACKAGE custom target should exist for multiconfig builds")
    ENDIF()
ENDMACRO()

##
# Verify that PACKAGE custom target has correct properties.
#
# Checks that the PACKAGE target has the expected properties set by CMDEF_PACKAGE,
# including FOLDER property and dependencies.
#
# <macro>(
#     <main_target>  // Main target that should be a dependency of PACKAGE target
# )
#
MACRO(TEST_PACKAGE_CUSTOM_TARGET_PROPERTIES main_target)
    GET_TARGET_PROPERTY(folder_prop PACKAGE FOLDER)
    IF(NOT folder_prop STREQUAL "${CMDEF_MULTICONF_FOLDER_NAME}")
        MESSAGE(FATAL_ERROR "PACKAGE target FOLDER should be '${CMDEF_MULTICONF_FOLDER_NAME}' but is '${folder_prop}'")
    ENDIF()

    GET_TARGET_PROPERTY(dependencies PACKAGE MANUALLY_ADDED_DEPENDENCIES)
    IF(NOT dependencies OR NOT "${main_target}" IN_LIST dependencies)
        MESSAGE(FATAL_ERROR "PACKAGE target should depend on '${main_target}' but dependencies are: ${dependencies}")
    ENDIF()
ENDMACRO()

##
# Test multiconfig packaging with ADD_CUSTOM_TARGET verification.
#
# Creates a library, installs it, and packages it without CMAKE_BUILD_TYPE set,
# verifying that ADD_CUSTOM_TARGET creates the PACKAGE target with correct properties.
#
# <function>()
#
FUNCTION(TEST_MULTICONFIG_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mclib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET mclib-shared NAMESPACE mclib-shared::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET mclib-shared
        VERSION 2.5.8
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/mclib-shared/")
    
    TEST_PACKAGE_CONFIG_FILE_EXISTS("mclib-shared")
    TEST_PACKAGE_VERSION_FILE_EXISTS("mclib-shared")
    TEST_PACKAGE_VERSION_FILE_CONTAINS("mclib-shared" "2.5.8")

    TEST_PACKAGE_CUSTOM_TARGET_EXISTS()
    TEST_PACKAGE_CUSTOM_TARGET_PROPERTIES("mclib-shared")

    TEST_PACKAGE_CPACK_PACKAGE_VERSION("2.5.8")
    TEST_PACKAGE_CPACK_OUTPUT_CONFIG_FILE()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_MULTICONFIG_PACKAGE()
