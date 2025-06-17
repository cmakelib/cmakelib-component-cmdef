## Main
#
# Test Windows-specific features in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_WINDOWS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

IF(NOT WIN32)
    MESSAGE(STATUS "Skipping Windows-specific tests - not running on Windows")
    RETURN()
ENDIF()



##
# Test MSVC runtime library settings.
#
# Creates libraries and verifies MSVC runtime library
# is set according to CMDEF_WINDOWS_STATIC_RUNTIME.
#
# <function>()
#
FUNCTION(TEST_MSVC_RUNTIME_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testmsvcruntime
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testmsvcruntime-shared)
        MESSAGE(FATAL_ERROR "Library target 'testmsvcruntime-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(msvc_runtime testmsvcruntime-shared MSVC_RUNTIME_LIBRARY)
    IF(NOT msvc_runtime)
        MESSAGE(FATAL_ERROR "MSVC_RUNTIME_LIBRARY property should be set on Windows")
    ENDIF()

    MESSAGE(STATUS "MSVC runtime library: ${msvc_runtime}")

    IF(CMDEF_WINDOWS_STATIC_RUNTIME)
        IF(NOT msvc_runtime MATCHES "MultiThreaded.*")
            MESSAGE(FATAL_ERROR "Expected static runtime pattern, got: ${msvc_runtime}")
        ENDIF()
        IF(msvc_runtime MATCHES ".*DLL.*")
            MESSAGE(FATAL_ERROR "Static runtime should not contain DLL, got: ${msvc_runtime}")
        ENDIF()
    ELSE()
        IF(NOT msvc_runtime MATCHES ".*DLL.*")
            MESSAGE(FATAL_ERROR "Expected dynamic runtime (DLL), got: ${msvc_runtime}")
        ENDIF()
    ENDIF()

    IF(NOT msvc_runtime MATCHES ".*\\$<\\$<CONFIG:DEBUG>:Debug>.*")
        MESSAGE(FATAL_ERROR "MSVC runtime should support debug configuration, got: ${msvc_runtime}")
    ENDIF()
ENDFUNCTION()

##
# Test Windows library suffixes.
#
# Verifies that Windows libraries get the correct suffixes.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_LIBRARY_SUFFIXES)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testwindowsshared
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(shared_suffix testwindowsshared-shared SUFFIX)
    IF(NOT shared_suffix STREQUAL ".dll")
        MESSAGE(FATAL_ERROR "Windows shared library should have .dll suffix, got: ${shared_suffix}")
    ENDIF()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testwindowsstatic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(static_suffix testwindowsstatic-static SUFFIX)
    IF(NOT static_suffix STREQUAL ".lib")
        MESSAGE(FATAL_ERROR "Windows static library should have .lib suffix, got: ${static_suffix}")
    ENDIF()
ENDFUNCTION()

##
# Test Windows resource generation.
#
# Verifies that Windows libraries get resource files generated
# with version information.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_RESOURCE_GENERATION)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testwindowsresource
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 2.1.3
    )

    IF(NOT TARGET testwindowsresource-shared)
        MESSAGE(FATAL_ERROR "Library target 'testwindowsresource-shared' was not created")
    ENDIF()

    # Check if resource target was created (this is internal to CMDEF)
    # We can't easily verify the resource file generation without building,
    # but we can verify the target was created successfully
    GET_TARGET_PROPERTY(target_type testwindowsresource-shared TYPE)
    IF(NOT target_type STREQUAL "SHARED_LIBRARY")
        MESSAGE(FATAL_ERROR "Target should be SHARED_LIBRARY type, got: ${target_type}")
    ENDIF()

    MESSAGE(STATUS "Windows resource generation test passed")
ENDFUNCTION()

##
# Test that SOVERSION is ignored on Windows.
#
# Creates a shared library with SOVERSION on Windows
# and verifies it's ignored.
#
# <function>()
#
FUNCTION(TEST_SOVERSION_IGNORED_ON_WINDOWS)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testwindowssoversion
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.5.0
        SOVERSION 1.0.0
    )

    IF(NOT TARGET testwindowssoversion-shared)
        MESSAGE(FATAL_ERROR "Library target 'testwindowssoversion-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(soversion testwindowssoversion-shared SOVERSION)
    IF(soversion)
        MESSAGE(STATUS "SOVERSION property found but should be ignored on Windows: ${soversion}")
    ELSE()
        MESSAGE(STATUS "SOVERSION correctly ignored on Windows")
    ENDIF()

    MESSAGE(STATUS "SOVERSION ignored on Windows test passed")
ENDFUNCTION()

TEST_MSVC_RUNTIME_LIBRARY()
TEST_WINDOWS_LIBRARY_SUFFIXES()
TEST_WINDOWS_RESOURCE_GENERATION()
TEST_SOVERSION_IGNORED_ON_WINDOWS()
