## Main
#
# Test minimal executable creation with required parameters only
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MINIMAL_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test minimal executable creation with required parameters only.
#
# Creates an executable with TARGET, SOURCES, and VERSION parameters
# and verifies basic properties are set correctly.
#
# <function>()
#
FUNCTION(TEST_MINIMAL_EXECUTABLE_CREATION)
    CMDEF_ADD_EXECUTABLE(
        TARGET testminimalexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    IF(NOT TARGET testminimalexe)
        MESSAGE(FATAL_ERROR "Target 'testminimalexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testminimalexe CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY(testminimalexe OUTPUT_NAME "testminimalexed")
ENDFUNCTION()

TEST_MINIMAL_EXECUTABLE_CREATION()
