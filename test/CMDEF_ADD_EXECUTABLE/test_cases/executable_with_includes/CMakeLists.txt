## Main
#
# Test executable creation with include directories
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_INCLUDES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with include directories in Debug build type.
#
# Creates an executable with INCLUDE_DIRECTORIES parameter and CMAKE_BUILD_TYPE set to Debug
# and verifies include directories and debug suffix are set correctly.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_WITH_INCLUDES_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testincludesexedebug
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        VERSION 2.1.0
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testincludesexedebug)
        MESSAGE(FATAL_ERROR "Target 'testincludesexedebug' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testincludesexedebug CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testincludesexedebug INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(output_name testincludesexedebug OUTPUT_NAME)
    SET(expected_output_name "testincludesexedebug${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with include directories in Release build type.
#
# Creates an executable with INCLUDE_DIRECTORIES parameter and CMAKE_BUILD_TYPE set to Release
# and verifies include directories are set correctly and no debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_WITH_INCLUDES_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testincludesexerelease
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        VERSION 2.1.0
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testincludesexerelease)
        MESSAGE(FATAL_ERROR "Target 'testincludesexerelease' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testincludesexerelease CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testincludesexerelease INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(output_name testincludesexerelease OUTPUT_NAME)
    SET(expected_output_name "testincludesexerelease")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with include directories for multiconfig generators.
#
# Creates an executable with INCLUDE_DIRECTORIES parameter and CMAKE_BUILD_TYPE unset
# and verifies include directories are set correctly and generator expressions are used.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_WITH_INCLUDES_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testincludesexemulti
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        VERSION 2.1.0
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testincludesexemulti)
        MESSAGE(FATAL_ERROR "Target 'testincludesexemulti' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testincludesexemulti CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testincludesexemulti INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(output_name testincludesexemulti OUTPUT_NAME)
    SET(expected_pattern "^testincludesexemulti\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_EXECUTABLE_WITH_INCLUDES_DEBUG()
TEST_EXECUTABLE_WITH_INCLUDES_RELEASE()
TEST_EXECUTABLE_WITH_INCLUDES_MULTICONFIG()
