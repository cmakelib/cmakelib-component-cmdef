## Main
#
# Test executable creation with custom output name
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_OUTPUT_NAME_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with custom output name.
#
# Creates an executable with OUTPUT_NAME parameter
# and verifies output name is set correctly.
#
# <function>()
#
FUNCTION(TEST_CUSTOM_OUTPUT_NAME)
    CMDEF_ADD_EXECUTABLE(
        TARGET testoutputexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.5.0
        OUTPUT_NAME "custom-executable-name"
    )

    IF(NOT TARGET testoutputexe)
        MESSAGE(FATAL_ERROR "Target 'testoutputexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testoutputexe OUTPUT_NAME "custom-executable-named")
    TEST_CHECK_TARGET_PROPERTY(testoutputexe CMDEF_EXECUTABLE TRUE)
ENDFUNCTION()

TEST_CUSTOM_OUTPUT_NAME()
