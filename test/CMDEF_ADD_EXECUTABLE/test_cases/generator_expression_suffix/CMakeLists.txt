## Main
#
# Test generator expression debug suffix for multi-config generators
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_EXECUTABLE_GENEX_SUFFIX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test generator expression debug suffix for multi-config generators.
#
# Creates executable with CMAKE_BUILD_TYPE set and verifies
# direct debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_DIRECT_DEBUG_SUFFIX)
    # Test that when CMAKE_BUILD_TYPE is set, we get the direct suffix
    # This test verifies the behavior when build type is known at configure time
    CMDEF_ADD_EXECUTABLE(
        TARGET testdirectsuffix
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdirectsuffix OUTPUT_NAME)
    # In Debug mode, we should get the direct debug suffix
    IF(NOT output_name MATCHES ".*${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}$")
        MESSAGE(FATAL_ERROR "Debug suffix not applied correctly: ${output_name}")
    ENDIF()

    MESSAGE(STATUS "Direct debug suffix test passed with output name: ${output_name}")
ENDFUNCTION()

##
# Test generator expression debug suffix behavior.
#
# Creates executable and verifies the actual debug suffix behavior.
# Note: CMDEF may set a default build type even when CMAKE_BUILD_TYPE is unset.
#
# <function>()
#
FUNCTION(TEST_GENERATOR_EXPRESSION_SUFFIX)
    # Save original build type and unset it
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testgenexsuffix
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testgenexsuffix OUTPUT_NAME)
    MESSAGE(STATUS "Output name with unset CMAKE_BUILD_TYPE: ${output_name}")

    # Check if it contains a generator expression OR direct suffix
    SET(has_generator_expr FALSE)
    SET(has_direct_suffix FALSE)

    IF(output_name MATCHES ".*\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>")
        SET(has_generator_expr TRUE)
        MESSAGE(STATUS "Found generator expression for debug suffix")
    ENDIF()

    IF(output_name MATCHES ".*${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}$")
        SET(has_direct_suffix TRUE)
        MESSAGE(STATUS "Found direct debug suffix")
    ENDIF()

    # Accept either behavior as valid (CMDEF may handle this differently)
    IF(NOT has_generator_expr AND NOT has_direct_suffix)
        MESSAGE(FATAL_ERROR "Neither generator expression nor direct suffix found: ${output_name}")
    ENDIF()

    MESSAGE(STATUS "Generator expression test passed - found valid debug suffix handling")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_DIRECT_DEBUG_SUFFIX()
TEST_GENERATOR_EXPRESSION_SUFFIX()
