## Main
#
# Test executable creation with custom output name
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_OUTPUT_NAME_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with custom output name in Debug build type.
#
# Creates an executable with OUTPUT_NAME parameter and CMAKE_BUILD_TYPE set to Debug
# and verifies debug suffix is applied to custom output name.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_OUTPUT_NAME_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testoutputexedebug
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.5.0
        OUTPUT_NAME "custom-executable-name"
    )

    IF(NOT TARGET testoutputexedebug)
        MESSAGE(FATAL_ERROR "Target 'testoutputexedebug' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testoutputexedebug OUTPUT_NAME)
    SET(expected_output_name "custom-executable-name${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testoutputexedebug CMDEF_EXECUTABLE TRUE)

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with custom output name in Release build type.
#
# Creates an executable with OUTPUT_NAME parameter and CMAKE_BUILD_TYPE set to Release
# and verifies no debug suffix is applied to custom output name.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_OUTPUT_NAME_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testoutputexerelease
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.5.0
        OUTPUT_NAME "custom-executable-name"
    )

    IF(NOT TARGET testoutputexerelease)
        MESSAGE(FATAL_ERROR "Target 'testoutputexerelease' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testoutputexerelease OUTPUT_NAME)
    SET(expected_output_name "custom-executable-name")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testoutputexerelease CMDEF_EXECUTABLE TRUE)

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with custom output name for multiconfig generators.
#
# Creates an executable with OUTPUT_NAME parameter and CMAKE_BUILD_TYPE unset
# and verifies generator expressions are used with custom output name.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_OUTPUT_NAME_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testoutputexemulti
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.5.0
        OUTPUT_NAME "custom-executable-name"
    )

    IF(NOT TARGET testoutputexemulti)
        MESSAGE(FATAL_ERROR "Target 'testoutputexemulti' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(output_name testoutputexemulti OUTPUT_NAME)
    SET(expected_pattern "^custom-executable-name\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testoutputexemulti CMDEF_EXECUTABLE TRUE)

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_CUSTOM_OUTPUT_NAME_DEBUG()
TEST_CUSTOM_OUTPUT_NAME_RELEASE()
TEST_CUSTOM_OUTPUT_NAME_MULTICONFIG()
