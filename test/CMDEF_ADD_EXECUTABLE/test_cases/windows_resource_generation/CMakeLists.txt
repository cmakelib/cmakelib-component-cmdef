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
# Test Windows resource file generation with auto-generated resources.
#
# Creates executable on Windows and verifies auto-generated resource file
# is created and added to target sources.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_RESOURCE_IN_SOURCES)

    CMDEF_ADD_EXECUTABLE(
        TARGET testresourceautoexe
        SOURCES 
            "${MAIN_SOURCE_FILE}"
        VERSION 2.5.1
    )

    GET_TARGET_PROPERTY(target_sources testresourceautoexe SOURCES)

    SET(resource_found FALSE)
    FOREACH(source IN LISTS target_sources)
        IF(source MATCHES ".*\\.rc$")
            SET(resource_found TRUE)
            IF(NOT EXISTS "${source}")
                MESSAGE(FATAL_ERROR "Auto-generated resource file does not exist: ${source}")
            ENDIF()
            BREAK()
        ENDIF()
    ENDFOREACH()
    IF(NOT resource_found)
        MESSAGE(FATAL_ERROR "No auto-generated resource file found in target sources")
    ENDIF()
ENDFUNCTION()

TEST_WINDOWS_RESOURCE_IN_SOURCES()
