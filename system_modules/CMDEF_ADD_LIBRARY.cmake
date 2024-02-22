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
# It creates shared, static or interface library.
#
# Initialize PREFIX and SUFFIX properties
#
# Creates target <library_group>-{static,shared,interface}.
# (e.g. If the TYPE is SHARED then 'shared')
#
# INCLUDE_DIRECTORIES is directory which will be added as include directory for given targets.
# generator expressions can be used.
#
# INSTALL_INCLUDE_DIRECTORIES is set of directories which will be installed along with
# library. If specified all directories specified by this property will be installed
# into CMDEF_LIBRARY_INSTALL_DIR at target package.
# It serve as an INTERFACE include directories for given library against linked target.
# It is a subset of INCLUDE_DIRECTORIES.
#
# SOURCES - all c/cpp/h/hpp files will be added as source to given target.
#
# SOURCE_BASE_DIRECTORY - INTERFACE library only. It is base directory for all source files.
# If defined, source files will be installed with relative path to this directory.
# Else, source files will be installed directly in CMDEF_SOURCE_INSTALL_DIR
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
#		[SOURCE_BASE_DIRECTORY <source_directories> M]
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
			SOURCE_BASE_DIRECTORY
		REQUIRED
			VERSION
			LIBRARY_GROUP
		P_ARGN ${ARGN}
	)
	CMDEF_HELPERS_IS_TARGET_NAME_VALID(${__LIBRARY_GROUP})
	CMUTIL_VERSION_CHECK(${__VERSION})
	_CMDEF_ADD_LIBRARY_CHECK_TYPE(${__TYPE})

	IF(TARGET ${__LIBRARY_GROUP})
		MESSAGE(FATAL_ERROR "Target '${__LIBRARY_GROUP}' already exist!")
	ENDIF()

	STRING(TOLOWER "${__TYPE}" target_lib_type_suffix)
	SET(target_lib "${__LIBRARY_GROUP}-${target_lib_type_suffix}")

	ADD_LIBRARY(${target_lib} "${__TYPE}")
	IF(__TYPE STREQUAL "INTERFACE")
		_CMDEF_ADD_LIBRARY_SET_INTERFACE_SOURCES(TARGET ${target_lib}
			BASE_DIR "${__SOURCE_BASE_DIRECTORY}"
			SOURCES ${__SOURCES}
		)
	ELSE()
		IF(DEFINED __SOURCE_BASE_DIRECTORY)
			MESSAGE(FATAL_ERROR "SOURCE_BASE_DIRECTORY is not supported for non INTERFACE library")
		ENDIF()
		IF(NOT DEFINED __SOURCES)
			MESSAGE(FATAL_ERROR "SOURCES is not defined.")
		ENDIF()
		TARGET_SOURCES(${target_lib} PRIVATE ${__SOURCES})
	ENDIF()

	IF(__TYPE STREQUAL "SHARED")
		SET_PROPERTY(TARGET ${target_lib} PROPERTY POSITION_INDEPENDENT_CODE TRUE)
	ENDIF()

	IF(DEFINED __INCLUDE_DIRECTORIES)
		IF(__TYPE STREQUAL "INTERFACE")
			TARGET_INCLUDE_DIRECTORIES(${target_lib} INTERFACE $<BUILD_INTERFACE:${__INCLUDE_DIRECTORIES}>)
		ELSE ()
			TARGET_INCLUDE_DIRECTORIES(${target_lib} PUBLIC $<BUILD_INTERFACE:${__INCLUDE_DIRECTORIES}>)
		ENDIF ()
	ENDIF ()

	IF(DEFINED __INSTALL_INCLUDE_DIRECTORIES)
		#TARGET_INCLUDE_DIRECTORIES(${target_lib} INTERFACE $<INSTALL_INTERFACE:${__INSTALL_INCLUDE_DIRECTORIES}>)
		SET_PROPERTY(TARGET ${target_lib}
			PROPERTY
				CMDEF_INSTALL_INCLUDE_DIRECTORIES ${__INSTALL_INCLUDE_DIRECTORIES}
		)
	ENDIF()

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
	IF(NOT __TYPE STREQUAL "INTERFACE")
		_CMDEF_ADD_LIBRARY_GET_SUFFIX(suffix ${__TYPE})
	ENDIF()
	SET_TARGET_PROPERTIES(${target_lib}
		PROPERTIES
			SUFFIX "${suffix}"
			PREFIX ""
			OUTPUT_NAME "${output_name}"
	)

	IF(DEFINED __SOVERSION AND CMDEF_OS_POSIX)
		IF(__SOVERSION VERSION_GREATER __VERSION)
			MESSAGE(FATAL_ERROR "SOVERSION (${__SOVERSION}) is not <= VERSION (${__VERSION})")
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
	IF(is_cmdef)
		SET(${output_var} "${target}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	UNSET(${output_var} PARENT_SCOPE)
ENDFUNCTION()

##
# Helper
#
# Set BUILD_INTERFACE sources for INTERFACE library
#
FUNCTION(_CMDEF_ADD_LIBRARY_SET_INTERFACE_SOURCES)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			SOURCES
		ONE_VALUE
			TARGET BASE_DIR
		P_ARGN ${ARGN}
	)

	IF(NOT __SOURCES)
		RETURN()
	ENDIF()

	SET(all_sources)
	FOREACH(source IN LISTS __SOURCES)
		SET(result_source)
		CMAKE_PATH(NORMAL_PATH source OUTPUT_VARIABLE source_normalized)
		CMAKE_PATH(IS_RELATIVE source_normalized is_relative)
		CMAKE_PATH(IS_ABSOLUTE source_normalized is_absolute)
		IF(is_absolute)
			SET(result_source ${source_normalized})
		ELSEIF(is_relative)
			CMAKE_PATH(APPEND CMAKE_CURRENT_LIST_DIR "${source_normalized}" OUTPUT_VARIABLE result_source)
		ELSE()
			MESSAGE(FATAL_ERROR "Error - the file is has not a valid path: ${source_normalized}")
		ENDIF()
		LIST(APPEND all_sources "${result_source}")
	ENDFOREACH()

	SET(base_dir)
	IF(__BASE_DIR)
		#[[SET(ext_regexp "*${ext_regexp}")
		LIST(JOIN CMDEF_SUPPORTED_LANG_SOURCE_EXT_LIST "|*" ext_regexp)

		#TODO - it is wanted behav. to include all sources in source dir
		#TODO and not only listed ones?
		FILE(GLOB_RECURSE base_dir_sources "${__BASE_DIR}/${ext_regexp}")
		LIST(APPEND all_sources "${base_dir_sources}")]]

		CMAKE_PATH(IS_RELATIVE __BASE_DIR base_dir_is_relative)
		IF(base_dir_is_relative)
			CMAKE_PATH(APPEND CMAKE_CURRENT_LIST_DIR "${__BASE_DIR}" OUTPUT_VARIABLE base_dir)
		ENDIF()
	ENDIF()
	LIST(REMOVE_DUPLICATES all_sources)

	FOREACH(final_source_path IN LISTS all_sources)
		TARGET_SOURCES(${__TARGET} INTERFACE $<BUILD_INTERFACE:${final_source_path}>)
	ENDFOREACH()

	SET_TARGET_PROPERTIES(${__TARGET}
		PROPERTIES
			CMDEF_LIBRARY_SOURCES "${all_sources}"
			CMDEF_LIBRARY_BASE_DIR "${base_dir}"
	)
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
