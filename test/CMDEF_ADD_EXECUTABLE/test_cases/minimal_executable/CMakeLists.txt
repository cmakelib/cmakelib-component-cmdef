## Main
#
# Test minimal executable creation with required parameters only
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MINIMAL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test minimal executable creation with Debug build type.
#
# Creates an executable with CMAKE_BUILD_TYPE set to Debug
# and verifies debug suffix is applied correctly.
#
# <function>()
#
FUNCTION(TEST_MINIMAL_EXECUTABLE_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testminimalexedebug
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testminimalexedebug)
        MESSAGE(FATAL_ERROR "Target 'testminimalexedebug' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testminimalexedebug CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testminimalexedebug OUTPUT_NAME)
    SET(expected_output_name "testminimalexedebug${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test minimal executable creation with Release build type.
#
# Creates an executable with CMAKE_BUILD_TYPE set to Release
# and verifies no debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_MINIMAL_EXECUTABLE_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testminimalexerelease
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testminimalexerelease)
        MESSAGE(FATAL_ERROR "Target 'testminimalexerelease' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testminimalexerelease CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testminimalexerelease OUTPUT_NAME)
    SET(expected_output_name "testminimalexerelease")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test minimal executable creation with multiconfig generator support.
#
# Creates an executable with CMAKE_BUILD_TYPE unset to simulate
# multiconfig generators and verifies generator expressions are used.
#
# <function>()
#
FUNCTION(TEST_MINIMAL_EXECUTABLE_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testminimalexemulti
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testminimalexemulti)
        MESSAGE(FATAL_ERROR "Target 'testminimalexemulti' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testminimalexemulti CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testminimalexemulti OUTPUT_NAME)
    SET(expected_pattern "^testminimalexemulti\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_MINIMAL_EXECUTABLE_DEBUG()
TEST_MINIMAL_EXECUTABLE_RELEASE()
TEST_MINIMAL_EXECUTABLE_MULTICONFIG()
