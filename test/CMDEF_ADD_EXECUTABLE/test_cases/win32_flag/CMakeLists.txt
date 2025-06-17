## Main
#
# Test WIN32 flag behavior
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_WIN32_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test WIN32 flag behavior on different platforms.
#
# Creates executable with WIN32 flag and verifies it's only
# applied when running on Windows platform.
#
# <function>()
#
FUNCTION(TEST_WIN32_FLAG_BEHAVIOR)
    CMDEF_ADD_EXECUTABLE(
        TARGET testwin32exe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
        WIN32 ON
    )

    IF(NOT TARGET testwin32exe)
        MESSAGE(FATAL_ERROR "Target 'testwin32exe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testwin32exe CMDEF_EXECUTABLE TRUE)
    
    GET_TARGET_PROPERTY(target_type testwin32exe TYPE)
    IF(NOT target_type STREQUAL "EXECUTABLE")
        MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE, got: ${target_type}")
    ENDIF()
    
    IF(CMDEF_OS_WINDOWS)
        MESSAGE(STATUS "WIN32 flag test passed on Windows platform")
    ELSE()
        MESSAGE(STATUS "WIN32 flag correctly ignored on non-Windows platform")
    ENDIF()
ENDFUNCTION()

TEST_WIN32_FLAG_BEHAVIOR()
