## Main
#
# INSTALL command override for CMDEF testing
#
# This module provides macros and functions to intercept INSTALL commands
# during testing of CMDEF functionality. It overrides the built-in
# INSTALL command to collect all arguments without executing actual installation.
# Used by both CMDEF_INSTALL and CMDEF_PACKAGE tests.
#

##
# Override INSTALL command to collect data for testing.
#
# This macro intercepts all INSTALL command calls and stores their arguments
# in separate global properties based on the INSTALL command type. The original
# INSTALL command is not executed, allowing tests to verify command parameters
# without performing actual installation.
#
# Arguments are stored in type-specific global properties:
# - CMDEF_TEST_INSTALL_TARGETS_CALLS - for INSTALL(TARGETS ...)
# - CMDEF_TEST_INSTALL_EXPORT_CALLS - for INSTALL(EXPORT ...)
# - CMDEF_TEST_INSTALL_DIRECTORY_CALLS - for INSTALL(DIRECTORY ...)
# - CMDEF_TEST_INSTALL_FILES_CALLS - for INSTALL(FILES ...)
#
# <macro>(
#     <install_arguments>...
# )
#
MACRO(INSTALL)
    SET(install_args ${ARGN})
    LIST(GET install_args 0 install_type)

    IF(install_type STREQUAL "TARGETS")
        SET_PROPERTY(GLOBAL APPEND PROPERTY CMDEF_TEST_INSTALL_TARGETS_CALLS "${ARGN}")
    ELSEIF(install_type STREQUAL "EXPORT")
        SET_PROPERTY(GLOBAL APPEND PROPERTY CMDEF_TEST_INSTALL_EXPORT_CALLS "${ARGN}")
    ELSEIF(install_type STREQUAL "DIRECTORY")
        SET_PROPERTY(GLOBAL APPEND PROPERTY CMDEF_TEST_INSTALL_DIRECTORY_CALLS "${ARGN}")
    ELSEIF(install_type STREQUAL "FILES")
        SET_PROPERTY(GLOBAL APPEND PROPERTY CMDEF_TEST_INSTALL_FILES_CALLS "${ARGN}")
    ELSE()
        SET_PROPERTY(GLOBAL APPEND PROPERTY CMDEF_TEST_INSTALL_OTHER_CALLS "${ARGN}")
    ENDIF()

    GET_PROPERTY(call_count GLOBAL PROPERTY CMDEF_TEST_INSTALL_COUNT)
    IF(NOT call_count)
        SET(call_count 0)
    ENDIF()
    MATH(EXPR call_count "${call_count} + 1")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_COUNT ${call_count})
ENDMACRO()

##
# Retrieve collected INSTALL(TARGETS) command calls.
#
# <function>(
#     <output_var>  // Variable to store the collected INSTALL(TARGETS) calls
# )
#
FUNCTION(TEST_GET_INSTALL_TARGETS_CALLS output_var)
    GET_PROPERTY(install_calls GLOBAL PROPERTY CMDEF_TEST_INSTALL_TARGETS_CALLS)
    SET(${output_var} "${install_calls}" PARENT_SCOPE)
ENDFUNCTION()

##
# Retrieve collected INSTALL(EXPORT) command calls.
#
# <function>(
#     <output_var>  // Variable to store the collected INSTALL(EXPORT) calls
# )
#
FUNCTION(TEST_GET_INSTALL_EXPORT_CALLS output_var)
    GET_PROPERTY(install_calls GLOBAL PROPERTY CMDEF_TEST_INSTALL_EXPORT_CALLS)
    SET(${output_var} "${install_calls}" PARENT_SCOPE)
ENDFUNCTION()

##
# Retrieve collected INSTALL(DIRECTORY) command calls.
#
# <function>(
#     <output_var>  // Variable to store the collected INSTALL(DIRECTORY) calls
# )
#
FUNCTION(TEST_GET_INSTALL_DIRECTORY_CALLS output_var)
    GET_PROPERTY(install_calls GLOBAL PROPERTY CMDEF_TEST_INSTALL_DIRECTORY_CALLS)
    SET(${output_var} "${install_calls}" PARENT_SCOPE)
ENDFUNCTION()

##
# Retrieve collected INSTALL(FILES) command calls.
#
# <function>(
#     <output_var>  // Variable to store the collected INSTALL(FILES) calls
# )
#
FUNCTION(TEST_GET_INSTALL_FILES_CALLS output_var)
    GET_PROPERTY(install_calls GLOBAL PROPERTY CMDEF_TEST_INSTALL_FILES_CALLS)
    SET(${output_var} "${install_calls}" PARENT_SCOPE)
ENDFUNCTION()

##
# Clear all collected INSTALL command data.
#
# Resets all INSTALL calls lists and call count to empty/zero state.
# This should be called before each test to ensure test isolation.
#
# <function>()
#
FUNCTION(TEST_CLEAR_INSTALL_CALLS)
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_TARGETS_CALLS "")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_EXPORT_CALLS "")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_DIRECTORY_CALLS "")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_FILES_CALLS "")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_OTHER_CALLS "")
    SET_PROPERTY(GLOBAL PROPERTY CMDEF_TEST_INSTALL_COUNT 0)
ENDFUNCTION()

##
# Verify INSTALL(TARGETS) destination parameter.
#
# Checks that an INSTALL(TARGETS) command was called with the specified
# destination type and that the destination value matches the expected value.
# This verifies that CMDEF_INSTALL uses correct CMDEF_ENV variables for
# installation destinations.
#
# <function>(
#     <destination_type>  // Type of destination (ARCHIVE, LIBRARY, RUNTIME, BUNDLE, PUBLIC_HEADER)
#     <expected_value>    // Expected destination path (e.g., "lib/", "bin/", "include/")
# )
#
FUNCTION(TEST_INSTALL_TARGETS_DESTINATION_EQUALS destination_type expected_value)
    TEST_GET_INSTALL_TARGETS_CALLS(calls)

    STRING(REGEX MATCH "${destination_type};DESTINATION;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL TARGETS ${destination_type} DESTINATION not found in calls: ${calls}")
    ENDIF()

    SET(actual_value "${CMAKE_MATCH_1}")
    IF(NOT actual_value STREQUAL expected_value)
        MESSAGE(FATAL_ERROR "INSTALL TARGETS ${destination_type} DESTINATION should be '${expected_value}' but is '${actual_value}'")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(TARGETS) EXPORT parameter.
#
# Checks that an INSTALL(TARGETS) command was called with the EXPORT parameter
# and that the export name matches the expected target name.
#
# <function>(
#     <expected_export>  // Expected export name (should match target name)
# )
#
FUNCTION(TEST_INSTALL_TARGETS_EXPORT_EQUALS expected_export)
    TEST_GET_INSTALL_TARGETS_CALLS(calls)

    STRING(REGEX MATCH "EXPORT;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL TARGETS EXPORT not found in calls: ${calls}")
    ENDIF()

    SET(actual_export "${CMAKE_MATCH_1}")
    IF(NOT actual_export STREQUAL expected_export)
        MESSAGE(FATAL_ERROR "INSTALL TARGETS EXPORT should be '${expected_export}' but is '${actual_export}'")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(TARGETS) CONFIGURATIONS parameter.
#
# Checks that an INSTALL(TARGETS) command was called with the CONFIGURATIONS
# parameter and that it contains the expected configuration name.
#
# <function>(
#     <expected_config>  // Expected configuration name (e.g., "Debug", "Release")
# )
#
FUNCTION(TEST_INSTALL_TARGETS_CONFIGURATIONS_CONTAINS expected_config)
    TEST_GET_INSTALL_TARGETS_CALLS(calls)

    STRING(REGEX MATCH "CONFIGURATIONS;([^;]*;)*${expected_config}" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL TARGETS CONFIGURATIONS not found in calls: ${calls}")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(EXPORT) destination parameter.
#
# Checks that an INSTALL(EXPORT) command was called with the correct
# DESTINATION parameter. The destination should include the cmake subdirectory
# and namespace path when applicable.
#
# <function>(
#     <expected_value>  // Expected destination path (e.g., "lib/cmake/namespace/")
# )
#
FUNCTION(TEST_INSTALL_EXPORT_DESTINATION_EQUALS expected_value)
    TEST_GET_INSTALL_EXPORT_CALLS(calls)

    STRING(REGEX MATCH "EXPORT;[^;]+;CONFIGURATIONS;[^;]+;[^;]+;DESTINATION;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL EXPORT DESTINATION not found in calls: ${calls}")
    ENDIF()

    SET(actual_value "${CMAKE_MATCH_1}")
    IF(NOT actual_value STREQUAL expected_value)
        MESSAGE(FATAL_ERROR "INSTALL EXPORT DESTINATION should be '${expected_value}' but is '${actual_value}'")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(EXPORT) NAMESPACE parameter.
#
# Checks that an INSTALL(EXPORT) command was called with the NAMESPACE
# parameter and that the namespace value matches the expected value.
#
# <function>(
#     <expected_namespace>  // Expected namespace (e.g., "mylib::")
# )
#
FUNCTION(TEST_INSTALL_EXPORT_NAMESPACE_EQUALS expected_namespace)
    TEST_GET_INSTALL_EXPORT_CALLS(calls)

    STRING(REGEX MATCH "NAMESPACE;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL EXPORT NAMESPACE not found in calls: ${calls}")
    ENDIF()

    SET(actual_namespace "${CMAKE_MATCH_1}")
    IF(NOT actual_namespace STREQUAL expected_namespace)
        MESSAGE(FATAL_ERROR "INSTALL EXPORT NAMESPACE should be '${expected_namespace}' but is '${actual_namespace}'")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(EXPORT) CONFIGURATIONS parameter.
#
# Checks that an INSTALL(EXPORT) command was called with the CONFIGURATIONS
# parameter and that it contains the expected configuration name.
#
# <function>(
#     <expected_config>  // Expected configuration name (e.g., "Debug", "Release")
# )
#
FUNCTION(TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS expected_config)
    TEST_GET_INSTALL_EXPORT_CALLS(calls)

    STRING(REGEX MATCH "EXPORT;[^;]+;CONFIGURATIONS;([^;]*;)*${expected_config}" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL EXPORT CONFIGURATIONS not found in calls: ${calls}")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(DIRECTORY) destination parameter.
#
# Checks that an INSTALL(DIRECTORY) command was called with the correct
# DESTINATION parameter. This is used to verify include directory installation.
#
# <function>(
#     <expected_value>  // Expected destination path (e.g., "include/")
# )
#
FUNCTION(TEST_INSTALL_DIRECTORY_DESTINATION_EQUALS expected_value)
    TEST_GET_INSTALL_DIRECTORY_CALLS(calls)

    STRING(REGEX MATCH "DIRECTORY;[^;]+;CONFIGURATIONS;[^;]+;[^;]+;DESTINATION;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL DIRECTORY DESTINATION not found in calls: ${calls}")
    ENDIF()

    SET(actual_value "${CMAKE_MATCH_1}")
    IF(NOT actual_value STREQUAL expected_value)
        MESSAGE(FATAL_ERROR "INSTALL DIRECTORY DESTINATION should be '${expected_value}' but is '${actual_value}'")
    ENDIF()
ENDFUNCTION()

##
# Verify INSTALL(FILES) destination parameter.
#
# Checks that an INSTALL(FILES) command was called with the correct
# DESTINATION parameter. This is used to verify package config file installation.
#
# <function>(
#     <expected_value>  // Expected destination path (e.g., "lib/cmake/target/")
# )
#
FUNCTION(TEST_INSTALL_FILES_DESTINATION_EQUALS expected_value)
    TEST_GET_INSTALL_FILES_CALLS(calls)

    STRING(REGEX MATCH "FILES;[^;]+;[^;]+;DESTINATION;([^;]+)" match "${calls}")
    IF(NOT match)
        MESSAGE(FATAL_ERROR "INSTALL FILES DESTINATION not found in calls: ${calls}")
    ENDIF()

    SET(actual_value "${CMAKE_MATCH_1}")
    IF(NOT actual_value STREQUAL expected_value)
        MESSAGE(FATAL_ERROR "INSTALL FILES DESTINATION should be '${expected_value}' but is '${actual_value}'")
    ENDIF()
ENDFUNCTION()
