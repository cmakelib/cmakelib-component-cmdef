## Main
#
# Test generator expression handling in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_GENEX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test generator expression debug suffix for multi-config generators.
#
# Creates library with CMAKE_BUILD_TYPE set and verifies
# direct debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_DIRECT_DEBUG_SUFFIX)
    # Test that when CMAKE_BUILD_TYPE is set, we get the direct suffix
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testdirectsuffix
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdirectsuffix-shared OUTPUT_NAME)
    MESSAGE(STATUS "Output name with Debug build type: ${output_name}")

    IF(NOT output_name MATCHES ".*${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}$")
        MESSAGE(FATAL_ERROR "Direct debug suffix not found in output name: ${output_name}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test generator expression debug suffix behavior.
#
# Creates library and verifies the actual debug suffix behavior.
# Note: CMDEF may set a default build type even when CMAKE_BUILD_TYPE is unset.
#
# <function>()
#
FUNCTION(TEST_GENERATOR_EXPRESSION_SUFFIX)
    # Save original build type and unset it
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testgenexsuffix
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testgenexsuffix-shared OUTPUT_NAME)
    MESSAGE(STATUS "Output name with unset CMAKE_BUILD_TYPE: ${output_name}")

    SET(has_generator_expr FALSE)
    SET(has_direct_suffix FALSE)

    IF(output_name MATCHES ".*\\$<\\$<CONFIG:DEBUG>:${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}>")
        SET(has_generator_expr TRUE)
        MESSAGE(STATUS "Found generator expression for debug suffix")
    ENDIF()

    IF(output_name MATCHES ".*${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}$")
        SET(has_direct_suffix TRUE)
        MESSAGE(STATUS "Found direct debug suffix")
    ENDIF()

    MESSAGE(STATUS "Output name: ${output_name}/${CMAKE_BUILD_TYPE}")
    IF(NOT has_generator_expr)
        MESSAGE(FATAL_ERROR "Neither generator expression nor direct suffix found: ${output_name}")
    ENDIF()
    IF(has_direct_suffix)
        MESSAGE(FATAL_ERROR "Unexpected direct debug suffix found: ${output_name}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test BUILD_INTERFACE wrapping of INCLUDE_DIRECTORIES.
#
# Verifies that INCLUDE_DIRECTORIES parameter values are wrapped
# with BUILD_INTERFACE generator expressions for all library types.
#
# <function>()
#
FUNCTION(TEST_BUILD_INTERFACE_WRAPPING)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testshared
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    GET_TARGET_PROPERTY(shared_interface_dirs testshared-shared INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT shared_interface_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "SHARED library INTERFACE_INCLUDE_DIRECTORIES not wrapped with BUILD_INTERFACE")
    ENDIF()
    GET_TARGET_PROPERTY(shared_public_dirs testshared-shared INCLUDE_DIRECTORIES)
    IF(NOT shared_public_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "SHARED library INCLUDE_DIRECTORIES not wrapped with BUILD_INTERFACE")
    ENDIF()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP teststatic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    GET_TARGET_PROPERTY(static_interface_dirs teststatic-static INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT static_interface_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "STATIC library INTERFACE_INCLUDE_DIRECTORIES not wrapped with BUILD_INTERFACE")
    ENDIF()
    GET_TARGET_PROPERTY(static_public_dirs teststatic-static INCLUDE_DIRECTORIES)
    IF(NOT static_public_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "STATIC library INCLUDE_DIRECTORIES not wrapped with BUILD_INTERFACE")
    ENDIF()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testinterface
        TYPE INTERFACE
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    GET_TARGET_PROPERTY(interface_dirs testinterface-interface INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT interface_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "INTERFACE library INCLUDE_DIRECTORIES not wrapped with BUILD_INTERFACE")
    ENDIF()
ENDFUNCTION()

TEST_DIRECT_DEBUG_SUFFIX()
TEST_GENERATOR_EXPRESSION_SUFFIX()
TEST_BUILD_INTERFACE_WRAPPING()
