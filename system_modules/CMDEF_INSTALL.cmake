## Main
#
# Install library targets created by CMDEF_ADD_LIBRARY
#

IF(DEFINED CMDEF_INSTALL_MODULE)
	RETURN()
ENDIF()
SET(CMDEF_INSTALL_MODULE 1)

FIND_PACKAGE(CMLIB)



##
# Installs given target.
#
# If the CONFIGURATIONS is specified function installs
# target only for given list of build types.
# If no CONFIGURATIONS is specified that the target is installed
# for each build type
#
# NAMESPACE - Sets the namespace for the exported library and the export file path. The path is set to lib/cmake/<namespace>
# It must be equal to main target's name, to be findable with the package. This is checked in CMDEF_PACKAGE.
# It must end with CMDEF_ENV_NAMESPACE_SUFFIX (::). The suffix is removed for path creation.
# Workflow:
# - If the given target has INSTALL_INCLUDE_DIRECTORIES property
#   (created by CMDEF_ADD_LIBRARY)
# - Set DESTINATION for all types
#
# NO_INSTALL_CONFIG - if set, the export file is not installed. This is usable for creating virtual targets.
#
# <function>(
#		TARGET <target>
#		[CONFIGURATIONS <configurations>]
# )
#
FUNCTION(CMDEF_INSTALL)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			CONFIGURATIONS
		ONE_VALUE
			TARGET
			NAMESPACE
		OPTIONS
			NO_INSTALL_CONFIG
		REQUIRED
			TARGET
		P_ARGN ${ARGN}
	)

	IF(NOT DEFINED __CONFIGURATIONS)
		SET(__CONFIGURATIONS ${CMDEF_BUILD_TYPE_LIST_UPPERCASE})
	ENDIF()

	SET(original_target ${__TARGET})

	IF(DEFINED __NAMESPACE)
		_CMDEF_INSTALL_CHECK_NAMESPACE(${__NAMESPACE})
		_CMDEF_INSTALL_STRIP_NAMESPACE_SUFFIX(${__NAMESPACE} striped_namespace)
		SET_TARGET_PROPERTIES(${original_target} PROPERTIES
				CMDEF_NAMESPACE ${striped_namespace}
		)
	ELSE ()
		SET(__NAMESPACE "")
		SET(striped_namespace "")
	ENDIF()

	CMDEF_ADD_LIBRARY_CHECK(${__TARGET} cmdef_target)
	IF(cmdef_target)
		SET(original_target ${cmdef_target})

		GET_PROPERTY(include_dirs TARGET ${original_target} PROPERTY CMDEF_INSTALL_INCLUDE_DIRECTORIES)
		IF(include_dirs)
			TARGET_INCLUDE_DIRECTORIES(${original_target} INTERFACE $<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>)
			FOREACH(dir IN LISTS include_dirs)
				INSTALL(DIRECTORY ${dir}
					CONFIGURATIONS ${__CONFIGURATIONS}
					DESTINATION "${CMDEF_INCLUDE_INSTALL_DIR}"
				)
			ENDFOREACH()
		ENDIF()
	ENDIF()

	SET_TARGET_PROPERTIES(${original_target} PROPERTIES
			CMDEF_INSTALL ON
	)

	SET(file_set)
	IF(CMAKE_MINOR_VERSION GREATER 23)
		SET(file_set FILE_SET ${original_target} DESTINATION ${CMDEF_INCLUDE_INSTALL_DIR})
	ENDIF()

	INSTALL(TARGETS ${original_target}
		CONFIGURATIONS ${__CONFIGURATIONS}
		EXPORT ${original_target}
		ARCHIVE DESTINATION "${CMDEF_LIBRARY_INSTALL_DIR}"
		LIBRARY DESTINATION "${CMDEF_LIBRARY_INSTALL_DIR}"
		RUNTIME DESTINATION "${CMDEF_BINARY_INSTALL_DIR}"
		BUNDLE DESTINATION  "${CMDEF_BINARY_INSTALL_DIR}"
		PUBLIC_HEADER DESTINATION "${CMDEF_INCLUDE_INSTALL_DIR}"
		${file_set}
	)
	GET_TARGET_PROPERTY(target_type ${original_target} TYPE)
	IF(${target_type} STREQUAL "INTERFACE_LIBRARY")
		_CMDEF_INSTALL_INTERFACE_TARGET(TARGET ${original_target} CONFIGURATIONS ${__CONFIGURATIONS})
	ENDIF ()

	IF(DEFINED __NO_INSTALL_CONFIG AND NOT __NO_INSTALL_CONFIG)
		INSTALL(EXPORT ${original_target}
			CONFIGURATIONS ${__CONFIGURATIONS}
			DESTINATION "${CMDEF_TARGET_INSTALL_DIRECTORY}/${striped_namespace}/"
			NAMESPACE ${__NAMESPACE}
		)
	ELSE ()
		SET_TARGET_PROPERTIES(${original_target} PROPERTIES CMDEF_NO_INSTALL_CONFIG ON)
		MESSAGE(WARNING "Use of Deprecated NO_INSTALL_CONFIG. It might get removed in the future.")
	ENDIF()

ENDFUNCTION()

##
# It checks if the given target is installed by CMDEF_INSTALL.
# <function> (
# 		TARGET     <target>
#		OUTPUT_VAR <output_var>
# )
#
FUNCTION(CMDEF_INSTALL_USED_FOR)
	CMLIB_PARSE_ARGUMENTS(
			ONE_VALUE
			TARGET OUTPUT_VAR
			REQUIRED
			TARGET OUTPUT_VAR
			P_ARGN ${ARGN}
	)
	GET_TARGET_PROPERTY(is_installed_by_cmdef ${__TARGET} CMDEF_INSTALL)
	IF(NOT is_installed_by_cmdef)
		UNSET("${__OUTPUT_VAR}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	SET("${__OUTPUT_VAR}" ON PARENT_SCOPE)
ENDFUNCTION()

##
# It installs sources of the given target.
#
# If the TARGET has BASE_DIR property set, then the source files are installed
# in relative path to the BASE_DIR.
# Otherwise all source files are installed in the root of the CMDEF_SOURCE_INSTALL_DIR
#
FUNCTION(_CMDEF_INSTALL_INTERFACE_TARGET)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			CONFIGURATIONS
		ONE_VALUE
			TARGET
		REQUIRED
			TARGET CONFIGURATIONS
		P_ARGN ${ARGN}
	)
	SET(interface_target ${__TARGET})

	GET_TARGET_PROPERTY(cmdef_lib ${interface_target} CMDEF_LIBRARY)
	GET_TARGET_PROPERTY(target_type ${interface_target} TYPE)
	IF(NOT cmdef_lib OR (NOT target_type STREQUAL "INTERFACE_LIBRARY"))
		RETURN()
	ENDIF()
	GET_TARGET_PROPERTY(interface_sources ${interface_target} CMDEF_LIBRARY_SOURCES)
	IF (NOT interface_sources)
		RETURN()
	ENDIF ()
	GET_TARGET_PROPERTY(source_base_dir   ${interface_target} CMDEF_LIBRARY_BASE_DIR)

	SET(sources)
	SET(sources_without_base_dir)
	IF(source_base_dir)
		FOREACH(source IN LISTS interface_sources)
			CMAKE_PATH(IS_PREFIX source_base_dir "${source}" NORMALIZE has_base_dir)
			IF(has_base_dir)
				LIST(APPEND sources "${source}")
			ELSE()
				LIST(APPEND sources_without_base_dir "${source}")
			ENDIF()
		ENDFOREACH()
	ELSE()
		SET(sources_without_base_dir ${interface_sources})
	ENDIF()

	INSTALL(FILES ${sources_without_base_dir}
		CONFIGURATIONS ${__CONFIGURATIONS}
		DESTINATION "${CMDEF_SOURCE_INSTALL_DIR}"
	)
	SET_TARGET_PROPERTIES(${__TARGET} PROPERTIES CMDEF_INSTALL_INTERFACE_SOURCES "")

	FOREACH(source IN LISTS sources)
		CMAKE_PATH(RELATIVE_PATH source BASE_DIRECTORY "${source_base_dir}" OUTPUT_VARIABLE relative_source_path)
		CMAKE_PATH(GET relative_source_path PARENT_PATH relative_source_dir)
		CMAKE_PATH(GET relative_source_path FILENAME filename)

		INSTALL(FILES ${source}
			CONFIGURATIONS ${__CONFIGURATIONS}
			DESTINATION "${CMDEF_SOURCE_INSTALL_DIR}/${relative_source_dir}"
		)
		SET_PROPERTY(TARGET ${__TARGET} APPEND PROPERTY CMDEF_INSTALL_INTERFACE_SOURCES "${CMDEF_SOURCE_INSTALL_DIR}/${relative_source_dir}/${filename}")
	ENDFOREACH()
	SET_PROPERTY(TARGET ${__TARGET} APPEND PROPERTY EXPORT_PROPERTIES CMDEF_INSTALL_INTERFACE_SOURCES)

ENDFUNCTION()

##
# HELPER
#
# It checks if the namespace is valid and ends with correct namespace suffix
#
FUNCTION(_CMDEF_INSTALL_CHECK_NAMESPACE namespace)
	IF(NOT namespace)
		RETURN()
	ENDIF()
	CMDEF_HELPERS_IS_NAME_VALID(${namespace})
	STRING(REGEX MATCH "${CMDEF_ENV_NAMESPACE_SUFFIX}$" namespace_ends_with_double_colon ${namespace})
	IF(NOT namespace_ends_with_double_colon)
		MESSAGE(FATAL_ERROR "Namespace must end with ${CMDEF_ENV_NAMESPACE_SUFFIX}.")
	ENDIF()
ENDFUNCTION()

##
# HELPER
#
# It strips SUFFIX from the namespace
#
FUNCTION(_CMDEF_INSTALL_STRIP_NAMESPACE_SUFFIX namespace output_name)
	IF(NOT namespace)
		RETURN()
	ENDIF ()
	STRING(LENGTH ${namespace} namespace_length)
	STRING(LENGTH ${CMDEF_ENV_NAMESPACE_SUFFIX} namespace_suffix_length)
	MATH(EXPR namespace_length "${namespace_length} - ${namespace_suffix_length}")
	STRING(SUBSTRING ${namespace} 0 ${namespace_length} namespace)
	SET(${output_name} ${namespace} PARENT_SCOPE)
ENDFUNCTION()



