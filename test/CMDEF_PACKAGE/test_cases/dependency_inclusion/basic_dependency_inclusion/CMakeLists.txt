## Basic Dependency Inclusion Tests
#
# Test core dependency inclusion functionality in CMDEF_PACKAGE
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_PACKAGE_BASIC_DEPENDENCY_INCLUSION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../cache_var.cmake")

##
# Test basic single dependency inclusion.
#
# Creates two libraries with a dependency relationship, installs them, and packages the main target,
# verifying that the dependency is correctly included in the generated config file.
#
# <function>()
#
FUNCTION(TEST_SINGLE_DEPENDENCY_INCLUSION)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP deplib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mainlib
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(mainlib-shared PUBLIC deplib-shared)
    
    CMDEF_INSTALL(TARGET deplib-shared NAMESPACE mainlib-shared::)
    CMDEF_INSTALL(TARGET mainlib-shared NAMESPACE mainlib-shared::)
    
    CMDEF_PACKAGE(
        MAIN_TARGET mainlib-shared
        VERSION 1.6.3
    )
    
    TEST_INSTALL_FILES_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake/mainlib-shared/")
    
    TEST_PACKAGE_EXTENDED_CHECKS("mainlib-shared" "1.6.3")

    TEST_PACKAGE_CONFIG_FILE_CONTAINS("mainlib-shared" "__INCLUDE_TARGETS_CONFIGS(\"deplib-shared;mainlib-shared\")")

    # Verify dependency is properly configured for export
    GET_TARGET_PROPERTY(dep_install_status deplib-shared CMDEF_INSTALL)
    IF(NOT dep_install_status)
        MESSAGE(FATAL_ERROR "Dependency should be marked as installed by CMDEF_INSTALL")
    ENDIF()

    # Verify namespace consistency
    GET_TARGET_PROPERTY(main_ns mainlib-shared CMDEF_NAMESPACE)
    GET_TARGET_PROPERTY(dep_ns deplib-shared CMDEF_NAMESPACE)
    IF(NOT main_ns STREQUAL "mainlib-shared")
        MESSAGE(FATAL_ERROR "Main target namespace should be 'mainlib-shared' but is '${main_ns}'")
    ENDIF()
    IF(NOT dep_ns STREQUAL "mainlib-shared")
        MESSAGE(FATAL_ERROR "Dependency namespace should be 'mainlib-shared' but is '${dep_ns}'")
    ENDIF()

    # Verify link libraries are set correctly
    GET_TARGET_PROPERTY(linked_libs mainlib-shared INTERFACE_LINK_LIBRARIES)
    IF(NOT "deplib-shared" IN_LIST linked_libs)
        MESSAGE(FATAL_ERROR "mainlib-shared should link to deplib-shared but linked libraries are: ${linked_libs}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test multiple dependencies inclusion with properties.
#
# Creates libraries with dependencies and include directories, verifying all
# properties set by CMDEF_PACKAGE are correctly configured.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_DEPENDENCIES_WITH_PROPERTIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP basicdep1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP basicdep2
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mainmulti
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    TARGET_LINK_LIBRARIES(mainmulti-shared PUBLIC basicdep1-shared basicdep2-static)

    CMDEF_INSTALL(TARGET basicdep1-shared NAMESPACE mainmulti-shared::)
    CMDEF_INSTALL(TARGET basicdep2-static NAMESPACE mainmulti-shared::)
    CMDEF_INSTALL(TARGET mainmulti-shared NAMESPACE mainmulti-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET mainmulti-shared
        VERSION 0.8.4
    )

    TEST_PACKAGE_EXTENDED_CHECKS("mainmulti-shared" "0.8.4")

    TEST_PACKAGE_CONFIG_FILE_CONTAINS("mainmulti-shared" "__INCLUDE_TARGETS_CONFIGS(\"basicdep1-shared;basicdep2-static;mainmulti-shared\")")

    # Verify all dependencies are properly configured for export
    GET_TARGET_PROPERTY(dep1_install_status basicdep1-shared CMDEF_INSTALL)
    GET_TARGET_PROPERTY(dep2_install_status basicdep2-static CMDEF_INSTALL)
    IF(NOT dep1_install_status OR NOT dep2_install_status)
        MESSAGE(FATAL_ERROR "All dependencies should be marked as installed by CMDEF_INSTALL")
    ENDIF()

    # Verify namespace consistency for all targets
    GET_TARGET_PROPERTY(main_ns mainmulti-shared CMDEF_NAMESPACE)
    GET_TARGET_PROPERTY(dep1_ns basicdep1-shared CMDEF_NAMESPACE)
    GET_TARGET_PROPERTY(dep2_ns basicdep2-static CMDEF_NAMESPACE)
    IF(NOT main_ns STREQUAL "mainmulti-shared" OR NOT dep1_ns STREQUAL "mainmulti-shared" OR NOT dep2_ns STREQUAL "mainmulti-shared")
        MESSAGE(FATAL_ERROR "All targets should have matching namespace 'mainmulti-shared'")
    ENDIF()

    GET_TARGET_PROPERTY(linked_libs mainmulti-shared INTERFACE_LINK_LIBRARIES)
    IF(NOT "basicdep1-shared" IN_LIST linked_libs OR NOT "basicdep2-static" IN_LIST linked_libs)
        MESSAGE(FATAL_ERROR "mainmulti-shared should link to both dependencies but linked libraries are: ${linked_libs}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test mixed target types as dependencies.
#
# Creates dependencies of different types (SHARED, STATIC, INTERFACE)
# and verifies all CMDEF library targets are included regardless of type.
#
# <function>()
#
FUNCTION(TEST_MIXED_TARGET_TYPES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP shareddep
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP staticdep
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP interfacedep
        TYPE INTERFACE
        VERSION 1.0.0
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP mixedmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(mixedmain-shared PUBLIC shareddep-shared staticdep-static interfacedep-interface)

    CMDEF_INSTALL(TARGET shareddep-shared NAMESPACE mixedmain-shared::)
    CMDEF_INSTALL(TARGET staticdep-static NAMESPACE mixedmain-shared::)
    CMDEF_INSTALL(TARGET interfacedep-interface NAMESPACE mixedmain-shared::)
    CMDEF_INSTALL(TARGET mixedmain-shared NAMESPACE mixedmain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET mixedmain-shared
        VERSION 2.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("mixedmain-shared" "2.0.0")

    TEST_PACKAGE_CONFIG_FILE_CONTAINS("mixedmain-shared" "__INCLUDE_TARGETS_CONFIGS(\"shareddep-shared;staticdep-static;interfacedep-interface;mixedmain-shared\")")

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_SINGLE_DEPENDENCY_INCLUSION()
TEST_MULTIPLE_DEPENDENCIES_WITH_PROPERTIES()
TEST_MIXED_TARGET_TYPES()
