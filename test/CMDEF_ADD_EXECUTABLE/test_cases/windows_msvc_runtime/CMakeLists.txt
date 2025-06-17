## Main
#
# Test Windows MSVC runtime library settings
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ADD_EXECUTABLE_MSVC_RUNTIME_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test MSVC runtime library property with CMDEF_WINDOWS_STATIC_RUNTIME=ON.
#
# MSVC runtime always uses generator expressions regardless of CMAKE_BUILD_TYPE
# because runtime selection must be build-time dependent for multiconfig generators.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_MSVC_RUNTIME_STATIC_ON)

    CACHE_VAR_FORCE_SET(CMDEF_WINDOWS_STATIC_RUNTIME ON)

    CMDEF_ADD_EXECUTABLE(
        TARGET testmsvcruntimestaticon
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(msvc_runtime testmsvcruntimestaticon MSVC_RUNTIME_LIBRARY)

    SET(expected_pattern "^MultiThreaded\\$<\\$<CONFIG:DEBUG>:Debug>$")

    IF(NOT msvc_runtime MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected MSVC runtime to match pattern '${expected_pattern}' but got '${msvc_runtime}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMDEF_WINDOWS_STATIC_RUNTIME)
ENDFUNCTION()

##
# Test MSVC runtime library property with CMDEF_WINDOWS_STATIC_RUNTIME=OFF.
#
# MSVC runtime always uses generator expressions regardless of CMAKE_BUILD_TYPE
# because runtime selection must be build-time dependent for multiconfig generators.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_MSVC_RUNTIME_STATIC_OFF)

    CACHE_VAR_FORCE_SET(CMDEF_WINDOWS_STATIC_RUNTIME OFF)

    CMDEF_ADD_EXECUTABLE(
        TARGET testmsvcruntimestaticoff
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(msvc_runtime testmsvcruntimestaticoff MSVC_RUNTIME_LIBRARY)

    SET(expected_pattern "^MultiThreaded\\$<\\$<CONFIG:DEBUG>:Debug>DLL$")

    IF(NOT msvc_runtime MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected MSVC runtime to match pattern '${expected_pattern}' but got '${msvc_runtime}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMDEF_WINDOWS_STATIC_RUNTIME)
ENDFUNCTION()

##
# Test MSVC runtime library property with undefined CMDEF_WINDOWS_STATIC_RUNTIME.
#
# Tests behavior when CMDEF_WINDOWS_STATIC_RUNTIME is not defined,
# which should default to dynamic runtime (DLL).
#
# <function>()
#
FUNCTION(TEST_WINDOWS_MSVC_RUNTIME_UNDEFINED)

    CACHE_VAR_FORCE_UNSET(CMDEF_WINDOWS_STATIC_RUNTIME)

    CMDEF_ADD_EXECUTABLE(
        TARGET testmsvcruntimeundef
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(msvc_runtime testmsvcruntimeundef MSVC_RUNTIME_LIBRARY)

    SET(expected_pattern "^MultiThreaded\\$<\\$<CONFIG:DEBUG>:Debug>DLL$")

    IF(NOT msvc_runtime MATCHES "${expected_pattern}")
        MESSAGE(FATAL_ERROR "Expected MSVC runtime to match pattern '${expected_pattern}' but got '${msvc_runtime}'")
    ENDIF()

    CACHE_VAR_RESTORE(CMDEF_WINDOWS_STATIC_RUNTIME)
ENDFUNCTION()

TEST_WINDOWS_MSVC_RUNTIME_STATIC_ON()
TEST_WINDOWS_MSVC_RUNTIME_STATIC_OFF()
TEST_WINDOWS_MSVC_RUNTIME_UNDEFINED()
