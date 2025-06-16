## Main
#
# Test CMDEF_PACKAGE with executable
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_EXECUTABLE_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../package_test_macros.cmake")

##
# Test executable packaging with complete verification.
#
# Creates an executable, installs it, and packages it, verifying all
# INSTALL commands, file creation, and package properties.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_PACKAGE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")
    
    CMDEF_ADD_EXECUTABLE(
        TARGET elib
        VERSION 1.0.0
        SOURCES "${MAIN_SOURCE_FILE}"
    )
    
    CMDEF_INSTALL(TARGET elib NAMESPACE elib::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET elib
        VERSION 1.2.3
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/elib/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("elib" "1.2.3")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test executable packaging properties verification.
#
# Creates an executable and verifies all properties set by CMDEF_PACKAGE
# are correctly configured.
#
# <function>()
#
FUNCTION(TEST_EXECUTABLE_PACKAGE_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_EXECUTABLE(
        TARGET eplib
        VERSION 1.0.0
        SOURCES "${MAIN_SOURCE_FILE}"
    )

    CMDEF_INSTALL(TARGET eplib NAMESPACE eplib::)

    CMDEF_PACKAGE(
        MAIN_TARGET eplib
        VERSION 2.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("eplib" "2.0.0")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_EXECUTABLE_PACKAGE()
TEST_EXECUTABLE_PACKAGE_PROPERTIES()
