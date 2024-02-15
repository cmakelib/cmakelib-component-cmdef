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
# Workflow:
# - If the given target has INSTALL_INCLUDE_DIRECTORIES property
#   (created by CMDEF_ADD_LIBRARY)
# - Set DESTINATION for all types
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
		OPTIONS
			NO_INSTALL_CONFIG # TODO check and if useless delete
		REQUIRED
			TARGET
		P_ARGN ${ARGN}
	)

	IF(NOT DEFINED __CONFIGURATIONS)
		SET(__CONFIGURATIONS ${CMDEF_BUILD_TYPE_LIST_UPPERCASE})
	ENDIF()

	SET(original_target ${__TARGET})
	MESSAGE("OG target 1 ${original_target}")
	CMDEF_ADD_LIBRARY_CHECK(${__TARGET} cmdef_target)
	IF(cmdef_target)
		SET(original_target ${cmdef_target})
		MESSAGE("OG target 2 ${original_target}")

		GET_PROPERTY(include_dirs TARGET ${original_target} PROPERTY CMDEF_INSTALL_INCLUDE_DIRECTORIES)
		IF(NOT include_dirs STREQUAL "NOTFOUND")
			TARGET_INCLUDE_DIRECTORIES(${original_target} INTERFACE $<INSTALL_INTERFACE:${CMDEF_INCLUDE_INSTALL_DIR}>)
			FOREACH(dir IN LISTS include_dirs)
				INSTALL(DIRECTORY ${dir}
					CONFIGURATIONS ${__CONFIGURATIONS}
					DESTINATION "${CMDEF_INCLUDE_INSTALL_DIR}"
				)
			ENDFOREACH()
		ENDIF()
	ENDIF()

	SET_TARGET_PROPERTIES(${original_target} PROPERTIES CMDEF_INSTALL ON)

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
	IF(DEFINED __NO_INSTALL_CONFIG AND NOT __NO_INSTALL_CONFIG)
		INSTALL(EXPORT ${original_target}
			CONFIGURATIONS ${__CONFIGURATIONS}
			DESTINATION "cmakem/"
		)
	ENDIF()
	MESSAGE("OG target 3 ${original_target}")

ENDFUNCTION()



##
#
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
	IF("${is_installed_by_cmdef}" STREQUAL "is_installed_by_cmdef-NOTFOUND")
		UNSET("${__OUTPUT_VAR}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	SET("${__OUTPUT_VAR}" ON PARENT_SCOPE)
ENDFUNCTION()
