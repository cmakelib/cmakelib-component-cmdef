## Main
#
# Test debug suffix with CMAKE_BUILD_TYPE
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_EXECUTABLE_DEBUG_SUFFIX_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test debug suffix application with CMAKE_BUILD_TYPE.
#
# Creates executable with Debug build type and verifies
# debug suffix is applied correctly.
#
# <function>()
#
FUNCTION(TEST_DEBUG_SUFFIX_APPLICATION)
    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Debug")
    
    CMDEF_ADD_EXECUTABLE(
        TARGET testdebugsuffixexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(output_name testdebugsuffixexe OUTPUT_NAME)
    IF(NOT output_name MATCHES ".*${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}$")
        MESSAGE(FATAL_ERROR "Debug suffix not applied correctly: ${output_name}")
    ENDIF()

    CACHE_VAR_FORCE_SET(CMAKE_BUILD_TYPE "Release")

    CMDEF_ADD_EXECUTABLE(
        TARGET testreleaseexe
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(release_output_name testreleaseexe OUTPUT_NAME)
    IF(release_output_name MATCHES ".*${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}$")
        MESSAGE(FATAL_ERROR "Debug suffix incorrectly applied in Release: ${release_output_name}")
    ENDIF()

    CACHE_VAR_RESTORE(CMAKE_BUILD_TYPE)
ENDFUNCTION()

TEST_DEBUG_SUFFIX_APPLICATION()
