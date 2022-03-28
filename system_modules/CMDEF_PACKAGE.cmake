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

SET(CMDEF_PACKAGE_CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}")

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
			VERSION MAIN_TARGET
			CPACK_CONFIG_FILE
		REQUIRED
			VERSION
			MAIN_TARGET
		P_ARGN ${ARGN}
	)

	SET(original_target "${__MAIN_TARGET}")
	CMDEF_ADD_LIBRARY_CHECK(${__MAIN_TARGET} cmdef_target)
	IF(cmdef_target)
		SET(original_target ${cmdef_target})
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

	SET(package_config_file "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
	SET(package_version_file "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")

	INCLUDE(CMakePackageConfigHelpers)
	CONFIGURE_PACKAGE_CONFIG_FILE(
		"${CMDEF_PACKAGE_CURRENT_DIR}/resources/cmake_package_config.cmake.in"
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

	SET(CPACK_PACKAGE_VERSION "${__VERSION}" PARENT_SCOPE)
	IF(DEFINED CMAKE_BUILD_TYPE)
		GET_PROPERTY(output_name TARGET ${__MAIN_TARGET} PROPERTY OUTPUT_NAME)
		SET(CPACK_PACKAGE_FILE_NAME "${output_name}${CMDEF_LIBRARY_NAME_DEV_SUFFIX}_v${__VERSION}_${CMDEF_DISTRO_ID}-${CMDEF_DISTRO_VERSION_ID}-${CMDEF_ARCHITECTURE}" PARENT_SCOPE)
	ELSE()	
		SET(CPACK_OUTPUT_CONFIG_FILE "${config_file}" PARENT_SCOPE)
		SET(package_name_rule "$<TARGET_FILE_BASE_NAME:${__MAIN_TARGET}>${CMDEF_LIBRARY_NAME_DEV_SUFFIX}")
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
