## Main
#
# Test generator expression debug suffix for multi-config generators
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_GENEX_SUFFIX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test generator expression debug suffix with Debug build type.
#
# Creates executable with CMAKE_BUILD_TYPE set to Debug and verifies
# direct debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_GENERATOR_EXPRESSION_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testgenexdebug
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testgenexdebug OUTPUT_NAME)
    SET(expected_output_name "testgenexdebug${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "Generator expression Debug test passed with output name: ${output_name}")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test generator expression debug suffix with Release build type.
#
# Creates executable with CMAKE_BUILD_TYPE set to Release and verifies
# no debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_GENERATOR_EXPRESSION_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testgenexrelease
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testgenexrelease OUTPUT_NAME)
    SET(expected_output_name "testgenexrelease")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "Generator expression Release test passed with output name: ${output_name}")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test generator expression debug suffix for multiconfig generators.
#
# Creates executable with CMAKE_BUILD_TYPE unset and verifies
# generator expressions are used for debug suffix.
#
# <function>()
#
FUNCTION(TEST_GENERATOR_EXPRESSION_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testgenexmulti
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testgenexmulti OUTPUT_NAME)
    SET(expected_pattern "^testgenexmulti\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "Generator expression multiconfig test passed with output name: ${output_name}")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_GENERATOR_EXPRESSION_DEBUG()
TEST_GENERATOR_EXPRESSION_RELEASE()
TEST_GENERATOR_EXPRESSION_MULTICONFIG()
