## Main
#
# Test CMDEF_ADD_LIBRARY integration with CMDEF cache variables
#
# This test validates that CMDEF_ADD_LIBRARY properly uses CMDEF_* cache variables
# from CMDEF_ENV when creating libraries and setting target properties.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_INTEGRATION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test CMDEF_ADD_LIBRARY integration with cache variables.
#
# Creates libraries and verifies that CMDEF cache variables are properly
# used in the library creation process and target properties.
#
# <function>()
#
FUNCTION(TEST_CACHE_VARIABLES_INTEGRATION)
    MESSAGE(STATUS "Testing CMDEF_ADD_LIBRARY integration with cache variables")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testcachevars
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testcachevars-shared)
        MESSAGE(FATAL_ERROR "Library target 'testcachevars-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testcachevars-shared OUTPUT_NAME)
    IF(NOT output_name MATCHES "${CMDEF_LIBRARY_PREFIX}")
        MESSAGE(FATAL_ERROR "OUTPUT_NAME should start with CMDEF_LIBRARY_PREFIX '${CMDEF_LIBRARY_PREFIX}', got: ${output_name}")
    ENDIF()

    GET_TARGET_PROPERTY(suffix testcachevars-shared SUFFIX)
    IF(NOT suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}")
        MESSAGE(FATAL_ERROR "SUFFIX should match CMDEF_LIBRARY_NAME_SUFFIX_SHARED '${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}', got: ${suffix}")
    ENDIF()

    GET_TARGET_PROPERTY(prefix testcachevars-shared PREFIX)
    IF(NOT prefix STREQUAL "")
        MESSAGE(FATAL_ERROR "PREFIX should be empty for CMDEF libraries, got: '${prefix}'")
    ENDIF()

    GET_TARGET_PROPERTY(cmdef_lib testcachevars-shared CMDEF_LIBRARY)
    IF(NOT cmdef_lib STREQUAL "SHARED")
        MESSAGE(FATAL_ERROR "CMDEF_LIBRARY property should be 'SHARED', got: ${cmdef_lib}")
    ENDIF()

    GET_TARGET_PROPERTY(install_dirs testcachevars-shared CMDEF_INSTALL_INCLUDE_DIRECTORIES)
    IF(NOT install_dirs)
        MESSAGE(FATAL_ERROR "CMDEF_INSTALL_INCLUDE_DIRECTORIES should be set")
    ENDIF()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testcachevars
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testcachevars-static)
        MESSAGE(FATAL_ERROR "Static library target 'testcachevars-static' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(static_suffix testcachevars-static SUFFIX)
    IF(NOT static_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}")
        MESSAGE(FATAL_ERROR "Static library SUFFIX should match CMDEF_LIBRARY_NAME_SUFFIX_STATIC '${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}', got: ${static_suffix}")
    ENDIF()

    MESSAGE(STATUS "Cache variables integration test passed")
ENDFUNCTION()

##
# Test CMDEF_ADD_LIBRARY debug suffix integration.
#
# Tests that debug suffixes from CMDEF_ENV are properly applied
# to library names based on build configuration.
#
# <function>()
#
FUNCTION(TEST_DEBUG_SUFFIX_INTEGRATION)
    MESSAGE(STATUS "Testing debug suffix integration with CMDEF_ADD_LIBRARY")

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testdebug
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testdebug-shared)
        MESSAGE(FATAL_ERROR "Debug library target 'testdebug-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(debug_output_name testdebug-shared OUTPUT_NAME)
    IF(NOT debug_output_name MATCHES "${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}")
        MESSAGE(FATAL_ERROR "Debug library OUTPUT_NAME should contain debug suffix '${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}', got: ${debug_output_name}")
    ENDIF()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testrelease
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testrelease-shared)
        MESSAGE(FATAL_ERROR "Release library target 'testrelease-shared' was not created")
    ENDIF()

    # The double d needs to be matched here to not confuse shareD for a debug suffix
    GET_TARGET_PROPERTY(release_output_name testrelease-shared OUTPUT_NAME)
    IF(release_output_name MATCHES "d${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}$")
        MESSAGE(FATAL_ERROR "Release library OUTPUT_NAME should NOT contain debug suffix '${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}', got: ${release_output_name}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)

    MESSAGE(STATUS "Debug suffix integration test passed")
ENDFUNCTION()

##
# Test CMDEF cache variables for Windows platform.
#
# Validates all CMDEF_* cache variables have correct values
# when running on Windows systems.
#
# <function>()
#
FUNCTION(TEST_PLATFORM_SUFFIX_INTEGRATION)
    MESSAGE(STATUS "Testing platform-specific suffix integration")

    # Create libraries to test platform-specific suffixes
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testplatform
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testplatform
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testplatform-shared)
        MESSAGE(FATAL_ERROR "Platform shared library target 'testplatform-shared' was not created")
    ENDIF()

    IF(NOT TARGET testplatform-static)
        MESSAGE(FATAL_ERROR "Platform static library target 'testplatform-static' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(shared_suffix testplatform-shared SUFFIX)
    GET_TARGET_PROPERTY(static_suffix testplatform-static SUFFIX)

    IF(NOT shared_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}")
        MESSAGE(FATAL_ERROR "Shared library suffix '${shared_suffix}' does not match CMDEF_LIBRARY_NAME_SUFFIX_SHARED '${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}'")
    ENDIF()

    IF(NOT static_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}")
        MESSAGE(FATAL_ERROR "Static library suffix '${static_suffix}' does not match CMDEF_LIBRARY_NAME_SUFFIX_STATIC '${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}'")
    ENDIF()
ENDFUNCTION()

TEST_CACHE_VARIABLES_INTEGRATION()
TEST_DEBUG_SUFFIX_INTEGRATION()
TEST_PLATFORM_SUFFIX_INTEGRATION()
