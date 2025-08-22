## Main
#
# Tests for CMDEF_ENV module
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.22)
PROJECT(CMDEF_ENV_TEST)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../CMDEFConfig.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/basic_init")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/os_detection")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/arch_detection")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_variables_validation")

EXECUTE_PROCESS(
	COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_LIST_DIR}/os_detection/CMakeLists.txt"
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/os_detection"
	RESULT_VARIABLE result_var
)
IF(NOT result_var EQUAL 0)
	MESSAGE(FATAL_ERROR "os_detection test did not pass in script mode!")
ENDIF()

EXECUTE_PROCESS(
	COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_LIST_DIR}/arch_detection/CMakeLists.txt"
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/arch_detection"
	RESULT_VARIABLE result_var
)
IF(NOT result_var EQUAL 0)
	MESSAGE(FATAL_ERROR "arch_detection test did not pass in script mode!")
ENDIF()

IF(CMDEF_OS_WINDOWS)
	TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/windows_specific")
ELSEIF(CMDEF_OS_POSIX)
	TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/macos_specific")
ENDIF() 