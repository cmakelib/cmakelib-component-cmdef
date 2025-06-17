## Main
#
# Test executable creation with include directories
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_INCLUDES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test executable creation with include directories.
#
# Creates an executable with INCLUDE_DIRECTORIES parameter
# and verifies include directories are set correctly.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_WITH_INCLUDES)
    CMDEF_ADD_EXECUTABLE(
        TARGET testincludesexe
        SOURCES
            "${MAIN_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        VERSION 2.1.0
        INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}"
    )

    IF(NOT TARGET testincludesexe)
        MESSAGE(FATAL_ERROR "Target 'testincludesexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testincludesexe CMDEF_EXECUTABLE TRUE)
    TEST_CHECK_TARGET_PROPERTY_CONTAINS(testincludesexe INCLUDE_DIRECTORIES "${EXECUTABLE_INCLUDE_DIR}")
ENDFUNCTION()

TEST_EXECUTABLE_WITH_INCLUDES()
