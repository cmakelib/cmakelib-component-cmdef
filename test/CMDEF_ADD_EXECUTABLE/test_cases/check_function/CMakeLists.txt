## Main
#
# Test CMDEF_ADD_EXECUTABLE_CHECK function
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_CHECK_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test CMDEF_ADD_EXECUTABLE_CHECK function.
#
# Creates executables and verifies the check function
# correctly identifies CMDEF-created targets.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_CHECK_FUNCTION)
    CMDEF_ADD_EXECUTABLE(
        TARGET testcheckexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    ADD_EXECUTABLE(regularcmakeexe "${MAIN_SOURCE_FILE}")

    CMDEF_ADD_EXECUTABLE_CHECK(testcheckexe cmdef_result)
    IF(NOT DEFINED cmdef_result)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_EXECUTABLE_CHECK failed to identify CMDEF target")
    ENDIF()
    IF(NOT cmdef_result STREQUAL "testcheckexe")
        MESSAGE(FATAL_ERROR "CMDEF_ADD_EXECUTABLE_CHECK returned wrong target name: ${cmdef_result}")
    ENDIF()

    CMDEF_ADD_EXECUTABLE_CHECK(regularcmakeexe regular_result)
    IF(DEFINED regular_result)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_EXECUTABLE_CHECK incorrectly identified regular CMake target")
    ENDIF()
ENDFUNCTION()

TEST_EXECUTABLE_CHECK_FUNCTION()
