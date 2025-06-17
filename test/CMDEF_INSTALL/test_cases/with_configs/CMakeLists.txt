## Main
#
# Test CMDEF_INSTALL with specific configurations
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_INSTALL_CONFIGURATIONS_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")

##
# Test installation with specific configurations.
#
# Creates a library and installs it with specific configurations,
# verifying CONFIGURATIONS parameter is passed correctly to both
# INSTALL(TARGETS) and INSTALL(EXPORT).
#
# <function>()
#
FUNCTION(TEST_CONFIGURATIONS_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP clib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET clib-shared CONFIGURATIONS Debug Release)
    
    TEST_INSTALL_TARGETS_EXPORT_EQUALS("clib-shared")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("ARCHIVE" "${CMDEF_LIBRARY_INSTALL_DIR}")
    
    TEST_INSTALL_TARGETS_CONFIGURATIONS_CONTAINS("Debug")
    TEST_INSTALL_TARGETS_CONFIGURATIONS_CONTAINS("Release")
    
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("Debug")
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("Release")
    
    TEST_INSTALL_EXPORT_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake//")
ENDFUNCTION()

##
# Test configurations installation with property verification.
#
# Creates a library with specific configurations and verifies all target
# properties set by CMDEF_INSTALL are correctly configured.
#
# <function>()
#
FUNCTION(TEST_CONFIGURATIONS_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP cplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_INSTALL(TARGET cplib-shared CONFIGURATIONS Debug Release)

    TEST_CHECK_TARGET_PROPERTY(cplib-shared CMDEF_INSTALL ON)
ENDFUNCTION()

TEST_CONFIGURATIONS_INSTALL()
TEST_CONFIGURATIONS_PROPERTIES()
