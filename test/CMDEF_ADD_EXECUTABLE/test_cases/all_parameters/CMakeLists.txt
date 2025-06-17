## Main
#
# Test executable creation with all optional parameters
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_ALL_PARAMS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with all optional parameters.
#
# Creates an executable with all possible parameters
# and verifies they are all set correctly.
#
# <function>()
#
FUNCTION(TEST_ALL_PARAMETERS)
    CMDEF_ADD_EXECUTABLE(
        TARGET testallparamsexe
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

    IF(NOT TARGET testallparamsexe)
        MESSAGE(FATAL_ERROR "Target 'testallparamsexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testallparamsexe CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY(testallparamsexe OUTPUT_NAME "comprehensive-test-executabled")
    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testallparamsexe INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(target_type testallparamsexe TYPE)
    IF(NOT target_type STREQUAL "EXECUTABLE")
        MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE, got: ${target_type}")
    ENDIF()
    
    GET_TARGET_PROPERTY(target_sources testallparamsexe SOURCES)
    LIST(LENGTH target_sources source_count)
    IF(source_count LESS 3)
        MESSAGE(FATAL_ERROR "Expected at least 3 source files, got: ${source_count}")
    ENDIF()
    
    MESSAGE(STATUS "All parameters test passed successfully")
ENDFUNCTION()

TEST_ALL_PARAMETERS()
