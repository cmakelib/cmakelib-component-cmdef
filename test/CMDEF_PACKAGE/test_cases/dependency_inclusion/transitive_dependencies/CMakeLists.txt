## Transitive Dependencies Tests
#
# Test multi-level dependency chains and warning generation
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_TRANSITIVE_DEPENDENCIES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../package_test_macros.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../cache_var.cmake")

##
# Test multi-level dependency chains.
#
# Creates a chain: main -> dep1 -> dep2 and verifies that only direct
# dependencies are included while transitive ones generate warnings.
#
# <function>()
#
FUNCTION(TEST_MULTI_LEVEL_DEPENDENCIES)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    #
    # Create dependency chain: main -> dep1 -> dep2
    #

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP transdep2
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP transdep1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multilevel
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(transdep1-shared PUBLIC transdep2-shared)
    TARGET_LINK_LIBRARIES(multilevel-shared PUBLIC transdep1-shared)

    CMDEF_INSTALL(TARGET transdep2-shared NAMESPACE multilevel-shared::)
    CMDEF_INSTALL(TARGET transdep1-shared NAMESPACE multilevel-shared::)
    CMDEF_INSTALL(TARGET multilevel-shared NAMESPACE multilevel-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET multilevel-shared
        VERSION 1.5.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("multilevel-shared" "1.5.0")

    # Verify only direct dependencies are included (transdep1-shared, multilevel-shared)
    # transdep2-shared should not be included as it's a transitive dependency
    TEST_PACKAGE_CONFIG_FILE_CONTAINS("multilevel-shared" "__INCLUDE_TARGETS_CONFIGS(\"transdep1-shared;multilevel-shared\")")

    # Verify transitive dependency is not in the config file
    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/multilevel-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "transdep2-shared" dep2_found)
    IF(NOT dep2_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Transitive dependency transdep2-shared should not be included in config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test deeper dependency chains.
#
# Creates a longer chain: main -> dep1 -> dep2 -> dep3 and verifies
# that only the direct dependency is included.
#
# <function>()
#
FUNCTION(TEST_DEEP_DEPENDENCY_CHAIN)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    #
    # Create deep dependency chain: main -> dep1 -> dep2 -> dep3
    #

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP deepdep3
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP deepdep2
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP deepdep1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP deepmain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(deepdep2-shared PUBLIC deepdep3-shared)
    TARGET_LINK_LIBRARIES(deepdep1-shared PUBLIC deepdep2-shared)
    TARGET_LINK_LIBRARIES(deepmain-shared PUBLIC deepdep1-shared)

    CMDEF_INSTALL(TARGET deepdep3-shared NAMESPACE deepmain-shared::)
    CMDEF_INSTALL(TARGET deepdep2-shared NAMESPACE deepmain-shared::)
    CMDEF_INSTALL(TARGET deepdep1-shared NAMESPACE deepmain-shared::)
    CMDEF_INSTALL(TARGET deepmain-shared NAMESPACE deepmain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET deepmain-shared
        VERSION 2.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("deepmain-shared" "2.0.0")

    # Verify only direct dependency is included
    TEST_PACKAGE_CONFIG_FILE_CONTAINS("deepmain-shared" "__INCLUDE_TARGETS_CONFIGS(\"deepdep1-shared;deepmain-shared\")")

    # Verify transitive dependencies are not in the config file
    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/deepmain-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "deepdep2-shared" dep2_found)
    STRING(FIND "${config_content}" "deepdep3-shared" dep3_found)

    IF(NOT dep2_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Transitive dependency deepdep2-shared should not be included in config file")
    ENDIF()
    IF(NOT dep3_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Transitive dependency deepdep3-shared should not be included in config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

##
# Test multiple direct dependencies with transitive chains.
#
# Creates: main -> dep1 -> dep1_sub, main -> dep2 -> dep2_sub
# Verifies only direct dependencies (dep1, dep2) are included.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_DIRECT_WITH_TRANSITIVE)
    TEST_CLEAR_INSTALL_CALLS()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multidep1sub
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multidep2sub
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multidep1
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multidep2
        TYPE STATIC
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP multimain
        TYPE SHARED
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
    )

    TARGET_LINK_LIBRARIES(multidep1-shared PUBLIC multidep1sub-shared)
    TARGET_LINK_LIBRARIES(multidep2-static PUBLIC multidep2sub-static)
    TARGET_LINK_LIBRARIES(multimain-shared PUBLIC multidep1-shared multidep2-static)

    CMDEF_INSTALL(TARGET multidep1sub-shared NAMESPACE multimain-shared::)
    CMDEF_INSTALL(TARGET multidep2sub-static NAMESPACE multimain-shared::)
    CMDEF_INSTALL(TARGET multidep1-shared NAMESPACE multimain-shared::)
    CMDEF_INSTALL(TARGET multidep2-static NAMESPACE multimain-shared::)
    CMDEF_INSTALL(TARGET multimain-shared NAMESPACE multimain-shared::)

    CMDEF_PACKAGE(
        MAIN_TARGET multimain-shared
        VERSION 3.0.0
    )

    TEST_PACKAGE_EXTENDED_CHECKS("multimain-shared" "3.0.0")

    # Verify only direct dependencies are included (sorted alphabetically)
    TEST_PACKAGE_CONFIG_FILE_CONTAINS("multimain-shared" "__INCLUDE_TARGETS_CONFIGS(\"multidep1-shared;multidep2-static;multimain-shared\")")

    # Verify transitive dependencies are not in the config file
    SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/multimain-sharedConfig.cmake")
    FILE(READ "${config_file}" config_content)
    STRING(FIND "${config_content}" "multidep1sub-shared" dep1sub_found)
    STRING(FIND "${config_content}" "multidep2sub-static" dep2sub_found)

    IF(NOT dep1sub_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Transitive dependency multidep1sub-shared should not be included in config file")
    ENDIF()
    IF(NOT dep2sub_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Transitive dependency multidep2sub-static should not be included in config file")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_MULTI_LEVEL_DEPENDENCIES()
TEST_DEEP_DEPENDENCY_CHAIN()
TEST_MULTIPLE_DIRECT_WITH_TRANSITIVE()
