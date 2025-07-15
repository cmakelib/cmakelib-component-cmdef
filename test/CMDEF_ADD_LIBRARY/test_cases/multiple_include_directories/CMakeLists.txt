## Main
#
# Test multiple include directories in CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_MULTIPLE_INCLUDES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../multiple_include_sources/multiple_include_sources.cmake")

##
# Test library with multiple include directories.
#
# Creates a library with multiple INCLUDE_DIRECTORIES and
# INSTALL_INCLUDE_DIRECTORIES and verifies they're all set correctly.
# INSTALL_INCLUDE_DIRECTORIES contains actual header directories that
# should be included in the generated package.
#
# <function>()
#
FUNCTION(TEST_MULTIPLE_INCLUDE_DIRECTORIES)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testmultipleincludes
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
        INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
            "${LIBRARY_INCLUDE2_DIR}"
        INSTALL_INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
    )

    IF(NOT TARGET testmultipleincludes-shared)
        MESSAGE(FATAL_ERROR "Library target 'testmultipleincludes-shared' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(include_dirs testmultipleincludes-shared INTERFACE_INCLUDE_DIRECTORIES)

    # Verify each include directory is present (with BUILD_INTERFACE)
    # Use more flexible matching since paths might be normalized
    SET(expected_dirs
        "multiple_include_sources/include"
        "multiple_include_sources/include1"
        "multiple_include_sources/include2"
    )

    FOREACH(expected_dir IN LISTS expected_dirs)
        IF(NOT include_dirs MATCHES "${expected_dir}")
            MESSAGE(FATAL_ERROR "Include directory containing '${expected_dir}' not found in INTERFACE_INCLUDE_DIRECTORIES: ${include_dirs}")
        ENDIF()
    ENDFOREACH()

    GET_TARGET_PROPERTY(install_include_dirs testmultipleincludes-shared CMDEF_INSTALL_INCLUDE_DIRECTORIES)

    SET(expected_install_dirs
        "${LIBRARY_INCLUDE_DIR}"
        "${LIBRARY_INCLUDE1_DIR}"
    )

    FOREACH(expected_install_dir IN LISTS expected_install_dirs)
        LIST(FIND install_include_dirs "${expected_install_dir}" found_index)
        IF(found_index EQUAL -1)
            MESSAGE(FATAL_ERROR "Install include directory '${expected_install_dir}' not found in CMDEF_INSTALL_INCLUDE_DIRECTORIES")
        ENDIF()
    ENDFOREACH()

    MESSAGE(STATUS "Multiple include directories test passed")
ENDFUNCTION()

##
# Test interface library with multiple include directories.
#
# Creates an interface library with multiple include directories
# and verifies they use INTERFACE visibility correctly.
# INSTALL_INCLUDE_DIRECTORIES contains actual header directories that
# should be included in the generated package.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_MULTIPLE_INCLUDE_DIRECTORIES)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testinterfacemultipleincludes
        TYPE INTERFACE
        VERSION 1.0.0
        INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
        INSTALL_INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
    )

    IF(NOT TARGET testinterfacemultipleincludes-interface)
        MESSAGE(FATAL_ERROR "Interface library target 'testinterfacemultipleincludes-interface' was not created")
    ENDIF()

    GET_TARGET_PROPERTY(include_dirs testinterfacemultipleincludes-interface INTERFACE_INCLUDE_DIRECTORIES)
    
    # Verify include directories are present with BUILD_INTERFACE
    # Use more flexible matching since paths might be normalized
    SET(expected_dirs
        "multiple_include_sources/include"
        "multiple_include_sources/include1"
    )

    FOREACH(expected_dir IN LISTS expected_dirs)
        IF(NOT include_dirs MATCHES "${expected_dir}")
            MESSAGE(FATAL_ERROR "Include directory containing '${expected_dir}' not found in interface library INTERFACE_INCLUDE_DIRECTORIES: ${include_dirs}")
        ENDIF()
    ENDFOREACH()

    MESSAGE(STATUS "Interface library multiple include directories test passed")
ENDFUNCTION()

TEST_MULTIPLE_INCLUDE_DIRECTORIES()
TEST_INTERFACE_MULTIPLE_INCLUDE_DIRECTORIES()
