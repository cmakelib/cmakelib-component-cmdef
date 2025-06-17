## Main
#
# Test CMDEF_INSTALL with interface library
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_INSTALL_INTERFACE_LIB_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../install_override.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../library_tests.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../install_test_macros.cmake")



##
# Verify target CMDEF_INSTALL_INTERFACE_SOURCES contains expected source path.
#
# Checks that a target's CMDEF_INSTALL_INTERFACE_SOURCES property contains
# the expected source file path. This is used to verify that CMDEF_INSTALL
# properly processes interface library sources.
#
# <macro>(
#     <target>                    // Target name to check
#     <expected_source_path>      // Expected source path in the property
# )
#
MACRO(TEST_CHECK_TARGET_INSTALL_INTERFACE_SOURCES_CONTAINS target expected_source_path)
    GET_TARGET_PROPERTY(interface_sources ${target} CMDEF_INSTALL_INTERFACE_SOURCES)
    IF(NOT interface_sources)
        MESSAGE(FATAL_ERROR "Target ${target} has no CMDEF_INSTALL_INTERFACE_SOURCES property")
    ENDIF()

    STRING(FIND "${interface_sources}" "${expected_source_path}" found_pos)
    IF(found_pos EQUAL -1)
        MESSAGE(FATAL_ERROR "CMDEF_INSTALL_INTERFACE_SOURCES for target ${target} does not contain '${expected_source_path}'. Got: ${interface_sources}")
    ENDIF()
ENDMACRO()

##
# Verify target CMDEF_INSTALL_INTERFACE_SOURCES has expected number of entries.
#
# Checks that a target's CMDEF_INSTALL_INTERFACE_SOURCES property has the
# expected number of source file entries.
#
# <macro>(
#     <target>           // Target name to check
#     <expected_count>   // Expected number of source entries
# )
#
MACRO(TEST_CHECK_TARGET_INSTALL_INTERFACE_SOURCES_COUNT target expected_count)
    GET_TARGET_PROPERTY(interface_sources ${target} CMDEF_INSTALL_INTERFACE_SOURCES)
    IF(NOT interface_sources)
        SET(interface_sources "")
    ENDIF()

    LIST(LENGTH interface_sources actual_count)
    IF(NOT actual_count EQUAL ${expected_count})
        MESSAGE(FATAL_ERROR "CMDEF_INSTALL_INTERFACE_SOURCES for target ${target} should have ${expected_count} entries but has ${actual_count}. Got: ${interface_sources}")
    ENDIF()
ENDMACRO()



##
# Test interface library installation with source files.
#
# Creates an interface library with sources and verifies INSTALL(TARGETS)
# and INSTALL(FILES) commands are called correctly.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_INSTALL)
    TEST_CLEAR_INSTALL_CALLS()
    
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP ilib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )
    
    CMDEF_INSTALL(TARGET ilib-interface)
    
    LIBRARY_TESTS("ilib-interface")
    
    TEST_GET_INSTALL_FILES_CALLS(files_calls)
    IF(NOT files_calls MATCHES "FILES.*DESTINATION.*${CMDEF_SOURCE_INSTALL_DIR}")
        MESSAGE(FATAL_ERROR "INSTALL FILES for interface sources not found with correct destination")
    ENDIF()
ENDFUNCTION()

##
# Test interface library with sources but no base directory.
#
# Creates an interface library with sources but no SOURCE_BASE_DIRECTORY.
# According to _CMDEF_INSTALL_INTERFACE_TARGET implementation:
# - CMDEF_INSTALL_INTERFACE_SOURCES is set to empty (line 206)
# - EXPORT_PROPERTIES always includes CMDEF_INSTALL_INTERFACE_SOURCES (line 219)
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_NO_BASE_DIR)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP inbdlib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET inbdlib-interface)

    TEST_CHECK_TARGET_PROPERTY(inbdlib-interface CMDEF_INSTALL ON)

    TEST_CHECK_TARGET_HAS_PROPERTY(inbdlib-interface CMDEF_LIBRARY)
    TEST_CHECK_TARGET_HAS_PROPERTY(inbdlib-interface CMDEF_LIBRARY_SOURCES)
    TEST_CHECK_TARGET_LACKS_PROPERTY(inbdlib-interface CMDEF_LIBRARY_BASE_DIR)

    TEST_CHECK_TARGET_INSTALL_INTERFACE_SOURCES_COUNT(inbdlib-interface 0)

    TEST_CHECK_TARGET_EXPORT_PROPERTIES_CONTAINS(inbdlib-interface "CMDEF_INSTALL_INTERFACE_SOURCES")
ENDFUNCTION()

##
# Test interface library with sources and base directory.
#
# Creates an interface library with SOURCE_BASE_DIRECTORY.
# According to _CMDEF_INSTALL_INTERFACE_TARGET implementation:
# - Sources with base directory prefix get added to CMDEF_INSTALL_INTERFACE_SOURCES (line 217)
# - EXPORT_PROPERTIES always includes CMDEF_INSTALL_INTERFACE_SOURCES (line 219)
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_WITH_BASE_DIR)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP ibdlib
        TYPE INTERFACE
        VERSION 1.0.0
        SOURCES "${LIBRARY_SOURCE_FILE}"
        SOURCE_BASE_DIRECTORY "../../shared_sources"
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET ibdlib-interface)

    TEST_CHECK_TARGET_PROPERTY(ibdlib-interface CMDEF_INSTALL ON)

    TEST_CHECK_TARGET_HAS_PROPERTY(ibdlib-interface CMDEF_LIBRARY)
    TEST_CHECK_TARGET_HAS_PROPERTY(ibdlib-interface CMDEF_LIBRARY_SOURCES)
    TEST_CHECK_TARGET_HAS_PROPERTY(ibdlib-interface CMDEF_LIBRARY_BASE_DIR)

    TEST_CHECK_TARGET_INSTALL_INTERFACE_SOURCES_COUNT(ibdlib-interface 1)
    TEST_CHECK_TARGET_INSTALL_INTERFACE_SOURCES_CONTAINS(ibdlib-interface "library.cpp")

    TEST_CHECK_TARGET_EXPORT_PROPERTIES_CONTAINS(ibdlib-interface "CMDEF_INSTALL_INTERFACE_SOURCES")
ENDFUNCTION()

##
# Test interface library without sources.
#
# Creates an interface library without sources.
# According to _CMDEF_INSTALL_INTERFACE_TARGET implementation:
# - Function returns early if no CMDEF_LIBRARY_SOURCES (line 182-184)
# - No interface-specific properties are set
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_NO_SOURCES)
    TEST_CLEAR_INSTALL_CALLS()

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP inslib
        TYPE INTERFACE
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_INSTALL(TARGET inslib-interface)

    TEST_CHECK_TARGET_PROPERTY(inslib-interface CMDEF_INSTALL ON)

    TEST_CHECK_TARGET_HAS_PROPERTY(inslib-interface CMDEF_LIBRARY)
    TEST_CHECK_TARGET_LACKS_PROPERTY(inslib-interface CMDEF_LIBRARY_SOURCES)

    TEST_CHECK_TARGET_LACKS_PROPERTY(inslib-interface CMDEF_INSTALL_INTERFACE_SOURCES)

    GET_TARGET_PROPERTY(export_props inslib-interface EXPORT_PROPERTIES)
    IF(export_props AND "CMDEF_INSTALL_INTERFACE_SOURCES" IN_LIST export_props)
        MESSAGE(FATAL_ERROR "EXPORT_PROPERTIES should not contain CMDEF_INSTALL_INTERFACE_SOURCES when no sources")
    ENDIF()
ENDFUNCTION()

TEST_INTERFACE_LIBRARY_INSTALL()
TEST_INTERFACE_LIBRARY_NO_BASE_DIR()
TEST_INTERFACE_LIBRARY_WITH_BASE_DIR()
TEST_INTERFACE_LIBRARY_NO_SOURCES()
