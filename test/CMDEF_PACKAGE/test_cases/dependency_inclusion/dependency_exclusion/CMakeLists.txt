## Dependency Exclusion Tests
#
# Test exclusion of non-CMDEF and IMPORTED targets from dependency inclusion
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_DEPENDENCY_EXCLUSION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../cache_var.cmake")

##
# Test exclusion of non-CMDEF targets.
#
# Creates standard CMake targets and system libraries that should be
# excluded from dependency inclusion.
#
# <function>()
#
FUNCTION(TEST_NON_CMDEF_EXCLUSION)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    # Create CMDEF dependency that should be included
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP cmdefdep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    # Create main library
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP exclusionmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    # Create standard CMake targets that should be excluded
    ADD_LIBRARY(standard_shared SHARED "${LIBRARY_SOURCE_FILE}")
    ADD_LIBRARY(standard_static STATIC "${LIBRARY_SOURCE_FILE}")

    # Find system library that should be excluded
    FIND_PACKAGE(Threads QUIET)

    # Link all dependencies
    TARGET_LINK_LIBRARIES(exclusionmain-shared PUBLIC cmdefdep-shared standard_shared standard_static)
    IF(Threads_FOUND)
        TARGET_LINK_LIBRARIES(exclusionmain-shared PUBLIC Threads::Threads)
    ENDIF()

    # Install only CMDEF targets
    CMDEF_INSTALL(TARGET cmdefdep-shared NAMESPACE exclusionmain-shared::)
    CMDEF_INSTALL(TARGET exclusionmain-shared NAMESPACE exclusionmain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET exclusionmain-shared
        VERSION 3.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("exclusionmain-shared" "3.0.0")

    # Verify only CMDEF targets are included
    TEST_PACKAGE_CONFIG_FILE_CONTAINS("exclusionmain-shared" "__INCLUDE_TARGETS_CONFIGS(\"cmdefdep-shared;exclusionmain-shared\")")

    # Verify non-CMDEF targets are excluded
    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/exclusionmain-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "standard_shared" standard_shared_found)
    STRING(FIND "${config_content}" "standard_static" standard_static_found)
    STRING(FIND "${config_content}" "Threads::Threads" threads_found)

    IF(NOT standard_shared_found EQUAL -1)
        MESSAGE(FATAL_ERROR "standard_shared should be excluded from config file")
    ENDIF()
    IF(NOT standard_static_found EQUAL -1)
        MESSAGE(FATAL_ERROR "standard_static should be excluded from config file")
    ENDIF()
    IF(NOT threads_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Threads::Threads should be excluded from config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test exclusion of IMPORTED targets.
#
# Creates IMPORTED targets that should be excluded from dependency inclusion.
#
# <function>()
#
FUNCTION(TEST_IMPORTED_TARGET_EXCLUSION)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    # Create CMDEF dependency that should be included
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP cmdefdep2
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    # Create main library
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP importmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    ADD_LIBRARY(imported_shared SHARED IMPORTED)
    IF(WIN32)
        SET_TARGET_PROPERTIES(imported_shared PROPERTIES
            IMPORTED_LOCATION "/fake/path/shared.dll"
            IMPORTED_IMPLIB "/fake/path/shared.lib"
        )
    ELSE()
        SET_TARGET_PROPERTIES(imported_shared PROPERTIES IMPORTED_LOCATION "/fake/path/libshared.so")
    ENDIF()

    ADD_LIBRARY(imported_static STATIC IMPORTED)
    IF(WIN32)
        SET_TARGET_PROPERTIES(imported_static PROPERTIES IMPORTED_LOCATION "/fake/path/static.lib")
    ELSE()
        SET_TARGET_PROPERTIES(imported_static PROPERTIES IMPORTED_LOCATION "/fake/path/libstatic.a")
    ENDIF()

    TARGET_LINK_LIBRARIES(importmain-shared PUBLIC cmdefdep2-shared imported_shared imported_static)

    CMDEF_INSTALL(TARGET cmdefdep2-shared NAMESPACE importmain-shared::)
    CMDEF_INSTALL(TARGET importmain-shared NAMESPACE importmain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET importmain-shared
        VERSION 4.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("importmain-shared" "4.0.0")

    TEST_PACKAGE_CONFIG_FILE_CONTAINS("importmain-shared" "__INCLUDE_TARGETS_CONFIGS(\"cmdefdep2-shared;importmain-shared\")")

    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/importmain-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "imported_shared" imported_shared_found)
    STRING(FIND "${config_content}" "imported_static" imported_static_found)

    IF(NOT imported_shared_found EQUAL -1)
        MESSAGE(FATAL_ERROR "imported_shared should be excluded from config file")
    ENDIF()
    IF(NOT imported_static_found EQUAL -1)
        MESSAGE(FATAL_ERROR "imported_static should be excluded from config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test mixed scenarios with CMDEF and non-CMDEF dependencies.
#
# Creates a complex scenario with multiple types of dependencies to verify
# that only CMDEF targets are included while others are properly excluded.
#
# <function>()
#
FUNCTION(TEST_MIXED_EXCLUSION_SCENARIOS)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP included1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP included2
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mixedmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    ADD_LIBRARY(excluded_standard SHARED "${LIBRARY_SOURCE_FILE}")
    ADD_LIBRARY(excluded_imported SHARED IMPORTED)
    IF(WIN32)
        SET_TARGET_PROPERTIES(excluded_imported PROPERTIES
            IMPORTED_LOCATION "/fake/path/lib.dll"
            IMPORTED_IMPLIB "/fake/path/lib.lib"
        )
    ELSE()
        SET_TARGET_PROPERTIES(excluded_imported PROPERTIES IMPORTED_LOCATION "/fake/path/lib.so")
    ENDIF()

    TARGET_LINK_LIBRARIES(mixedmain-shared PUBLIC 
        included1-shared 
        included2-static 
        excluded_standard 
        excluded_imported
    )

    # Install only CMDEF targets
    CMDEF_INSTALL(TARGET included1-shared NAMESPACE mixedmain-shared::)
    CMDEF_INSTALL(TARGET included2-static NAMESPACE mixedmain-shared::)
    CMDEF_INSTALL(TARGET mixedmain-shared NAMESPACE mixedmain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET mixedmain-shared
        VERSION 5.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("mixedmain-shared" "5.0.0")

    # Verify only CMDEF targets are included (sorted alphabetically)
    TEST_PACKAGE_CONFIG_FILE_CONTAINS("mixedmain-shared" "__INCLUDE_TARGETS_CONFIGS(\"included1-shared;included2-static;mixedmain-shared\")")

    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/mixedmain-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "excluded_standard" excluded_standard_found)
    STRING(FIND "${config_content}" "excluded_imported" excluded_imported_found)

    IF(NOT excluded_standard_found EQUAL -1)
        MESSAGE(FATAL_ERROR "excluded_standard should be excluded from config file")
    ENDIF()
    IF(NOT excluded_imported_found EQUAL -1)
        MESSAGE(FATAL_ERROR "excluded_imported should be excluded from config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_NON_CMDEF_EXCLUSION()
TEST_IMPORTED_TARGET_EXCLUSION()
TEST_MIXED_EXCLUSION_SCENARIOS()
