## Main
#
# Create CMake package.
# Consumes output from CMDEF_ADD_LIBRARY, CMDEF_ADD_EXECUTABLE
#
# If the Generator supports multiconf default target PACKAGE
# is redefined to support multiconfig generators.
#

IF(DEFINED CMDEF_PACKAGE_MODULE)
	RETURN()
ENDIF()
SET(CMDEF_PACKAGE_MODULE 1)

SET(_CMDEF_PACKAGE_CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}"
	CACHE INTERNAL
	""
)

FIND_PACKAGE(CMLIB)



##
# Creates and initialize PACKAGE targets.
#
# Handle and update CPACK variables. After this function the CPACK generator
# must be chosen and INCLUDE(CPACK) must be called.
#
# If the CMAKE_BUILD_TYPE is specified default
# cpack configuration file is created (so the 'cpack' command
# can be used without explicit config file')
#
# If the CMAKE_BUILD_TYPE is not specified then custom cpack configuration file 
# is created and PACKAGE target is redefined. CPack command must by used only
# with new CPack configuration file and config.
# (Due to compatibility with multiconfig)
#
# [Arguments]
# MAIN_TARGET is main target (Definition in README.md).
# Basicaly it represents target which will serve as reference
# against which we create package. It's target from which the meta-information
# like package name etc is processed.
# The package is created for all installed resource/targets etc.
#
# CPACK_CONFIG_FILE - path to CPack config file to be used
# instead of auto-generated one
#
# CONFIGURATIONS - list of configurations for which the package
# is available. List of configurations must be subset of configurations
# which is installed by CMDEF_INSTALL.
# If the CONFIGURATIONS is not a subset of installed then the result is undefined.
# If no CONFIGURATIONS is specified that the package is created for each
# available build type / configuration.
#
# <function>(
#		VERSION <version>
#		MAIN_TARGET <valid_cmake_target>
#		[CPACK_CONFIG_FILE <cpack_config_file>]
#		[CONFIGURATIONS <configurations> M]
# )
#
FUNCTION(CMDEF_PACKAGE)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			CONFIGURATIONS
		ONE_VALUE
			VERSION
			MAIN_TARGET
			CPACK_CONFIG_FILE
		REQUIRED
			VERSION
			MAIN_TARGET
		P_ARGN ${ARGN}
	)
# TODO find dependencies in properties, everything the main target linked
	# Funkce nejprve najde vsechny NOT imported TARGETy 1. urovne -> pouze ty primo linknuty,
	# potom bude rekurzivne prochazet vsechny dependence ktere jsou TARGET a pokud najde nejaky cmake, ktery jeste nebyl definovany tak zarve WARNING
	SET(original_target "${__MAIN_TARGET}")
	CMDEF_ADD_LIBRARY_CHECK(${__MAIN_TARGET} cmdef_target)
	IF(cmdef_target)
		SET(original_target ${cmdef_target})	# TODO proc se nastavuje original target ktery se nepouziva
	ENDIF()

	_CMDEF_PACKAGE_CHECK_AND_INCLUDE_DEPENDENCIES(${__MAIN_TARGET} targets_to_include)

	SET(configurations ${CMDEF_BUILD_TYPE_LIST_UPPERCASE})
	IF(DEFINED __CONFIGURATIONS)
		SET(configurations ${__CONFIGURATIONS})
	ENDIF()

	SET(config_file)
	IF(DEFINED __CPACK_CONFIG_FILE)
		SET(config_file "${__CPACK_CONFIG_FILE}")
	ELSE()
		SET(config_file "${CMAKE_CURRENT_BINARY_DIR}/CMDEFCPackConfig.cmake")
	ENDIF()

#	SET(package_config_file "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
#	SET(package_version_file "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
	SET(package_config_file "${CMAKE_CURRENT_BINARY_DIR}/${__MAIN_TARGET}Config.cmake")
	SET(package_version_file "${CMAKE_CURRENT_BINARY_DIR}/${__MAIN_TARGET}ConfigVersion.cmake")

	INCLUDE(CMakePackageConfigHelpers)
	CONFIGURE_PACKAGE_CONFIG_FILE(
		"${_CMDEF_PACKAGE_CURRENT_DIR}/resources/cmake_package_config.cmake.in"
		"${package_config_file}"
		INSTALL_DESTINATION "cmake/"
	)
	WRITE_BASIC_PACKAGE_VERSION_FILE(
		"${package_version_file}"
		VERSION "${__VERSION}"
		COMPATIBILITY SameMajorVersion
	)
	INSTALL(FILES "${package_config_file}" "${package_version_file}"
		DESTINATION "cmake/"
	)

	SET(package_name_suffix)
	GET_TARGET_PROPERTY(target_type ${__MAIN_TARGET} TYPE)
	IF("${target_type}" STREQUAL "SHARED_LIBRARY" OR
			"${target_type}" STREQUAL "STATIC_LIBRARY" OR
			"${target_type}" STREQUAL "MODULE_LIBRARY")
		SET(package_name_suffix "${CMDEF_LIBRARY_NAME_DEV_SUFFIX}")
	ENDIF()

	SET(CPACK_PACKAGE_VERSION "${__VERSION}" PARENT_SCOPE)
	IF(DEFINED CMAKE_BUILD_TYPE)
		GET_PROPERTY(output_name TARGET ${__MAIN_TARGET} PROPERTY OUTPUT_NAME)
		SET(CPACK_PACKAGE_FILE_NAME "${output_name}${package_name_suffix}_v${__VERSION}_${CMDEF_DISTRO_ID}-${CMDEF_DISTRO_VERSION_ID}-${CMDEF_ARCHITECTURE}" PARENT_SCOPE)
	ELSE()	
		SET(CPACK_OUTPUT_CONFIG_FILE "${config_file}" PARENT_SCOPE)
		SET(package_name_rule "$<TARGET_FILE_BASE_NAME:${__MAIN_TARGET}>${package_name_suffix}")
		SET(package_filename  "${package_name_rule}_v${__VERSION}_${CMDEF_DISTRO_ID}-${CMDEF_DISTRO_VERSION_ID}-${CMDEF_ARCHITECTURE}")

		ADD_CUSTOM_TARGET(PACKAGE
			COMMAND "${CMAKE_CPACK_COMMAND}"
				"-C" "$<CONFIGURATION>"
				"-D" "CPACK_PACKAGE_FILE_NAME=${package_filename}"
				"--config" "${config_file}"
			COMMENT "Creating package"
		)
		SET_TARGET_PROPERTIES(PACKAGE
			PROPERTIES
			FOLDER "${CMDEF_MULTICONF_FOLDER_NAME}"
		)
		ADD_DEPENDENCIES(PACKAGE ${__MAIN_TARGET})
	ENDIF()
ENDFUNCTION()

FUNCTION(_CMDEF_PACKAGE_CHECK_AND_INCLUDE_DEPENDENCIES main_target output_dependencies)
	SET(dependencies)

	GET_TARGET_PROPERTY(linked_interfaces ${main_target} INTERFACE_LINK_LIBRARIES)
	_CMDEF_PACKAGE_APPEND_NOT_IMPORTED_TARGETS("${linked_interfaces}" target_interfaces)
	MESSAGE("Linked interfaces ${linked_interfaces}")
	SET(dependencies ${dependencies} ${target_interfaces})

	# TODO redundant? INTERFACE_LINK_LIBRARIES seems to find everything, but from documentation I didnt understand the function to do so
	#[[GET_TARGET_PROPERTY(linked_libs ${main_target} LINK_LIBRARIES)
	_CMDEF_PACKAGE_APPEND_NOT_IMPORTED_TARGETS("${linked_libs}" target_libs)
	SET(dependencies ${dependencies} ${target_libs})

	LIST(REMOVE_DUPLICATES dependencies)
	MESSAGE("${dependencies}")]]

	FOREACH (output_dependency IN LISTS dependencies)
		MESSAGE("Checking ${output_dependency}") # TODO debug print
		_CMDEF_PACKAGE_CHECK_DEPENDENCIES("${output_dependency}" "${dependencies}")
	ENDFOREACH ()

	SET(output_dependencies ${dependencies} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(_CMDEF_PACKAGE_APPEND_NOT_IMPORTED_TARGETS input_libraries output_targets)
	SET(targets)

	IF (input_libraries)
		FOREACH (input_library IN LISTS input_libraries)
			IF (TARGET ${input_library})
				IF (NOT "${${input_library}_IMPORTED}")
					SET(targets ${targets} ${input_library})
					MESSAGE("appended ${input_library}")
				ELSE ()
					MESSAGE("Library ${input_library} is IMPORTED")
				ENDIF ()
			ELSE ()
				MESSAGE("Library ${input_library} is not a target")
			ENDIF ()
		ENDFOREACH ()
	ELSE ()
		MESSAGE("empty input libraries") # TODO debug print
	ENDIF ()

	SET(${output_targets} ${targets} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(_CMDEF_PACKAGE_CHECK_DEPENDENCIES input_library already_included_libs)
	GET_TARGET_PROPERTY(linked_interfaces ${input_library} INTERFACE_LINK_LIBRARIES)

	IF (linked_interfaces)
		FOREACH (linked_lib IN LISTS linked_interfaces)
			MESSAGE("Checking library ${linked_lib}, dependency of ${input_library}") # TODO debug print
			IF (TARGET ${linked_lib})
				GET_TARGET_PROPERTY(imported ${linked_lib} IMPORTED)
				MESSAGE("is imported: ${imported}")
				IF (NOT ${imported})
					IF (NOT "${linked_lib}" IN_LIST already_included_libs)
						# TODO rewrite for more clarity
						MESSAGE(WARNING "Library ${linked_lib} is a dependency of ${input_library}, but is a NOT IMPORTED target and it is not direct dependency of ${__MAIN_TARGET}")
					ENDIF ()
				ENDIF ()
			ENDIF ()
		ENDFOREACH ()
	ENDIF ()

	MESSAGE("dependency Linked interfaces ${linked_interfaces}")
	#FOREACH (linked_lib IN LISTS )
	#GET_TARGET_PROPERTY(linked_libs ${input_library} LINK_LIBRARIES)
	# _CMDEF_PACKAGE_APPEND_NOT_IMPORTED_TARGETS("${linked_libs}" target_libs)
	# SET(output_dependencies ${target_libs} PARENT_SCOPE)
ENDFUNCTION()