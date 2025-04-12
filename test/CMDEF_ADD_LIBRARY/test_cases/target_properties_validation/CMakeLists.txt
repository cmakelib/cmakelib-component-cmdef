## Main
#
# Test comprehensive target properties validation for CMDEF_ADD_LIBRARY
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_LIBRARY_PROPERTIES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../multiple_include_sources/multiple_include_sources.cmake")



##
# Test INTERFACE library target properties.
#
# Creates an INTERFACE library with comprehensive parameters
# and validates all target properties are correctly set.
#
# <function>()
#
FUNCTION(TEST_INTERFACE_LIBRARY_PROPERTIES)
    SET(test_version "2.1.3")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testpropsintf
        TYPE INTERFACE
        VERSION ${test_version}
        INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
        INSTALL_INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
        SOURCES
            "${LIBRARY_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
    )

    TEST_CHECK_TARGET_PROPERTY(testpropsintf-interface TYPE "INTERFACE_LIBRARY")
    TEST_CHECK_TARGET_PROPERTY(testpropsintf-interface CMDEF_LIBRARY "INTERFACE")
    TEST_CHECK_TARGET_PROPERTY(testpropsintf-interface CMDEF_INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}")

    GET_TARGET_PROPERTY(intf_include_dirs testpropsintf-interface INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT intf_include_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "INTERFACE library INTERFACE_INCLUDE_DIRECTORIES missing BUILD_INTERFACE wrapper")
    ENDIF()

    GET_TARGET_PROPERTY(intf_regular_dirs testpropsintf-interface INCLUDE_DIRECTORIES)
    IF(intf_regular_dirs)
        MESSAGE(FATAL_ERROR "INTERFACE library should not have INCLUDE_DIRECTORIES property set")
    ENDIF()

    GET_TARGET_PROPERTY(intf_sources testpropsintf-interface SOURCES)
    IF(intf_sources)
        MESSAGE(FATAL_ERROR "INTERFACE library should not have SOURCES property set")
    ENDIF()

    GET_TARGET_PROPERTY(intf_interface_sources testpropsintf-interface INTERFACE_SOURCES)
    IF(NOT intf_interface_sources MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "INTERFACE library INTERFACE_SOURCES missing BUILD_INTERFACE wrapper")
    ENDIF()
ENDFUNCTION()

##
# Test SHARED library target properties.
#
# Creates a SHARED library with comprehensive parameters
# and validates all target properties are correctly set.
#
# <function>()
#
FUNCTION(TEST_SHARED_LIBRARY_PROPERTIES)
    SET(test_version "2.1.3")
    SET(test_soversion "2.1")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testpropsshared
        TYPE SHARED
        VERSION ${test_version}
        SOVERSION ${test_soversion}
        SOURCES
            "${LIBRARY_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
        INSTALL_INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
    )

    TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared TYPE "SHARED_LIBRARY")
    TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared CMDEF_LIBRARY "SHARED")
    TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared CMDEF_INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}")
    TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared PREFIX "")
    TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared POSITION_INDEPENDENT_CODE TRUE)

    IF(CMDEF_OS_POSIX)
        TEST_CHECK_TARGET_PROPERTY(testpropsshared-shared SOVERSION ${test_soversion})
    ENDIF()

    GET_TARGET_PROPERTY(shared_interface_dirs testpropsshared-shared INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT shared_interface_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "SHARED library INTERFACE_INCLUDE_DIRECTORIES missing BUILD_INTERFACE wrapper")
    ENDIF()

    GET_TARGET_PROPERTY(shared_include_dirs testpropsshared-shared INCLUDE_DIRECTORIES)
    IF(NOT shared_include_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "SHARED library INCLUDE_DIRECTORIES missing BUILD_INTERFACE wrapper")
    ENDIF()

    GET_TARGET_PROPERTY(shared_sources testpropsshared-shared SOURCES)
    IF(NOT shared_sources)
        MESSAGE(FATAL_ERROR "SHARED library should have SOURCES property set")
    ENDIF()

    GET_TARGET_PROPERTY(shared_output_name testpropsshared-shared OUTPUT_NAME)
    IF(NOT shared_output_name MATCHES "^${CMDEF_LIBRARY_PREFIX}")
        MESSAGE(FATAL_ERROR "SHARED library OUTPUT_NAME missing proper prefix")
    ENDIF()

    GET_TARGET_PROPERTY(shared_suffix testpropsshared-shared SUFFIX)
    IF(NOT shared_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}")
        MESSAGE(FATAL_ERROR "SHARED library SUFFIX incorrect: expected '${CMDEF_LIBRARY_NAME_SUFFIX_SHARED}', got '${shared_suffix}'")
    ENDIF()
ENDFUNCTION()
##
# Test STATIC library target properties.
#
# Creates a STATIC library with comprehensive parameters
# and validates all target properties are correctly set.
#
# <function>()
#
FUNCTION(TEST_STATIC_LIBRARY_PROPERTIES)
    SET(test_version "2.1.3")
    SET(test_soversion "2.1")

    CMDEF_ADD_LIBRARY(
        LIBRARY_GROUP testpropsstatic
        TYPE STATIC
        VERSION ${test_version}
        SOVERSION ${test_soversion}
        SOURCES
            "${LIBRARY_SOURCE_FILE}"
            "${UTILS_SOURCE_FILE}"
        INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
            "${LIBRARY_INCLUDE1_DIR}"
        INSTALL_INCLUDE_DIRECTORIES
            "${LIBRARY_INCLUDE_DIR}"
    )

    TEST_CHECK_TARGET_PROPERTY(testpropsstatic-static TYPE "STATIC_LIBRARY")
    TEST_CHECK_TARGET_PROPERTY(testpropsstatic-static CMDEF_LIBRARY "STATIC")
    TEST_CHECK_TARGET_PROPERTY(testpropsstatic-static CMDEF_INSTALL_INCLUDE_DIRECTORIES "${LIBRARY_INCLUDE_DIR}")
    TEST_CHECK_TARGET_PROPERTY(testpropsstatic-static PREFIX "")

    GET_TARGET_PROPERTY(static_pic testpropsstatic-static POSITION_INDEPENDENT_CODE)
    IF(static_pic)
        MESSAGE(FATAL_ERROR "STATIC library should not have POSITION_INDEPENDENT_CODE set to TRUE")
    ENDIF()

    IF(CMDEF_OS_POSIX)
        TEST_CHECK_TARGET_PROPERTY(testpropsstatic-static SOVERSION ${test_soversion})
    ENDIF()

    GET_TARGET_PROPERTY(static_interface_dirs testpropsstatic-static INTERFACE_INCLUDE_DIRECTORIES)
    IF(NOT static_interface_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "STATIC library INTERFACE_INCLUDE_DIRECTORIES missing BUILD_INTERFACE wrapper")
    ENDIF()

    GET_TARGET_PROPERTY(static_include_dirs testpropsstatic-static INCLUDE_DIRECTORIES)
    IF(NOT static_include_dirs MATCHES "\\$<BUILD_INTERFACE:")
        MESSAGE(FATAL_ERROR "STATIC library INCLUDE_DIRECTORIES missing BUILD_INTERFACE wrapper")
    ENDIF()

    GET_TARGET_PROPERTY(static_sources testpropsstatic-static SOURCES)
    IF(NOT static_sources)
        MESSAGE(FATAL_ERROR "STATIC library should have SOURCES property set")
    ENDIF()

    GET_TARGET_PROPERTY(static_output_name testpropsstatic-static OUTPUT_NAME)
    IF(NOT static_output_name MATCHES "^${CMDEF_LIBRARY_PREFIX}")
        MESSAGE(FATAL_ERROR "STATIC library OUTPUT_NAME missing proper prefix")
    ENDIF()

    GET_TARGET_PROPERTY(static_suffix testpropsstatic-static SUFFIX)
    IF(NOT static_suffix STREQUAL "${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}")
        MESSAGE(FATAL_ERROR "STATIC library SUFFIX incorrect: expected '${CMDEF_LIBRARY_NAME_SUFFIX_STATIC}', got '${static_suffix}'")
    ENDIF()

    MESSAGE(STATUS "STATIC library properties validation passed")
ENDFUNCTION()

TEST_INTERFACE_LIBRARY_PROPERTIES()
TEST_SHARED_LIBRARY_PROPERTIES()
TEST_STATIC_LIBRARY_PROPERTIES()
