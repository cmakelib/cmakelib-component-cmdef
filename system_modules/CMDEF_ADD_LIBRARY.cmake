## Main
#
# Add library. Maintain install include directories
#

IF(DEFINED CMDEF_ADD_LIBRARY_MODULE)
	RETURN()
ENDIF()
SET(CMDEF_ADD_LIBRARY_MODULE 1)

SET(_CMDEF_ADD_LIBRARY_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

FIND_PACKAGE(CMLIB COMPONENTS CMUTIL)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_ENV.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_RESOURCE.cmake)




##
# It creates shared or static library.
#
# Initialize PREFIX and SUFFIX properties
#
# Creates targets <library_group>-object, <library_group>-{static,shared}.
# (If the TYPE is SHARED then 'shared' otherwise 'static')
#
# INCLUDE_DIRECTORIES is directory which will be added as include directory for given targets.
# generator expressions can be used.
#
# INSTALL_INCLUDE_DIRECTORIES is set of directories which will be installed along with
# library. If specified all directories specified by this property will be installed
# into CMDEF_LIBRARY_INSTALL_DIR at target package.
# It serve as an INTERFACE include directories for given library against linked target.
#
# SOURCES - all c/cpp/h/hpp files will be added as source to given object target.
#
# [Custom properties]
# CMDEF_LIBRARY - property which mark library as "created by CMDEF_ADD_LIBRARY"
#
# <function>(
#		LIBRARY_GROUP <library_group>
#		TYPE {SHARED|STATIC|INTERFACE}
#		SOURCES <source_files> M
#		VERSION <version>
#		[INCLUDE_DIRECTORIES <directories> m]
#		[INSTALL_INCLUDE_DIRECTORIES <install_include_dirs> M]
#		[SOURCE_DIRECTORIES <source_directories> M]
# )
#
FUNCTION(CMDEF_ADD_LIBRARY)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			INSTALL_INCLUDE_DIRECTORIES
			INCLUDE_DIRECTORIES
			SOURCES
		ONE_VALUE
			VERSION SOVERSION
			LIBRARY_GROUP
			TYPE
		REQUIRED
			VERSION
			LIBRARY_GROUP
		P_ARGN ${ARGN}
	)
	# TODO check and forbid "_" in LIBRARY_GROUP name
	# TODO set SEPARATOR
	# TODO oddelat object lib
	# TODO dat TYPE na silu lowercase za jmeno

	CMUTIL_VERSION_CHECK(${__VERSION})
	_CMDEF_ADD_LIBRARY_CHECK_TYPE(${__TYPE})

	IF(TARGET ${__LIBRARY_GROUP})
		MESSAGE(FATAL_ERROR "Target '${__LIBRARY_GROUP}' already exist!")
	ENDIF()
#[[

	SET(target_object_lib ${__LIBRARY_GROUP}-object)
	IF(NOT TARGET ${target_object_lib})
		IF(NOT DEFINED __SOURCES)
			MESSAGE(FATAL_ERROR "SOURCES is not defined.")
		ENDIF()
		ADD_LIBRARY(${target_object_lib} OBJECT ${__SOURCES})
		IF(DEFINED __INCLUDE_DIRECTORIES)
			TARGET_INCLUDE_DIRECTORIES(${target_object_lib} PUBLIC ${__INCLUDE_DIRECTORIES})
		ENDIF()
		SET_TARGET_PROPERTIES(${target_object_lib}
			PROPERTIES
				FOLDER "${CMDEF_MULTICONF_FOLDER_NAME}/object_libraries"
		)
	ENDIF()
]]

	IF("${__TYPE}" STREQUAL "SHARED")
		SET_PROPERTY(TARGET ${__LIBRARY_GROUP} PROPERTY POSITION_INDEPENDENT_CODE TRUE)
	ENDIF()
	STRING(TOLOWER "${__TYPE}" target_lib_type_suffix)
	SET(target_lib "${__LIBRARY_GROUP}-${target_lib_type_suffix}")
	MESSAGE("target lib ${target_lib}")

	ADD_LIBRARY(${target_lib} "${__TYPE}")
	IF (DEFINED __SOURCES)
		TARGET_SOURCES(${target_lib} PUBLIC __SOURCES)
	ENDIF ()

	IF(DEFINED __INCLUDE_DIRECTORIES)
		IF("${__TYPE}" STREQUAL "INTERFACE")
			TARGET_INCLUDE_DIRECTORIES(${target_lib} INTERFACE $<BUILD_INTERFACE:${__INCLUDE_DIRECTORIES}>)
		ELSE ()
			TARGET_INCLUDE_DIRECTORIES(${target_lib} PUBLIC $<BUILD_INTERFACE:${__INCLUDE_DIRECTORIES}>)
		ENDIF ()
	ENDIF ()

	IF(DEFINED __INSTALL_INCLUDE_DIRECTORIES)
		TARGET_INCLUDE_DIRECTORIES(${target_lib} INTERFACE $<INSTALL_INTERFACE:${__INSTALL_INCLUDE_DIRECTORIES}>)
		SET_PROPERTY(TARGET ${target_lib}
			PROPERTY
				CMDEF_INSTALL_INCLUDE_DIRECTORIES ${__INSTALL_INCLUDE_DIRECTORIES}
		)
	ENDIF()

#[[	SET(libname_suffix)
	IF(DEFINED CMDEF_LIBRARY_NAME_FLAG_${__TYPE})
		SET(libname_suffix "${CMDEF_LIBRARY_NAME_FLAG_${__TYPE}}")
	ENDIF()]]

	SET(output_name)
	IF(DEFINED CMAKE_BUILD_TYPE)
		IF(CMAKE_BUILD_TYPE STREQUAL "Debug")
			SET(output_name "${CMDEF_LIBRARY_PREFIX}${target_lib}${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}")
		ELSE()
			SET(output_name "${CMDEF_LIBRARY_PREFIX}${target_lib}")
		ENDIF()
	ELSE()
		SET(output_name "${CMDEF_LIBRARY_PREFIX}${target_lib}$<$<CONFIG:DEBUG>:${CMDEF_LIBRARY_NAME_DEBUG_SUFFIX}>")
	ENDIF()

	SET(suffix)
	IF (NOT "${__TYPE}" STREQUAL "INTERFACE")
		_CMDEF_ADD_LIBRARY_GET_SUFFIX(suffix ${__TYPE})
	ENDIF ()
	SET_TARGET_PROPERTIES(${target_lib}
		PROPERTIES
			SUFFIX "${suffix}"
			PREFIX ""
			OUTPUT_NAME "${output_name}"
	)

	IF(DEFINED __SOVERSION AND CMDEF_OS_POSIX)
		IF(__SOVERSION VERSION_GREATER __VERSION)
			MESSAGE(FATAL_ERROR "SOVERSION (${__SOVERSION}) is not  <= VERSION (${__VERSION})")
		ENDIF()
		SET_PROPERTY(TARGET ${target_lib} PROPERTY SOVERSION ${__SOVERSION})
	ENDIF()
	SET_TARGET_PROPERTIES(${target_lib}
		PROPERTIES
			CMDEF_LIBRARY "${__TYPE}"
	)
	IF(CMDEF_OS_WINDOWS)
		_CMDEF_ADD_LIBRARY_WINDOWS_SETTING(${target_lib} ${__VERSION})
	ENDIF()
ENDFUNCTION()



##
# Check if the target is created by CMDEF_ADD_LIBRARY
# function.
#
# Set <output_var> to name of ALIASED_TARGET if created by CMDEF_ADD_LIBRARY.
# Unset(<output_var> PARENT_SCOPE) if not created by CMDEF_ADD_LIBRARY.
#
# Usage:
#	<function>(target_a output_var_name)
#	IF(DEFINED output_var_name)
#		MESSAGE(STATUS "Target name: ${output_var_name}")
#	ELSE()
#		MESSAGE(STATUS "Not a CMDEF target")
#	ENDIF()
#
# <function>(
#	<target>
#	<output_var>
# )
#
FUNCTION(CMDEF_ADD_LIBRARY_CHECK target output_var)
	GET_PROPERTY(is_cmdef TARGET ${target} PROPERTY CMDEF_LIBRARY)
	IF(NOT is_cmdef STREQUAL "NOTFOUND")
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
# )
#
FUNCTION(_CMDEF_ADD_LIBRARY_WINDOWS_SETTING target_lib version)
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
		RESOURCE_FILE "${_CMDEF_ADD_LIBRARY_CURRENT_LIST_DIR}/resources/windows_version.rc"
		DEFINITIONS
			VERSION_MAJOR  ${version_MAJOR}
			VERSION_MINOR  ${version_MINOR}
			VERSION_PATCH  ${version_PATCH}
			PRODUCT_BUNDLE "$<TARGET_NAME:${target_lib}>"
			PRODUCT_COMPANY_COPYRIGHT "${CMDEF_ENV_DESCRIPTION_COPYRIGHT}"
			PRODUCT_COMPANY_NAME      "${CMDEF_ENV_DESCRIPTION_COMPANY_NAME}"
	)
ENDFUNCTION()



## Helper
# Get library suffix according to build type and host OS
#
# <function>(
#		<type> // build type - uppercase
# )
#
FUNCTION(_CMDEF_ADD_LIBRARY_GET_SUFFIX output_var type)
	SET(suf_var CMDEF_LIBRARY_NAME_SUFFIX_${type})
	IF(NOT DEFINED ${suf_var})
		MESSAGE(FATAL_ERROR "Cannot determine suffix for non existent configuration")
	ENDIF()
	SET(${output_var} "${${suf_var}}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Check if the 'type' is STATIC, SHARED or INTERFACE
#
# <function>(
#		<library_type>
# )
#
FUNCTION(_CMDEF_ADD_LIBRARY_CHECK_TYPE type)
	SET(available_types "STATIC" "SHARED" "INTERFACE")
	LIST(FIND available_types "${type}" type_found)
	IF(type_found EQUAL -1)
		MESSAGE(FATAL_ERROR "Invalid Type '${type}'")
	ENDIF()
ENDFUNCTION()
