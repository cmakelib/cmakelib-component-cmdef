## Main
#
# Add executable
#

INCLUDE_GUARD(GLOBAL)

SET(_CMDEF_ADD_EXECUTABLE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

FIND_PACKAGE(CMLIB COMPONENTS CMUTIL REQUIRED)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_RESOURCE.cmake)



##
# Add executable.
#
# SOURCES - all c/cpp/h/hpp files will be added as source to given target.
#
# WIN32 - create WIN32 application.
# Ignored if the CMDEF_OS_WINDOWS is false
#
# MACOS_BUNDLE - create macosx bundle.
# Ignored if CMDEF_OS_MACOS is false.
#
# OUTPUT_NAME - output base name. Name of the target
# file after compile and link.
#
# [Custom properties]
# CMDEF_EXECUTABLE - property which mark library as "created by CMDEF_ADD_EXECUTABLE"
#
# <function>(
#		TARGET  <target>
#		SOURCES <sources> M
#		VERSION <version>
#		[OUTPUT_NAME <output_name>]
#		[WIN32         {ON|OFF}]
#		[MACOS_BUNDLE {ON|OFF}]
#		[INCLUDE_DIRECTORIES <include_directories> M]
# )
#
FUNCTION(CMDEF_ADD_EXECUTABLE)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			INCLUDE_DIRECTORIES
			SOURCES
		ONE_VALUE
			VERSION
			TARGET
			OUTPUT_NAME
		OPTIONS
			WIN32 MACOS_BUNDLE
		REQUIRED
			VERSION
			SOURCES
			TARGET
		P_ARGN ${ARGN}
	)
	CMDEF_HELPER_IS_TARGET_NAME_VALID(${__TARGET})
	CMUTIL_VERSION_CHECK("${__VERSION}")

	SET(exec_flag)
	IF(CMDEF_OS_WINDOWS AND __WIN32)
		SET(exec_flag WIN32)
	ELSEIF(CMDEF_OS_MACOS AND __MACOS_BUNDLE)
		SET(exec_flag MACOSX_BUNDLE)
	ENDIF()

	SET(output_name ${__TARGET})
	IF(DEFINED __OUTPUT_NAME)
		SET(output_name "${__OUTPUT_NAME}")
	ENDIF()

	SET(package_name_suffix)
	IF(DEFINED CMAKE_BUILD_TYPE)
		IF(CMAKE_BUILD_TYPE STREQUAL "Debug")
			SET(package_name_suffix "${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}")
		ENDIF()
	ELSE()
		SET(package_name_suffix "$<$<CONFIG:DEBUG>:${CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX}>")
	ENDIF()

	ADD_EXECUTABLE(${__TARGET} ${exec_flag} ${__SOURCES})
	SET_TARGET_PROPERTIES(${__TARGET}
		PROPERTIES
			OUTPUT_NAME "${output_name}${package_name_suffix}"
			CMDEF_EXECUTABLE TRUE
	)

	IF(DEFINED __INCLUDE_DIRECTORIES)
		TARGET_INCLUDE_DIRECTORIES(${__TARGET} PRIVATE ${__INCLUDE_DIRECTORIES})
	ENDIF()

	IF(CMDEF_OS_WINDOWS)
		_CMDEF_ADD_EXECUTABLE_WINDOWS_SETTING(${__TARGET} ${__VERSION})
	ENDIF()
ENDFUNCTION()



##
# Check if the target is created by CMDEF_ADD_EXECUTABLE
# function.
#
# Set <output_var> to TRUE if created by CMDEF_ADD_EXECUTABLE.
#
# Usage:
#	<function>(target output_var_name)
#	IF(DEFINED output_var_name)
#		MESSAGE(STATUS "Target name: ${output_var_name}")
#	ELSE()
#		MESSAGE(STATUS "Not a CMDEF target")
#	ENDIF()
#
# <function>(
#	<target>
#	<output_var>	# UNSET if not created by CMDEF_ADD_EXECUTABLE, else set to target name
# )
#
FUNCTION(CMDEF_ADD_EXECUTABLE_CHECK target output_var)
	GET_PROPERTY(is_cmdef TARGET ${target} PROPERTY CMDEF_EXECUTABLE)
	IF(is_cmdef)
		SET(${output_var} "${target}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	UNSET(${output_var} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Setting specific only for Windows
#
# <function> (
# 	<target_lib>
# 	<version>
# )
#
FUNCTION(_CMDEF_ADD_EXECUTABLE_WINDOWS_SETTING target_lib version)
	SET(msvc_runtime_type)
	IF(NOT CMDEF_WINDOWS_STATIC_RUNTIME)
		SET(msvc_runtime_type DLL)
	ENDIF()
	SET_PROPERTY(TARGET ${target_lib}
		PROPERTY
			MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:DEBUG>:Debug>${msvc_runtime_type}"
	)
	CMUTIL_VERSION_SPLIT(version ${version})
	CMDEF_RESOURCE_WINDOWS(
		RESOURCE_TARGET ${target_lib}
		RESOURCE_FILE "${_CMDEF_ADD_EXECUTABLE_CURRENT_LIST_DIR}/resources/windows_version.rc"
		DEFINITIONS
			VERSION_MAJOR  ${version_MAJOR}
			VERSION_MINOR  ${version_MINOR}
			VERSION_PATCH  ${version_PATCH}
			PRODUCT_BUNDLE "$<TARGET_NAME:${target_lib}>"
			PRODUCT_COMPANY_COPYRIGHT "${CMDEF_ENV_DESCRIPTION_COPYRIGHT}"
			PRODUCT_COMPANY_NAME      "${CMDEF_ENV_DESCRIPTION_COMPANY_NAME}"
	)
ENDFUNCTION()
