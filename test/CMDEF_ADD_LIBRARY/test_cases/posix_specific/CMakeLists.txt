## Main
#
# Test POSIX-specific features in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_POSIX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test SOVERSION setting on POSIX systems.
#
# Creates shared libraries with SOVERSION and verifies
# the property is set correctly on POSIX systems.
#
# <function>()
#
FUNCTION(TEST_SOVERSION_ON_POSIX)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixsoversion
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 3.2.1
        SOVERSION 3.2.0
    )

    IF(NOT TARGET testposixsoversion-shared)
        MESSAGE(FATAL_ERROR "Library target 'testposixsoversion-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(soversion testposixsoversion-shared SOVERSION)
    IF(NOT soversion STREQUAL "3.2.0")
        MESSAGE(FATAL_ERROR "SOVERSION should be set to '3.2.0' on POSIX systems, got: ${soversion}")
    ENDIF()
ENDFUNCTION()

##
# Test POSIX library suffixes.
#
# Verifies that POSIX libraries get the correct suffixes.
#
# <function>()
#
FUNCTION(TEST_POSIX_LIBRARY_SUFFIXES)
    # Test shared library suffix
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixshared
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(shared_suffix testposixshared-shared SUFFIX)

    # Use CMDEF cache variable for expected shared library suffix
    IF(NOT shared_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}")
        MESSAGE(FATAL_ERROR "POSIX shared library should have '${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}' suffix, got: ${shared_suffix}")
    ENDIF()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixstatic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(static_suffix testposixstatic-static SUFFIX)
    IF(NOT static_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}")
        MESSAGE(FATAL_ERROR "POSIX static library should have '${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}' suffix, got: ${static_suffix}")
    ENDIF()
ENDFUNCTION()

##
# Test POSITION_INDEPENDENT_CODE for shared libraries.
#
# Verifies that shared libraries have POSITION_INDEPENDENT_CODE
# set to TRUE on POSIX systems.
#
# <function>()
#
FUNCTION(TEST_POSITION_INDEPENDENT_CODE)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixpic
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testposixpic-shared)
        MESSAGE(FATAL_ERROR "Library target 'testposixpic-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(pic testposixpic-shared POSITION_INDEPENDENT_CODE)
    IF(NOT pic)
        MESSAGE(FATAL_ERROR "POSITION_INDEPENDENT_CODE should be TRUE for shared libraries")
    ENDIF()

    MESSAGE(STATUS "POSITION_INDEPENDENT_CODE correctly set for shared library")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixstaticpic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(static_pic testposixstaticpic-static POSITION_INDEPENDENT_CODE)
    IF(static_pic)
        MESSAGE(STATUS "Static library has POSITION_INDEPENDENT_CODE set (may be platform default): ${static_pic}")
    ELSE()
        MESSAGE(STATUS "Static library does not have POSITION_INDEPENDENT_CODE set (expected)")
    ENDIF()
ENDFUNCTION()

##
# Test library naming on POSIX systems.
#
# Verifies that POSIX libraries follow the expected naming convention.
#
# <function>()
#
FUNCTION(TEST_POSIX_LIBRARY_NAMING)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testposixnaming
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(prefix testposixnaming-shared PREFIX)
    IF(NOT prefix STREQUAL "")
        MESSAGE(FATAL_ERROR "PREFIX should be empty for CMDEF libraries, got: '${prefix}'")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testposixnaming-shared OUTPUT_NAME)
    IF(NOT output_name MATCHES "libtestposixnaming-shared")
        MESSAGE(FATAL_ERROR "OUTPUT_NAME should follow CMDEF pattern, got: ${output_name}")
    ENDIF()
ENDFUNCTION()

TEST_SOVERSION_ON_POSIX()
TEST_POSIX_LIBRARY_SUFFIXES()
TEST_POSITION_INDEPENDENT_CODE()
TEST_POSIX_LIBRARY_NAMING()
