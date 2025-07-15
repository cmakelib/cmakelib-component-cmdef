## Main
#
# Test executable creation with all optional parameters
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_ALL_PARAMS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with all optional parameters in Debug build type.
#
# Creates an executable with all possible parameters and CMAKE_BUILD_TYPE set to Debug
# and verifies debug suffix is applied to custom output name.
#
# <function>()
#
FUNCTION(TEST_ALL_PARAMETERS_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testallparamsexedebug
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 3.2.1
        OUTPUT_NAME "comprehensive-test-executable"
        INCLUDE_DIRECTORIES
            "${EXECUTABLE_INCLUDE_DIR}"
        WIN32 ON
        MACOS_BUNDLE ON
    )

    IF(NOT TARGET testallparamsexedebug)
        MESSAGE(FATAL_ERROR "Target 'testallparamsexedebug' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testallparamsexedebug CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testallparamsexedebug OUTPUT_NAME)
    SET(expected_output_name "comprehensive-test-executable${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testallparamsexedebug INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(target_type testallparamsexedebug TYPE)
    IF(NOT target_type STREQUAL "EXECUTABLE")
        MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE, got: ${target_type}")
    ENDIF()

    GET_TARGET_PROPERTY(target_sources testallparamsexedebug SOURCES)
    LIST(LENGTH target_sources source_count)
    IF(source_count LESS 3)
        MESSAGE(FATAL_ERROR "Expected at least 3 source files, got: ${source_count}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with all optional parameters in Release build type.
#
# Creates an executable with all possible parameters and CMAKE_BUILD_TYPE set to Release
# and verifies no debug suffix is applied to custom output name.
#
# <function>()
#
FUNCTION(TEST_ALL_PARAMETERS_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testallparamsexerelease
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 3.2.1
        OUTPUT_NAME "comprehensive-test-executable"
        INCLUDE_DIRECTORIES
            "${EXECUTABLE_INCLUDE_DIR}"
        WIN32 ON
        MACOS_BUNDLE ON
    )

    IF(NOT TARGET testallparamsexerelease)
        MESSAGE(FATAL_ERROR "Target 'testallparamsexerelease' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testallparamsexerelease CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testallparamsexerelease OUTPUT_NAME)
    SET(expected_output_name "comprehensive-test-executable")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testallparamsexerelease INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(target_type testallparamsexerelease TYPE)
    IF(NOT target_type STREQUAL "EXECUTABLE")
        MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE, got: ${target_type}")
    ENDIF()

    GET_TARGET_PROPERTY(target_sources testallparamsexerelease SOURCES)
    LIST(LENGTH target_sources source_count)
    IF(source_count LESS 3)
        MESSAGE(FATAL_ERROR "Expected at least 3 source files, got: ${source_count}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with all optional parameters for multiconfig generators.
#
# Creates an executable with all possible parameters and CMAKE_BUILD_TYPE unset
# and verifies generator expressions are used with custom output name.
#
# <function>()
#
FUNCTION(TEST_ALL_PARAMETERS_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testallparamsexemulti
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 3.2.1
        OUTPUT_NAME "comprehensive-test-executable"
        INCLUDE_DIRECTORIES
            "${EXECUTABLE_INCLUDE_DIR}"
        WIN32 ON
        MACOS_BUNDLE ON
    )

    IF(NOT TARGET testallparamsexemulti)
        MESSAGE(FATAL_ERROR "Target 'testallparamsexemulti' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testallparamsexemulti CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(output_name testallparamsexemulti OUTPUT_NAME)
    SET(expected_pattern "^comprehensive-test-executable\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testallparamsexemulti INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(target_type testallparamsexemulti TYPE)
    IF(NOT target_type STREQUAL "EXECUTABLE")
        MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE, got: ${target_type}")
    ENDIF()

    GET_TARGET_PROPERTY(target_sources testallparamsexemulti SOURCES)
    LIST(LENGTH target_sources source_count)
    IF(source_count LESS 3)
        MESSAGE(FATAL_ERROR "Expected at least 3 source files, got: ${source_count}")
    ENDIF()

    MESSAGE(STATUS "All parameters test passed successfully")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_ALL_PARAMETERS_DEBUG()
TEST_ALL_PARAMETERS_RELEASE()
TEST_ALL_PARAMETERS_MULTICONFIG()
