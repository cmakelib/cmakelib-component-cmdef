## Main
#
# Test Windows resource file generation
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_RESOURCE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test Windows resource file generation.
#
# Creates executable on Windows and verifies resource file
# is generated and added to target sources.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_RESOURCE_GENERATION)
    IF(NOT CMDEF_OS_WINDOWS)
        MESSAGE(STATUS "Skipping resource generation test - not on Windows")
        RETURN()
    ENDIF()
    
    CMDEF_ADD_EXECUTABLE(
        TARGET testresourceexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 2.5.1
    )

    GET_TARGET_PROPERTY(target_sources testresourceexe SOURCES)
    
    SET(resource_found FALSE)
    FOREACH(source IN LISTS target_sources)
        IF(source MATCHES ".*\\.rc$")
            SET(resource_found TRUE)
            MESSAGE(STATUS "Found resource file: ${source}")
            
            IF(EXISTS "${source}")
                MESSAGE(STATUS "Resource file exists on disk")
            ELSE()
                MESSAGE(FATAL_ERROR "Resource file does not exist: ${source}")
            ENDIF()
            BREAK()
        ENDIF()
    ENDFOREACH()
    
    IF(NOT resource_found)
        MESSAGE(FATAL_ERROR "No resource file found in target sources")
    ENDIF()
ENDFUNCTION()

TEST_WINDOWS_RESOURCE_GENERATION()
