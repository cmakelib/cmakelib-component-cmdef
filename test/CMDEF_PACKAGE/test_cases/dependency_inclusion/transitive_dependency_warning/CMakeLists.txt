## Transitive Dependency Warning Test
#
# Test that warning is generated for transitive dependencies that are not imported
# and not directly linked to the main target.
#
# This test creates a dependency chain: main -> direct_dep -> transitive_dep
# and verifies that the warning message is generated for transitive_dep.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_PACKAGE_TRANSITIVE_DEPENDENCY_WARNING_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../shared_sources/shared_sources.cmake")

CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP transitivedep
    TYPE SHARED
    VERSION 1.0.0
    SOURCES "${LIBRARY_SOURCE_FILE}"
)

CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP directdep
    TYPE SHARED
    VERSION 1.0.0
    SOURCES "${LIBRARY_SOURCE_FILE}"
)

CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP main
    TYPE SHARED
    VERSION 1.0.0
    SOURCES "${LIBRARY_SOURCE_FILE}"
)

TARGET_LINK_LIBRARIES(directdep-shared PUBLIC transitivedep-shared)
TARGET_LINK_LIBRARIES(main-shared PUBLIC directdep-shared)

CMDEF_INSTALL(TARGET transitivedep-shared NAMESPACE main-shared::)
CMDEF_INSTALL(TARGET directdep-shared NAMESPACE main-shared::)
CMDEF_INSTALL(TARGET main-shared NAMESPACE main-shared::)

CMDEF_PACKAGE(
    MAIN_TARGET main-shared
    VERSION 1.0.0
)
