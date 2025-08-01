## Main
#
# Test OS detection in CMDEF_ENV
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ENV_OS_DETECTION_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../system_modules/CMDEF_ENV.cmake")

IF(CMDEF_OS_LINUX)
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "linux")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "lin")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "LINUX")
	TEST_VAR_TRUE(CMDEF_OS_LINUX)
	TEST_VAR_FALSE(CMDEF_OS_WINDOWS)
	TEST_VAR_FALSE(CMDEF_OS_MACOS)
	TEST_VAR_TRUE(CMDEF_OS_POSIX)
ELSEIF(CMDEF_OS_WINDOWS)
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "windows")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "win")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "WINDOWS")
	TEST_VAR_TRUE(CMDEF_OS_WINDOWS)
	TEST_VAR_FALSE(CMDEF_OS_LINUX)
	TEST_VAR_FALSE(CMDEF_OS_MACOS)
	TEST_VAR_FALSE(CMDEF_OS_POSIX)
ELSEIF(CMDEF_OS_MACOS)
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME "macos")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_SHORT "mac")
	TEST_VAR_VALUE_EQUAL(CMDEF_OS_NAME_UPPER "MACOS")
	TEST_VAR_TRUE(CMDEF_OS_MACOS)
	TEST_VAR_FALSE(CMDEF_OS_LINUX)
	TEST_VAR_FALSE(CMDEF_OS_WINDOWS)
	TEST_VAR_TRUE(CMDEF_OS_POSIX)
ELSE()
	MESSAGE(FATAL_ERROR "No OS flag is set to true")
ENDIF() 