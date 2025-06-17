## Main
#
# Test SOVERSION handling in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_SOVERSION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test valid SOVERSION on POSIX systems.
#
# Creates a shared library with valid SOVERSION and verifies
# it's set correctly on POSIX systems.
#
# <function>()
#
FUNCTION(TEST_VALID_SOVERSION)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testsoversion
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 2.1.0
        SOVERSION 2.0.0
    )

    IF(NOT TARGET testsoversion-shared)
        MESSAGE(FATAL_ERROR "Library target 'testsoversion-shared' was not created")
    ENDIF()

    IF(CMDEF_OS_POSIX)
        GET_TARGET_PROPERTY(soversion testsoversion-shared SOVERSION)
        IF(NOT soversion STREQUAL "2.0.0")
            MESSAGE(FATAL_ERROR "SOVERSION should be set to '2.0.0' on POSIX systems, got: ${soversion}")
        ENDIF()
        MESSAGE(STATUS "SOVERSION correctly set on POSIX system: ${soversion}")
    ELSE()
        GET_TARGET_PROPERTY(soversion testsoversion-shared SOVERSION)
        IF(soversion)
            MESSAGE(STATUS "SOVERSION ignored on non-POSIX system (expected): ${soversion}")
        ENDIF()
    ENDIF()
ENDFUNCTION()

##
# Test SOVERSION equal to VERSION.
#
# Creates a shared library with SOVERSION equal to VERSION
# and verifies it works correctly.
#
# <function>()
#
FUNCTION(TEST_SOVERSION_EQUAL_VERSION)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testsoversionequal
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.5.0
        SOVERSION 1.5.0
    )

    IF(NOT TARGET testsoversionequal-shared)
        MESSAGE(FATAL_ERROR "Library target 'testsoversionequal-shared' was not created")
    ENDIF()

    IF(CMDEF_OS_POSIX)
        GET_TARGET_PROPERTY(soversion testsoversionequal-shared SOVERSION)
        IF(NOT soversion STREQUAL "1.5.0")
            MESSAGE(FATAL_ERROR "SOVERSION should be set to '1.5.0' on POSIX systems, got: ${soversion}")
        ENDIF()
        MESSAGE(STATUS "SOVERSION equal to VERSION correctly set: ${soversion}")
    ENDIF()
ENDFUNCTION()

##
# Test SOVERSION with static library (should be ignored).
#
# Creates a static library with SOVERSION and verifies
# it's ignored (SOVERSION only applies to shared libraries).
#
# <function>()
#
FUNCTION(TEST_SOVERSION_STATIC_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testsoversionstatic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        SOVERSION 1.0.0
    )

    IF(NOT TARGET testsoversionstatic-static)
        MESSAGE(FATAL_ERROR "Library target 'testsoversionstatic-static' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(soversion testsoversionstatic-static SOVERSION)
    IF(soversion)
        MESSAGE(FATAL_ERROR "SOVERSION should not be set for static libraries, got: ${soversion}")
    ENDIF()
ENDFUNCTION()

##
# Test SOVERSION with interface library (should be ignored).
#
# Creates an interface library with SOVERSION and verifies
# it's ignored (SOVERSION only applies to shared libraries).
#
# <function>()
#
FUNCTION(TEST_SOVERSION_INTERFACE_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testsoversioninterface
        TYPE INTERFACE
        VERSION 1.0.0
        SOVERSION 1.0.0
    )

    IF(NOT TARGET testsoversioninterface-interface)
        MESSAGE(FATAL_ERROR "Library target 'testsoversioninterface-interface' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(soversion testsoversioninterface-interface SOVERSION)
    IF(soversion)
        MESSAGE(FATAL_ERROR "SOVERSION should not be set for interface libraries, got: ${soversion}")
    ENDIF()
ENDFUNCTION()

TEST_VALID_SOVERSION()
TEST_SOVERSION_EQUAL_VERSION()
TEST_SOVERSION_STATIC_LIBRARY()
TEST_SOVERSION_INTERFACE_LIBRARY()
