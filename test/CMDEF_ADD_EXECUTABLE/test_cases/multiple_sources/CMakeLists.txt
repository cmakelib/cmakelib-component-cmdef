## Main
#
# Test executable creation with multiple source files
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MULTIPLE_SOURCES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with multiple source files in Debug build type.
#
# Creates an executable with multiple C++ source files and CMAKE_BUILD_TYPE set to Debug
# and verifies all sources are added correctly and debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_SOURCES_DEBUG)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET testmultisourcesexedebug
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 1.2.3
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testmultisourcesexedebug)
        MESSAGE(FATAL_ERROR "Target 'testmultisourcesexedebug' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testmultisourcesexedebug CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(target_sources testmultisourcesexedebug SOURCES)

    SET(expected_sources
        "${MAIN_SOURCE_FILE}"
        "${UTILS_SOURCE_FILE}"
        "${PLATFORM_UTILS_SOURCE_FILE}"
    )

    FOREACH(expected_source IN LISTS expected_sources)
        LIST(FIND target_sources "${expected_source}" source_index)
        IF(source_index EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected source file not found: ${expected_source}")
        ENDIF()
    ENDFOREACH()

    GET_TARGET_PROPERTY(output_name testmultisourcesexedebug OUTPUT_NAME)
    SET(expected_output_name "testmultisourcesexedebug${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "All expected source files found in target")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with multiple source files in Release build type.
#
# Creates an executable with multiple C++ source files and CMAKE_BUILD_TYPE set to Release
# and verifies all sources are added correctly and no debug suffix is applied.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_SOURCES_RELEASE)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testmultisourcesexerelease
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 1.2.3
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testmultisourcesexerelease)
        MESSAGE(FATAL_ERROR "Target 'testmultisourcesexerelease' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testmultisourcesexerelease CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(target_sources testmultisourcesexerelease SOURCES)

    SET(expected_sources
        "${MAIN_SOURCE_FILE}"
        "${UTILS_SOURCE_FILE}"
        "${PLATFORM_UTILS_SOURCE_FILE}"
    )

    FOREACH(expected_source IN LISTS expected_sources)
        LIST(FIND target_sources "${expected_source}" source_index)
        IF(source_index EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected source file not found: ${expected_source}")
        ENDIF()
    ENDFOREACH()

    GET_TARGET_PROPERTY(output_name testmultisourcesexerelease OUTPUT_NAME)
    SET(expected_output_name "testmultisourcesexerelease")

    IF(NOT output_name STREQUAL expected_output_name)
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME '${expected_output_name}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "All expected source files found in target")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable creation with multiple source files for multiconfig generators.
#
# Creates an executable with multiple C++ source files and CMAKE_BUILD_TYPE unset
# and verifies all sources are added correctly and generator expressions are used.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_SOURCES_MULTICONFIG)
    CACHE_VAR_FORCE_UNSET(CMAKE_BUILD_TYPE)

    CMDEF_ADD_EXECUTABLE(
        TARGET testmultisourcesexemulti
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 1.2.3
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testmultisourcesexemulti)
        MESSAGE(FATAL_ERROR "Target 'testmultisourcesexemulti' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testmultisourcesexemulti CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(target_sources testmultisourcesexemulti SOURCES)

    SET(expected_sources
        "${MAIN_SOURCE_FILE}"
        "${UTILS_SOURCE_FILE}"
        "${PLATFORM_UTILS_SOURCE_FILE}"
    )

    FOREACH(expected_source IN LISTS expected_sources)
        LIST(FIND target_sources "${expected_source}" source_index)
        IF(source_index EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected source file not found: ${expected_source}")
        ENDIF()
    ENDFOREACH()

    GET_TARGET_PROPERTY(output_name testmultisourcesexemulti OUTPUT_NAME)
    SET(expected_pattern "^testmultisourcesexemulti\\$<\\$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>$")

    IF(NOT output_name MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected OUTPUT_NAME to match pattern '${expected_pattern}' but got '${output_name}'")
    ENDIF()

    MESSAGE(STATUS "All expected source files found in target")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_MULTIPLE_SOURCES_DEBUG()
TEST_MULTIPLE_SOURCES_RELEASE()
TEST_MULTIPLE_SOURCES_MULTICONFIG()
