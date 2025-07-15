## Main
#
# Test MACOS_BUNDLE flag behavior
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MACOS_BUNDLE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test MACOS_BUNDLE flag behavior on different platforms.
#
# Creates executable with MACOS_BUNDLE flag and verifies it's only
# applied when running on macOS platform.
#
# <function>()
#
FUNCTION(TEST_MACOS_BUNDLE_BEHAVIOR)
    CMDEF_ADD_EXECUTABLE(
        TARGET testbundleexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
        MACOS_BUNDLE ON
    )

    IF(NOT TARGET testbundleexe)
        MESSAGE(FATAL_ERROR "Target 'testbundleexe' was not created")
    ENDIF()

    TEST_CHECK_TARGET_PROPERTY(testbundleexe CMDEF_EXECUTABLE TRUE)

    GET_TARGET_PROPERTY(target_type testbundleexe TYPE)
    IF(CMDEF_OS_MACOS)
        MESSAGE(STATUS "macOS bundle test - target type: ${target_type}")
    ELSE()
        IF(NOT target_type STREQUAL "EXECUTABLE")
            MESSAGE(FATAL_ERROR "Target type should be EXECUTABLE on non-macOS, got: ${target_type}")
        ENDIF()
        MESSAGE(STATUS "MACOS_BUNDLE flag correctly ignored on non-macOS platform")
    ENDIF()
ENDFUNCTION()

TEST_MACOS_BUNDLE_BEHAVIOR()
