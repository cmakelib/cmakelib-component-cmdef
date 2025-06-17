## Main
#
# Test executable creation with multiple source files
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MULTIPLE_SOURCES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with multiple source files.
#
# Creates an executable with multiple C++ source files
# and verifies all sources are added correctly.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_SOURCES)
    CMDEF_ADD_EXECUTABLE(
        TARGET testmultisourcesexe
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
            "${PLATFORM_UTILS_SOURCE_FILE}"
        VERSION 1.2.3
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testmultisourcesexe)
        MESSAGE(FATAL_ERROR "Target 'testmultisourcesexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testmultisourcesexe CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(target_sources testmultisourcesexe SOURCES)
    
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
    
    MESSAGE(STATUS "All expected source files found in target")
ENDFUNCTION()

TEST_MULTIPLE_SOURCES()
