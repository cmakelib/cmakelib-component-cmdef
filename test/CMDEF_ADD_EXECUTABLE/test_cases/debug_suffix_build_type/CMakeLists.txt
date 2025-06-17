## Main
#
# Test debug suffix with CMAKE_BUILD_TYPE
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_DEBUG_SUFFIX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test debug suffix application with Debug build type.
#
# Creates executable with CMAKE_BUILD_TYPE set to Debug and verifies
# debug suffix is applied correctly.
#
# <function>()
#
FUNCTION(TEST_DEBUG_SUFFIX_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testdebugsuffixdebug
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdebugsuffixdebug OUTPUT_NAME)
    SET(expected_output_name "testdebugsuffixdebug${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test debug suffix application with Release build type.
#
# Creates executable with CMAKE_BUILD_TYPE set to Release and verifies
# no debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_DEBUG_SUFFIX_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testdebugsuffixrelease
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdebugsuffixrelease OUTPUT_NAME)
    SET(expected_output_name "testdebugsuffixrelease")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test debug suffix application for multiconfig generators.
#
# Creates executable with CMAKE_BUILD_TYPE unset and verifies
# generator expressions are used for debug suffix.
#
# <function>()
#
FUNCTION(TEST_DEBUG_SUFFIX_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testdebugsuffixmulti
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdebugsuffixmulti OUTPUT_NAME)
    SET(expected_pattern "^testdebugsuffixmulti\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_DEBUG_SUFFIX_DEBUG()
TEST_DEBUG_SUFFIX_RELEASE()
TEST_DEBUG_SUFFIX_MULTICONFIG()
