## Main
#
# Test CMDEF_INSTALL with executable
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_INSTALL_EXECUTABLE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../library_tests.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test executable installation with INSTALL command verification.
#
# Creates an executable and verifies INSTALL commands are called
# with correct destinations for executables.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_EXECUTABLE(
        TARGET texe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )
    
    CMDEF_INSTALL(TARGET texe)
    LIBRARY_TESTS("texe") 
ENDFUNCTION()

##
# Test executable installation with property verification.
#
# Creates an executable and verifies all target properties set by
# CMDEF_INSTALL are correctly configured.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_EXECUTABLE(
        TARGET epexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    CMDEF_INSTALL(TARGET epexe)

    TEST_CHECK_TARGET_PROPERTY(epexe CMDEF_INSTALL ON)
ENDFUNCTION()

TEST_EXECUTABLE_INSTALL()
TEST_EXECUTABLE_PROPERTIES()
