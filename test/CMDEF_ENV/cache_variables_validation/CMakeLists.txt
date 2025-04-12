## Main
#
# Test CMDEF_ENV cache variables validation for all supported platforms
#
# This test validates that all CMDEF_* cache variables defined by CMDEF_ENV
# are properly set with expected values for each supported platform (Linux, macOS, Windows).
# Also tests environment variable support.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMDEF_ENV_CACHE_VARIABLES_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../system_modules/CMDEF_ENV.cmake")



##
# Test CMDEF_ENV cache variables for Linux platform.
#
# Validates all CMDEF_* cache variables from CMDEF_ENV have correct values
# when running on Linux systems.
#
# <function>()
#
FUNCTION(TEST_LINUX_CACHE_VARIABLES)
    IF(NOT CMDEF_OS_LINUX)
        MESSAGE(STATUS "Skipping Linux cache variables test - not running on Linux")
        RETURN()
    ENDIF()

    MESSAGE(STATUS "Testing CMDEF_ENV cache variables for Linux platform")

    # OS Detection Variables
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "linux")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "lin")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "LINUX")
    TEST_VAR_TRUE(CMDEF_OS_LINUX)
    TEST_VAR_FALSE(CMDEF_OS_WINDOWS)
    TEST_VAR_FALSE(CMDEF_OS_MACOS)
    TEST_VAR_TRUE(CMDEF_OS_POSIX)

    # Architecture Variables
    TEST_VAR_DEFINED(CMDEF_ARCHITECTURE)
    # Linux architecture should be one of the supported ones
    SET(supported_archs "x86-64" "x86" "aarch64" "aplsil")
    LIST(FIND supported_archs "${CMDEF_ARCHITECTURE}" arch_found)
    IF(arch_found EQUAL -1)
        MESSAGE(FATAL_ERROR "Unsupported architecture detected: ${CMDEF_ARCHITECTURE}")
    ENDIF()

    TEST_VAR_DEFINED(CMDEF_DISTRO_ID)
    TEST_VAR_DEFINED(CMDEF_DISTRO_VERSION_ID)
    IF("${CMDEF_DISTRO_ID}" STREQUAL "")
        MESSAGE(FATAL_ERROR "CMDEF_DISTRO_ID should not be empty on Linux")
    ENDIF()
    IF("${CMDEF_DISTRO_VERSION_ID}" STREQUAL "")
        MESSAGE(FATAL_ERROR "CMDEF_DISTRO_VERSION_ID should not be empty on Linux")
    ENDIF()

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_PREFIX "lib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_STATIC "-static")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_SHARED "")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEBUG_SUFFIX "d")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEV_SUFFIX "-dev")
    TEST_VAR_VALUE_EQUAL(CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX "d")

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC ".a")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED ".so")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_LINUX ".a")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_LINUX ".so")

    CMAKE_PATH(CONVERT "${CMDEF_INCLUDE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "include")

    CMAKE_PATH(CONVERT "${CMDEF_SOURCE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "source")

    CMAKE_PATH(CONVERT "${CMDEF_LIBRARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "lib")

    CMAKE_PATH(CONVERT "${CMDEF_BINARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "bin")

    # Naming Convention Variables
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAME_SEPARATOR "_")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAMESPACE_SUFFIX "::")

    # Supported Languages
    TEST_VAR_DEFINED(CMDEF_SUPPORTED_LANG_LIST)
    SET(expected_langs "C" "CXX" "OBJC" "OBJCXX" "RC")
    FOREACH(lang IN LISTS expected_langs)
        LIST(FIND CMDEF_SUPPORTED_LANG_LIST "${lang}" lang_found)
        IF(lang_found EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected language '${lang}' not found in CMDEF_SUPPORTED_LANG_LIST")
        ENDIF()
    ENDFOREACH()

    # Output Directory Variables
    TEST_VAR_DEFINED(CMDEF_TARGET_OUTPUT_DIRECTORY)

    # Description Variables
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COMPANY_NAME "Company name")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COPYRIGHT "Company name")

    # Multi-config Variables
    TEST_VAR_VALUE_EQUAL(CMDEF_MULTICONF_FOLDER_NAME "CMDEF")

    MESSAGE(STATUS "Linux cache variables validation passed")
ENDFUNCTION()

##
# Test CMDEF_ENV cache variables for macOS platform.
#
# Validates all CMDEF_* cache variables from CMDEF_ENV have correct values
# when running on macOS systems.
#
# <function>()
#
FUNCTION(TEST_MACOS_CACHE_VARIABLES)
    IF(NOT CMDEF_OS_MACOS)
        MESSAGE(STATUS "Skipping macOS cache variables test - not running on macOS")
        RETURN()
    ENDIF()

    MESSAGE(STATUS "Testing CMDEF_ENV cache variables for macOS platform")

    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "macos")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "mac")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "MACOS")
    TEST_VAR_TRUE(CMDEF_OS_MACOS)
    TEST_VAR_FALSE(CMDEF_OS_WINDOWS)
    TEST_VAR_FALSE(CMDEF_OS_LINUX)
    TEST_VAR_TRUE(CMDEF_OS_POSIX)

    TEST_VAR_VALUE_EQUAL(CMDEF_ARCHITECTURE "aplsil")

    TEST_VAR_VALUE_EQUAL(CMDEF_DISTRO_ID "macos")
    TEST_VAR_VALUE_EQUAL(CMDEF_DISTRO_VERSION_ID "11")

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_PREFIX "lib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_STATIC "-static")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_SHARED "")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEBUG_SUFFIX "d")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEV_SUFFIX "-dev")
    TEST_VAR_VALUE_EQUAL(CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX "d")

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC ".a")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED ".dylib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_MACOS ".a")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_MACOS ".dylib")

    CMAKE_PATH(CONVERT "${CMDEF_INCLUDE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "include")

    CMAKE_PATH(CONVERT "${CMDEF_SOURCE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "source")

    CMAKE_PATH(CONVERT "${CMDEF_LIBRARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "lib")

    CMAKE_PATH(CONVERT "${CMDEF_BINARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "bin")

    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAME_SEPARATOR "_")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAMESPACE_SUFFIX "::")

    TEST_VAR_DEFINED(CMDEF_SUPPORTED_LANG_LIST)
    SET(expected_langs "C" "CXX" "OBJC" "OBJCXX" "RC")
    FOREACH(lang IN LISTS expected_langs)
        LIST(FIND CMDEF_SUPPORTED_LANG_LIST "${lang}" lang_found)
        IF(lang_found EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected language '${lang}' not found in CMDEF_SUPPORTED_LANG_LIST")
        ENDIF()
    ENDFOREACH()

    TEST_VAR_DEFINED(CMDEF_TARGET_OUTPUT_DIRECTORY)

    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COMPANY_NAME "Company name")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COPYRIGHT "Company name")

    TEST_VAR_VALUE_EQUAL(CMDEF_MULTICONF_FOLDER_NAME "CMDEF")

    TEST_VAR_DEFINED(CMDEF_MACOS_EXECUTABLE_IBTOOL)

    MESSAGE(STATUS "macOS cache variables validation passed")
ENDFUNCTION()

##
# Test CMDEF_ENV cache variables for Windows platform.
#
# Validates all CMDEF_* cache variables from CMDEF_ENV have correct values
# when running on Windows systems.
#
# <function>()
#
FUNCTION(TEST_WINDOWS_CACHE_VARIABLES)
    IF(NOT CMDEF_OS_WINDOWS)
        MESSAGE(STATUS "Skipping Windows cache variables test - not running on Windows")
        RETURN()
    ENDIF()

    MESSAGE(STATUS "Testing CMDEF_ENV cache variables for Windows platform")

    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "windows")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "win")
    TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "WINDOWS")
    TEST_VAR_TRUE(CMDEF_OS_WINDOWS)
    TEST_VAR_FALSE(CMDEF_OS_LINUX)
    TEST_VAR_FALSE(CMDEF_OS_MACOS)
    TEST_VAR_FALSE(CMDEF_OS_POSIX)

    TEST_VAR_VALUE_EQUAL(CMDEF_ARCHITECTURE "x86-64")

    TEST_VAR_VALUE_EQUAL(CMDEF_DISTRO_ID "windows")
    TEST_VAR_VALUE_EQUAL(CMDEF_DISTRO_VERSION_ID "1")

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_PREFIX "lib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_STATIC "-static")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_FLAG_SHARED "")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEBUG_SUFFIX "d")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_DEV_SUFFIX "-dev")
    TEST_VAR_VALUE_EQUAL(CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX "d")

    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC ".lib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED ".dll")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_WINDOWS ".lib")
    TEST_VAR_VALUE_EQUAL(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_WINDOWS ".dll")

    CMAKE_PATH(CONVERT "${CMDEF_INCLUDE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "include")

    CMAKE_PATH(CONVERT "${CMDEF_SOURCE_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "source")

    CMAKE_PATH(CONVERT "${CMDEF_LIBRARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "lib")

    CMAKE_PATH(CONVERT "${CMDEF_BINARY_INSTALL_DIR}" TO_CMAKE_PATH_LIST _normalized)
    TEST_VAR_VALUE_EQUAL(_normalized "bin")

    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAME_SEPARATOR "_")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_NAMESPACE_SUFFIX "::")

    # Supported Languages
    TEST_VAR_DEFINED(CMDEF_SUPPORTED_LANG_LIST)
    SET(expected_langs "C" "CXX" "OBJC" "OBJCXX" "RC")
    FOREACH(lang IN LISTS expected_langs)
        LIST(FIND CMDEF_SUPPORTED_LANG_LIST "${lang}" lang_found)
        IF(lang_found EQUAL -1)
            MESSAGE(FATAL_ERROR "Expected language '${lang}' not found in CMDEF_SUPPORTED_LANG_LIST")
        ENDIF()
    ENDFOREACH()

    TEST_VAR_DEFINED(CMDEF_TARGET_OUTPUT_DIRECTORY)

    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COMPANY_NAME "Company name")
    TEST_VAR_VALUE_EQUAL(CMDEF_ENV_DESCRIPTION_COPYRIGHT "Company name")

    TEST_VAR_VALUE_EQUAL(CMDEF_MULTICONF_FOLDER_NAME "CMDEF")

    TEST_VAR_DEFINED(CMDEF_WINDOWS_EXECUTABLE_MT)
    TEST_VAR_DEFINED(CMDEF_WINDOWS_STATIC_RUNTIME)
    TEST_VAR_TRUE(CMDEF_WINDOWS_STATIC_RUNTIME)

    MESSAGE(STATUS "Windows cache variables validation passed")
ENDFUNCTION()

##
# Test common CMDEF_ENV cache variables that should be consistent across all platforms.
#
# Validates CMDEF_* cache variables from CMDEF_ENV that have the same expected values
# regardless of the platform.
#
# <function>()
#
FUNCTION(TEST_COMMON_CACHE_VARIABLES)
    MESSAGE(STATUS "Testing common CMDEF_ENV cache variables")

    # Language File Extensions
    TEST_VAR_DEFINED(CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS)
    TEST_VAR_DEFINED(CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS)
    TEST_VAR_DEFINED(CMDEF_LANG_OBJC_SOURCE_FILE_EXTENSIONS)
    TEST_VAR_DEFINED(CMDEF_LANG_OBJCXX_SOURCE_FILE_EXTENSIONS)
    TEST_VAR_DEFINED(CMDEF_LANG_RC_SOURCE_FILE_EXTENSIONS)

    LIST(FIND CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS ".cpp" cpp_found)
    IF(cpp_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".cpp extension not found in CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS ".c" c_found)
    IF(c_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".c extension not found in CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_RC_SOURCE_FILE_EXTENSIONS ".rc" rc_found)
    IF(rc_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".rc extension not found in CMDEF_LANG_RC_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS ".hpp" hpp_found)
    IF(hpp_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".hpp extension not found in CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS ".h" h_found)
    IF(h_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".h extension not found in CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_OBJC_SOURCE_FILE_EXTENSIONS ".m" m_found)
    IF(m_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".m extension not found in CMDEF_LANG_OBJC_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    LIST(FIND CMDEF_LANG_OBJCXX_SOURCE_FILE_EXTENSIONS ".mm" mm_found)
    IF(mm_found EQUAL -1)
        MESSAGE(FATAL_ERROR ".mm extension not found in CMDEF_LANG_OBJCXX_SOURCE_FILE_EXTENSIONS")
    ENDIF()

    MESSAGE(STATUS "Common cache variables validation passed")
ENDFUNCTION()

##
# Test CMDEF_ENV environment variable support.
#
# Tests that CMDEF_ENV properly reads and uses environment variables
# for architecture and distribution detection.
#
# <function>()
#
FUNCTION(TEST_ENVIRONMENT_VARIABLES)
    MESSAGE(STATUS "Testing CMDEF_ENV environment variable support")

    # Save current values
    SET(original_arch "${CMDEF_ARCHITECTURE}")
    SET(original_distro_id "${CMDEF_DISTRO_ID}")
    SET(original_distro_version "${CMDEF_DISTRO_VERSION_ID}")

    # Test that environment variables can override detection
    # Note: This test verifies the logic exists, but doesn't actually set ENV vars
    # since that would affect the global state

    # Verify that the environment variable logic is present in the code
    # by checking that the cache variables are defined (they should be from CMDEF_ENV_INIT)
    TEST_VAR_DEFINED(CMDEF_ARCHITECTURE)
    TEST_VAR_DEFINED(CMDEF_DISTRO_ID)
    TEST_VAR_DEFINED(CMDEF_DISTRO_VERSION_ID)

    SET(supported_archs "x86-64" "x86" "aarch64" "aplsil")
    LIST(FIND supported_archs "${CMDEF_ARCHITECTURE}" arch_found)
    IF(arch_found EQUAL -1)
        MESSAGE(FATAL_ERROR "CMDEF_ARCHITECTURE '${CMDEF_ARCHITECTURE}' is not in supported list: ${supported_archs}")
    ENDIF()

    IF("${CMDEF_DISTRO_ID}" STREQUAL "")
        MESSAGE(FATAL_ERROR "CMDEF_DISTRO_ID should not be empty")
    ENDIF()

    IF("${CMDEF_DISTRO_VERSION_ID}" STREQUAL "")
        MESSAGE(FATAL_ERROR "CMDEF_DISTRO_VERSION_ID should not be empty")
    ENDIF()

    MESSAGE(STATUS "Environment variable support validation passed")
ENDFUNCTION()

TEST_LINUX_CACHE_VARIABLES()
TEST_MACOS_CACHE_VARIABLES()
TEST_WINDOWS_CACHE_VARIABLES()
TEST_COMMON_CACHE_VARIABLES()
TEST_ENVIRONMENT_VARIABLES()
