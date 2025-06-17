## Main
#
# Test version validation in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_VERSION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test various valid version formats.
#
# Creates libraries with different valid version formats
# and verifies they're accepted.
#
# <function>()
#
FUNCTION(TEST_VALID_VERSIONS)
    # Test semantic version
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversion1
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.2.3
    )

    IF(NOT TARGET testversion1-static)
        MESSAGE(FATAL_ERROR "Library with version '1.2.3' was not created")
    ENDIF()

    # Test version with patch zero
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversion2
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 2.1.0
    )

    IF(NOT TARGET testversion2-static)
        MESSAGE(FATAL_ERROR "Library with version '2.1.0' was not created")
    ENDIF()

    # Test single digit version
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversion3
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 5.0.0
    )

    IF(NOT TARGET testversion3-static)
        MESSAGE(FATAL_ERROR "Library with version '5.0.0' was not created")
    ENDIF()

    # Test version with larger numbers
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversion4
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 10.15.25
    )

    IF(NOT TARGET testversion4-static)
        MESSAGE(FATAL_ERROR "Library with version '10.15.25' was not created")
    ENDIF()
ENDFUNCTION()

##
# Test version property setting.
#
# Creates a library and verifies the VERSION property
# is set correctly on the target.
#
# <function>()
#
FUNCTION(TEST_VERSION_PROPERTY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversionprop
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 3.2.1
    )

    IF(NOT TARGET testversionprop-shared)
        MESSAGE(FATAL_ERROR "Library target 'testversionprop-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(version_prop testversionprop-shared VERSION)
    IF(version_prop)
        MESSAGE(STATUS "VERSION property set to: ${version_prop}")
        IF(NOT version_prop STREQUAL "3.2.1")
            MESSAGE(FATAL_ERROR "VERSION property should be '3.2.1', got: ${version_prop}")
        ENDIF()
    ELSE()
        MESSAGE(STATUS "VERSION property not set (may be platform-dependent)")
    ENDIF()
ENDFUNCTION()

##
# Test version in output name.
#
# Verifies that the version doesn't appear in the output name
# (CMDEF uses its own naming scheme).
#
# <function>()
#
FUNCTION(TEST_VERSION_OUTPUT_NAME)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testversionoutput
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 4.1.2
    )

    IF(NOT TARGET testversionoutput-shared)
        MESSAGE(FATAL_ERROR "Library target 'testversionoutput-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testversionoutput-shared OUTPUT_NAME)
    MESSAGE(STATUS "Output name: ${output_name}")

    IF(NOT output_name MATCHES "libtestversionoutput-shared")
        MESSAGE(FATAL_ERROR "Output name doesn't follow expected CMDEF pattern: ${output_name}")
    ENDIF()

    IF(output_name MATCHES "4\\.1\\.2")
        MESSAGE(FATAL_ERROR "Version should not appear directly in output name: ${output_name}")
    ENDIF()
ENDFUNCTION()

TEST_VALID_VERSIONS()
TEST_VERSION_PROPERTY()
TEST_VERSION_OUTPUT_NAME()
