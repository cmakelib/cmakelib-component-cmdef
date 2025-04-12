## Main
#
# Test Windows MSVC runtime library settings
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ADD_EXECUTABLE_MSVC_RUNTIME_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../CMDEFConfig.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../shared_sources/shared_sources.cmake")

##
# Test MSVC runtime library property setting on Windows.
#
# Creates executable on Windows and verifies MSVC_RUNTIME_LIBRARY
# property is set correctly based on CMDEF_WINDOWS_STATIC_RUNTIME.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_MSVC_RUNTIME)
    IF(NOT CMDEF_OS_WINDOWS)
        MESSAGE(STATUS "Skipping MSVC runtime test - not on Windows")
        RETURN()
    ENDIF()
    
    CMDEF_ADD_EXECUTABLE(
        TARGET testmsvcruntime
        SOURCES "${MAIN_SOURCE_FILE}"
        VERSION 1.0.0
    )

    GET_TARGET_PROPERTY(msvc_runtime testmsvcruntime MSVC_RUNTIME_LIBRARY)
    
    IF(CMDEF_WINDOWS_STATIC_RUNTIME)
        IF(NOT msvc_runtime MATCHES "MultiThreaded.*")
            MESSAGE(FATAL_ERROR "MSVC runtime not set correctly for static runtime: ${msvc_runtime}")
        ENDIF()
        IF(msvc_runtime MATCHES ".*DLL.*")
            MESSAGE(FATAL_ERROR "Static runtime should not contain DLL: ${msvc_runtime}")
        ENDIF()
    ELSE()
        IF(NOT msvc_runtime MATCHES ".*DLL.*")
            MESSAGE(FATAL_ERROR "Dynamic runtime should contain DLL: ${msvc_runtime}")
        ENDIF()
    ENDIF()
    
    MESSAGE(STATUS "MSVC runtime library correctly set: ${msvc_runtime}")
ENDFUNCTION()

TEST_WINDOWS_MSVC_RUNTIME()
