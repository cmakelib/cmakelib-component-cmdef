## Main
#
# Test CMDEF_ADD_LIBRARY_CHECK function
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_LIBRARY_CHECK_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")



##
# Test CMDEF_ADD_LIBRARY_CHECK function with CMDEF-created shared library.
#
# Creates a CMDEF shared library and verifies the check function
# correctly identifies it.
#
# <function>()
#
FUNCTION(TEST_CHECK_CMDEF_SHARED_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testcheckshared
        TYPE SHARED
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    CMDEF_ADD_LIBRARY_CHECK(testcheckshared-shared cmdef_result_shared)
    IF(NOT DEFINED cmdef_result_shared)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK failed to identify CMDEF shared library target")
    ENDIF()
    IF(NOT cmdef_result_shared STREQUAL "testcheckshared-shared")
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK returned wrong target name for shared library: ${cmdef_result_shared}")
    ENDIF()
ENDFUNCTION()

##
# Test CMDEF_ADD_LIBRARY_CHECK function with CMDEF-created static library.
#
# Creates a CMDEF static library and verifies the check function
# correctly identifies it.
#
# <function>()
#
FUNCTION(TEST_CHECK_CMDEF_STATIC_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testcheckstatic
        TYPE STATIC
        SOURCES "${LIBRARY_SOURCE_FILE}"
        VERSION 1.0.0
    )

    CMDEF_ADD_LIBRARY_CHECK(testcheckstatic-static cmdef_result_static)
    IF(NOT DEFINED cmdef_result_static)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK failed to identify CMDEF static library target")
    ENDIF()
    IF(NOT cmdef_result_static STREQUAL "testcheckstatic-static")
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK returned wrong target name for static library: ${cmdef_result_static}")
    ENDIF()
ENDFUNCTION()

##
# Test CMDEF_ADD_LIBRARY_CHECK function with CMDEF-created interface library.
#
# Creates a CMDEF interface library and verifies the check function
# correctly identifies it.
#
# <function>()
#
FUNCTION(TEST_CHECK_CMDEF_INTERFACE_LIBRARY)
    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testcheckinterface
        TYPE INTERFACE
        VERSION 1.0.0
        INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}"
    )

    CMDEF_ADD_LIBRARY_CHECK(testcheckinterface-interface cmdef_result_interface)
    IF(NOT DEFINED cmdef_result_interface)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK failed to identify CMDEF interface library target")
    ENDIF()
    IF(NOT cmdef_result_interface STREQUAL "testcheckinterface-interface")
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK returned wrong target name for interface library: ${cmdef_result_interface}")
    ENDIF()
ENDFUNCTION()

##
# Test CMDEF_ADD_LIBRARY_CHECK function with regular CMake library.
#
# Creates a regular CMake library and verifies the check function
# correctly identifies it as NOT being a CMDEF-created target.
#
# <function>()
#
FUNCTION(TEST_CHECK_REGULAR_CMAKE_LIBRARY)
    ADD_LIBRARY(regularcmakelib STATIC "${LIBRARY_SOURCE_FILE}")

    CMDEF_ADD_LIBRARY_CHECK(regularcmakelib regular_result)
    IF(DEFINED regular_result)
        MESSAGE(FATAL_ERROR "CMDEF_ADD_LIBRARY_CHECK incorrectly identified regular CMake library as CMDEF target")
    ENDIF()
ENDFUNCTION()

TEST_CHECK_CMDEF_SHARED_LIBRARY()
TEST_CHECK_CMDEF_STATIC_LIBRARY()
TEST_CHECK_CMDEF_INTERFACE_LIBRARY()
TEST_CHECK_REGULAR_CMAKE_LIBRARY()
