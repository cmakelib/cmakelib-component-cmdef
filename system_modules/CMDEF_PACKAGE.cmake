## Main
#
# Create CMake package.
# Package targets created with CMDEF_ADD_LIBRARY or CMDEF_ADD_EXECUTABLE and installed by CMDEF_INSTALL.
# Provides packaging for other targets too, but with reduced functionality.
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
# If MAIN_TARGET is created and installed by CMDEF,
# it will check dependencies and include those directly linked, not imported and created by CMDEF in the target package.
# These dependencies must be in the same namespace as the MAIN_TARGET.
# NAMESPACE of the MAIN_TARGET is the same as the MAIN_TARGET's name.
#
# [Arguments]
# MAIN_TARGET is main target (Definition in README.md).
# Basically it represents target which will serve as reference
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

	CMDEF_ADD_LIBRARY_CHECK(${__MAIN_TARGET} cmdef_library)
	CMDEF_ADD_EXECUTABLE_CHECK(${__MAIN_TARGET} cmdef_executable)
	IF(DEFINED cmdef_library OR DEFINED cmdef_executable)
		_CMDEF_PACKAGE_FIND_AND_CHECK_DEPENDENCIES(
				MAIN_TARGET ${__MAIN_TARGET}
				OUTPUT_DEPENDENCIES_LIST targets_to_include
		)
		LIST(APPEND targets_to_include ${__MAIN_TARGET})
		_CMDEF_PACKAGE_CHECK_NAMESPACE(${__MAIN_TARGET} "${targets_to_include}")
	ENDIF()

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

	SET(package_config_file "${CMAKE_CURRENT_BINARY_DIR}/${__MAIN_TARGET}Config.cmake")
	SET(package_version_file "${CMAKE_CURRENT_BINARY_DIR}/${__MAIN_TARGET}ConfigVersion.cmake")

	INCLUDE(CMakePackageConfigHelpers)
	CONFIGURE_PACKAGE_CONFIG_FILE(
		"${_CMDEF_PACKAGE_CURRENT_DIR}/resources/cmake_package_config.cmake.in"
		"${package_config_file}"
		INSTALL_DESTINATION "${CMDEF_LIBRARY_INSTALL_DIR}/cmake/${__MAIN_TARGET}/"
	)

	WRITE_BASIC_PACKAGE_VERSION_FILE(
		"${package_version_file}"
		VERSION "${__VERSION}"
		COMPATIBILITY SameMajorVersion
	)
	INSTALL(FILES "${package_config_file}" "${package_version_file}"
		DESTINATION "${CMDEF_LIBRARY_INSTALL_DIR}/cmake/${__MAIN_TARGET}/"
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
		SET(package_filename  "${package_name_rule}${CMDEF_ENV_NAME_SEPARATOR}v${__VERSION}${CMDEF_ENV_NAME_SEPARATOR}${CMDEF_DISTRO_ID}-${CMDEF_DISTRO_VERSION_ID}-${CMDEF_ARCHITECTURE}")

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

##
# HELPER
#
# Find and check dependencies of the main target.
# Adds all main_target's directly linked CMDEF targets, that are not IMPORTED into output_dependencies_list.
# The dependencies are included only if they are CMDEF targets.
#
# Function finds all linked libraries of the main_target and then recursively checks their dependencies.
#
# [Arguments]
# MAIN_TARGET - package target, for which we want to check and include dependencies
# OUTPUT_DEPENDENCIES_LIST - output variable to store all installed, cmdef, not-imported dependencies of the main target
#
# <function>(
#	MAIN_TARGET              <main_target>
#	OUTPUT_DEPENDENCIES_LIST <output_dependencies_list> M // list of targets
# )
FUNCTION(_CMDEF_PACKAGE_FIND_AND_CHECK_DEPENDENCIES)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			MAIN_TARGET
		MULTI_VALUE
			OUTPUT_DEPENDENCIES_LIST
		REQUIRED
			MAIN_TARGET
			OUTPUT_DEPENDENCIES_LIST
		P_ARGN ${ARGN}
	)
	SET(dependencies)
	GET_TARGET_PROPERTY(linked_libraries ${__MAIN_TARGET} INTERFACE_LINK_LIBRARIES)
	_CMDEF_PACKAGE_FIND_NOT_IMPORTED_TARGETS(LIBRARIES ${linked_libraries} OUTPUT_TARGETS dependencies)

	FOREACH (dependency IN LISTS dependencies)
		_CMDEF_PACKAGE_CHECK_DEPENDENCIES(
				LIBRARY ${dependency}
				__ALREADY_LINKED_LIBS ${dependencies}
		)
	ENDFOREACH ()
	_CMDEF_PACKAGE_CHECK_IF_DEPENDENCIES_INSTALLED_BY_CMDEF(
			DEPENDENCIES ${dependencies}
			OUTPUT_INSTALLED_CMDEF_TARGETS dependencies_to_include
	)

	SET(${__OUTPUT_DEPENDENCIES_LIST} "${dependencies_to_include}" PARENT_SCOPE)
ENDFUNCTION()

##
# HELPER
#
# Find and put all not-IMPORTED Cmake TARGETS from list LIBRARIES into OUTPUT_TARGETS.
#
# [Arguments]
# LIBRARIES - list of libraries to check
# OUTPUT_TARGETS - output variable to store not IMPORTED CMake TARGETS
#
# <function>(
#	LIBRARIES      <linked_libraries> M
# 	OUTPUT_TARGETS <output_targets> M	// list
# )
FUNCTION(_CMDEF_PACKAGE_FIND_NOT_IMPORTED_TARGETS)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LIBRARIES
			OUTPUT_TARGETS
		REQUIRED
			LIBRARIES
			OUTPUT_TARGETS
		P_ARGN ${ARGN}
	)
	SET(targets)

	FOREACH (library IN LISTS __LIBRARIES)
		IF (NOT TARGET ${library})
			CONTINUE()
		ENDIF ()

		GET_TARGET_PROPERTY(imported ${library} IMPORTED)
		IF (NOT imported)
			LIST(APPEND targets ${library})
		ENDIF ()
	ENDFOREACH ()

	SET(${__OUTPUT_TARGETS} ${targets} PARENT_SCOPE)
ENDFUNCTION()

##
# HELPER
# Used for checking transitive dependencies of the main target.
# All those dependencies should be IMPORTED or linked directly to the main target.
# Warns if the LIBRARY is not IMPORTED and is not in __ALREADY_LINKED_LIBS.
#
# <function>(
# 	LIBRARY                <library>
# 	__ALREADY_LINKED_LIBS  <already_linked_libs> M
# )
#
FUNCTION(_CMDEF_PACKAGE_CHECK_DEPENDENCIES)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			LIBRARY
		MULTI_VALUE
			__ALREADY_LINKED_LIBS
		REQUIRED
			LIBRARY
			__ALREADY_LINKED_LIBS
		P_ARGN ${ARGN}
	)
	GET_TARGET_PROPERTY(linked_interfaces ${__LIBRARY} INTERFACE_LINK_LIBRARIES)
	IF (NOT linked_interfaces)
		RETURN()
	ENDIF ()

	FOREACH (linked_lib IN LISTS linked_interfaces)
		IF (NOT TARGET ${linked_lib})
			CONTINUE()
		ENDIF ()
		GET_TARGET_PROPERTY(imported ${linked_lib} IMPORTED)
		IF (imported)
			CONTINUE()
		ENDIF ()
		IF (NOT "${linked_lib}" IN_LIST ____ALREADY_LINKED_LIBS)
			# TODO rewrite for more clarity
			MESSAGE(WARNING "Library ${linked_lib} is a dependency of ${input_library}, but is a NOT IMPORTED target and it is not direct dependency of ${__MAIN_TARGET}")
		ENDIF ()
	ENDFOREACH ()
ENDFUNCTION()

##
# HELPER
#
# Checks if the dependencies are CMDEF targets and if they are installed.
# If the dependency is installed, it is added to the OUTPUT_INSTALLED_CMDEF_TARGETS.
# Otherwise the function will fail.
#
# If the dependency is installed with option NO_INSTALL_CONFIG, it is not included.
#
# <function>(
# 	OUTPUT_INSTALLED_CMDEF_TARGETS <output_installed_cmdef_targets> M	// list of installed dependencies
# 	[DEPENDENCIES                   <list_of_dependencies> M]
# )
#
FUNCTION(_CMDEF_PACKAGE_CHECK_IF_DEPENDENCIES_INSTALLED_BY_CMDEF)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			DEPENDENCIES
			OUTPUT_INSTALLED_CMDEF_TARGETS
		REQUIRED
			OUTPUT_INSTALLED_CMDEF_TARGETS
		P_ARGN ${ARGN}
	)
	SET(dependencies_to_include)
	FOREACH (target IN LISTS __DEPENDENCIES)
		CMDEF_ADD_LIBRARY_CHECK(${target} is_cmdef_target)
		IF(NOT is_cmdef_target)
			CONTINUE()
		ENDIF ()
		CMDEF_INSTALL_USED_FOR(TARGET ${target} OUTPUT_VAR is_installed)
		IF(is_installed)
			GET_TARGET_PROPERTY(no_install_config ${target} CMDEF_NO_INSTALL_CONFIG)
			IF(NOT no_install_config)
				LIST(APPEND dependencies_to_include ${target})
			ENDIF ()
		ELSE ()
			MESSAGE(FATAL_ERROR "Dependency ${target} is not installed")
		ENDIF ()
	ENDFOREACH ()
	SET(${__OUTPUT_INSTALLED_CMDEF_TARGETS} "${dependencies_to_include}" PARENT_SCOPE)
ENDFUNCTION()

##
# Helper
#
# It goes over all direct include targets of the main target and checks namespace
# The namespaces have to match the main target's name. Throws error if not.
#
# <function>(
# 	<main_target>
# 	<dependencies>
# )
FUNCTION(_CMDEF_PACKAGE_CHECK_NAMESPACE main_target dependencies)
	FOREACH (dependency IN LISTS dependencies)
		GET_TARGET_PROPERTY(namespace ${dependency} CMDEF_NAMESPACE)
		IF (NOT "${namespace}" STREQUAL "${main_target}")
			MESSAGE(FATAL_ERROR "NAMESPACE of target \"${dependency}\" is not the same as the main target's name \"${main_target}\".")
		ENDIF ()
	ENDFOREACH ()
ENDFUNCTION()
