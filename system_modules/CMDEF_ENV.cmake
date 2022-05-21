## Main
#
# initialize base CMDEF CMake variables.
#
# Module relay on some CMake variables like
# - CMAKE_SIZEOF_VOID_P (not defined for Script mode)
# - CMAKE_CURRENT_BINARY_DIR (defined as "${CMAKE_CURRENT_LIST_DIR}" for script mode)
#

IF(DEFINED CMDEF_ENV_MODULE)
	RETURN()
ENDIF()
SET(CMDEF_ENV_MODULE 1)

FIND_PACKAGE(CMLIB)

#
# Variable that is defined only as local.
# Is not intended to be modified by user
#
# It holds list of supported/well_tested architectures
#
# aplsil architecture referes to Apple silicon 
#
SET(_CMDEF_ENV_SUPPORTED_ARCH_LIST "x86-64" "x86" "aarch64" "aplsil")



##
# Initialize CMDEF CMake variables.
#
# <function>(
# )
#
FUNCTION(CMDEF_ENV_INIT)

	_CMDEF_ENV_SET_OS()
	_CMDEF_ENV_SET_PACKAGE(${CMDEF_OS_NAME})
	_CMDEF_ENV_SET_OUTPUT_DIR()
	_CMDEF_ENV_SET_TARGET_INSTALL_DIR()
	_CMDEF_ENV_SET_DESCRIPTION()

	_CMDEF_ENV_SET_SUPPORTED_LANG()

	IF(CMDEF_OS_WINDOWS)
		IF(NOT CMDEF_WINDOWS_EXECUTABLE_MT)
			FIND_PROGRAM(CMDEF_WINDOWS_EXECUTABLE_MT "mt.exe")
			IF(${CMDEF_WINDOWS_EXECUTABLE_MT} STREQUAL "${prefix}WINDOWS_EXECUTABLE_MT-NOTFOUND")
				MESSAGE(WARNING "Could not find mt.exe. Some functionality may not be available. Suggesting mt.exe")
				SET(CMDEF_WINDOWS_EXECUTABLE_MT "mt.exe" CACHE STRING "mt.exe" FORCE)
			ENDIF()
		ENDIF()
	ENDIF()
	IF(CMDEF_OS_MACOSX)
		FIND_PROGRAM(CMDEF_MACOSX_EXECUTABLE_IBTOOL ibtool
			HINTS "/usr/bin" "${OSX_DEVELOPER_ROOT}/usr/bin")
		IF(${CMDEF_MACOSX_EXECUTABLE_IBTOOL} STREQUAL "${prefix}MACOSX_EXECUTABLE_IBTOOL-NOTFOUND")
			MESSAGE(SEND_ERROR "Could not find 'ibtool'. Some functionality may not be available")
		ENDIF()
	ENDIF()

	SET(CMDEF_MULTICONF_FOLDER_NAME "CMDEF"
		CACHE PATH
		"Name of folder for CMDEF targets in multiconfig like Visual Studio"
	)

ENDFUNCTION()



## Helper
# Set package variables
#
# <function>(
# )
#
MACRO(_CMDEF_ENV_SET_PACKAGE os_name)
	SET(CMDEF_LIBRARY_PREFIX "lib"
		CACHE STRING
		"Suffix for package names if the installed target is library"
	)
	SET(CMDEF_LIBRARY_NAME_FLAG_STATIC "-static"
		CACHE STRING
		"Flag which is appended to library name and CMDEF_*_NAME_DEBUG_SUFFIX"
	)
	SET(CMDEF_LIBRARY_NAME_FLAG_SHARED ""
		CACHE STRING
		"Flag which is appended to library name and CMDEF_*_NAME_DEBUG_SUFFIX"
	)
	SET(CMDEF_LIBRARY_NAME_DEBUG_SUFFIX "d"
		CACHE STRING
		"Suffix for library name if the target is configured in debug"
	)
	SET(CMDEF_LIBRARY_NAME_DEV_SUFFIX "-dev"
		CACHE STRING
		"Suffix for development library"
	)
	SET(CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX "d"
		CACHE STRING
		"Suffix for executable name if the target is configured in debug"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_WINDOWS ".lib"
		CACHE STRING
		".lib"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_WINDOWS ".dll"
		CACHE STRING
		".dll"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_LINUX ".a"
		CACHE STRING
		".a"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_LINUX ".so"
		CACHE STRING
		".so"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_MACOSX ".a"
		CACHE STRING
		".a"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_MACOSX ".dylib"
		CACHE STRING
		".dylib"
	)

	IF(NOT DEFINED CMDEF_OS_NAME_UPPER)
		MESSAGE(FATAL_ERROR "")
	ENDIF()

	SET(shared_var_name CMDEF_LIBRARY_NAME_SUFFIX_SHARED_${CMDEF_OS_NAME_UPPER})
	SET(static_var_name CMDEF_LIBRARY_NAME_SUFFIX_STATIC_${CMDEF_OS_NAME_UPPER})
	IF(NOT DEFINED ${shared_var_name} OR
			NOT DEFINED ${static_var_name})
		MESSAGE(FATAL_ERROR "Undefined suffix variable!")
	ENDIF()
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED "${${shared_var_name}}"
		CACHE STRING
		"Suffix for shared library. Determined by host OS."
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC "${${static_var_name}}"
		CACHE STRING
		"Suffix for static library. Determined by host OS."
	)
ENDMACRO()



## Helper
# Set and control list of supported languages
# 
# <function> (
# )
#
MACRO(_CMDEF_ENV_SET_SUPPORTED_LANG)
	SET(CMDEF_SUPPORTED_LANG_LIST C;CXX;OBJC;OBJCXX;RC;
		CACHE STRING
		"Supported programming languages"
	)
ENDMACRO()



## Helper
# Define variables for OS
#
# <function> (
# )
#
MACRO(_CMDEF_ENV_SET_OS)
	CMAKE_HOST_SYSTEM_INFORMATION(RESULT _os_name QUERY OS_NAME)
	MESSAGE(STATUS "System name: ${_os_name}")
	SET(os_name "")
	IF("${_os_name}" STREQUAL "Darwin" OR
			"${_os_name}" STREQUAL "Mac OS X" OR
			"${_os_name}" STREQUAL "macOS")
		SET(os_name "macos")
	ELSEIF("${_os_name}" STREQUAL "Linux")
		SET(os_name "linux")
	ELSEIF("${_os_name}" STREQUAL "Windows")
		SET(os_name "windows")
	ENDIF()

	SET(CMDEF_OS_NAME ${os_name}
		CACHE STRING
		"String, normalized representation of OS name"
	)
	IF("${CMDEF_OS_NAME}" STREQUAL "macos")
		SET(_OS_MACOSX  ON)
		SET(_OS_POSIX   ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_LINUX   OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ELSEIF("${CMDEF_OS_NAME}" STREQUAL "linux")
		SET(_OS_LINUX ON)
		SET(_OS_POSIX ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_MACOSX  OFF)
	ELSEIF("${CMDEF_OS_NAME}" STREQUAL "windows")
		SET(_OS_LINUX OFF)
		SET(_OS_POSIX OFF)
		SET(_OS_WINDOWS ON)
		SET(_OS_MACOSX  OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ELSE()
		MESSAGE(FATAL_ERROR "Unsupported CMDEF_OS_NAME value: ${CMDEF_OS_NAME}")
	ENDIF()

	STRING(SUBSTRING "${CMDEF_OS_NAME}" 0 3 os_name_short)
	SET(CMDEF_OS_NAME_SHORT ${os_name_short}
		CACHE STRING
		"Short-string representation of OS name"
	)
	
	STRING(TOUPPER ${CMDEF_OS_NAME} os_name_upper)
	SET(CMDEF_OS_NAME_UPPER ${os_name_upper}
		CACHE INTERNAL
		"String representation of OS name - upper case"
		FORCE
	)

	SET(CMDEF_OS_MACOSX ${_OS_MACOSX}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_WINDOWS ${_OS_WINDOWS}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_LINUX ${_OS_LINUX}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_POSIX ${_OS_POSIX}
		CACHE BOOL
		"Do we have POSIX OS?"
	)

	IF(NOT CMDEF_ARCHITECTURE)
		_CMDEF_ENV_GET_ARCH(arch)
		SET(CMDEF_ARCHITECTURE ${arch}
			CACHE STRING
			"Achitecture for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Architecture: ${CMDEF_ARCHITECTURE}")
	LIST(FIND _CMDEF_ENV_SUPPORTED_ARCH_LIST "${CMDEF_ARCHITECTURE}" arch_found)
	IF(arch_found EQUAL -1)
		MESSAGE(WARNING "Unsupported Architecture: ${CMDEF_ARCHITECTURE}")
	ENDIF()

	IF (NOT CMDEF_DISTRO_ID)
		SET(distro_id)
		IF($ENV{CMDEF_DISTRO_ID})
			SET(distro_id "$ENV{CMDEF_DISTRO_ID}")
		ELSE()
			_CMDEF_ENV_GET_DISTRO_ID(distro_id)
		ENDIF()
		SET(CMDEF_DISTRO_ID ${distro_id}
			CACHE STRING
			"Distro ID for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Distro ID: ${CMDEF_DISTRO_ID}")

	IF (NOT CMDEF_DISTRO_VERSION_ID)
		SET(version_id)
		IF($ENV{CMDEF_DISTRO_VERSION_ID})
			SET(version_id "$ENV{CMDEF_DISTRO_VERSION_ID}")
		ELSE()
			_CMDEF_ENV_GET_DISTRO_VERSION_ID(version_id)
		ENDIF()
		SET(CMDEF_DISTRO_VERSION_ID ${version_id}
			CACHE STRING
			"Distro Version ID for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Distro Version ID: ${CMDEF_DISTRO_VERSION_ID}")
ENDMACRO()



## Helper
# Set output directory variable
#
# <function>(
#		<prefix>
# )
#
MACRO(_CMDEF_ENV_SET_OUTPUT_DIR)
	SET(CMDEF_TARGET_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>"
		CACHE PATH
		"Output directory for CMake targets"
	)
ENDMACRO()



## Helper
# Set install dir names which serve as DESTINATION
# for 'install' command
#
# <function>(
#		<prefix>
# )
#
MACRO(_CMDEF_ENV_SET_TARGET_INSTALL_DIR)
	SET(CMDEF_INCLUDE_INSTALL_DIR "include/"
		CACHE PATH
		"Name of include directory after install (in package)"
	)
	SET(CMDEF_LIBRARY_INSTALL_DIR "lib/"
		CACHE PATH
		"Name of library directory after install (in package)"
	)
	SET(CMDEF_BINARY_INSTALL_DIR "bin/"
		CACHE PATH
		"Name of bin directory after install (in package)"
	)
ENDMACRO()



## Helper
#
# 
#
# <function>(
# )
#
FUNCTION(_CMDEF_ENV_SET_WINDOWS_FLAGS)
	IF(NOT DEFINED CMDEF_OS_WINDOWS)
		MESSAGE(FATAL_ERROR "Canot determine target OS. Not defined.")
	ENDIF()
	IF(NOT CMDEF_OS_WINDOWS)
		RETURN()
	ENDIF()

	SET(CMDEF_WINDOWS_STATIC_RUNTIME ON
		CACHE BOOL
		"If ON then STATIC runtime is used, of OFF DYNAMIC runtime is used"
	)
ENDFUNCTION()



## Helper
#
# <function> (
#		
#)
#
FUNCTION(_CMDEF_ENV_SET_DESCRIPTION)
	SET(CMDEF_ENV_DESCRIPTION_COMPANY_NAME "Company name"
		CACHE STRING
		"Name of the company"
	)
	SET(CMDEF_ENV_DESCRIPTION_COPYRIGHT "${CMDEF_ENV_DESCRIPTION_COMPANY_NAME}"
		CACHE STRING
		"Copyrigth which will be added to binaries"
	)
ENDFUNCTION()



## Helper
#
# Determine architecture.
# If the cannot be determined is set to 'unknown'
#
# <function>(
#		<arch_output_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_ARCH arch)
	IF(CMDEF_OS_WINDOWS)
		SET(${arch} "x86-64" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_MACOSX)
		SET(${arch} "aplsil" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_LINUX)
		FIND_PROGRAM(CMDEF_UNAME uname REQUIRED)
		EXECUTE_PROCESS(COMMAND "${CMDEF_UNAME}" -m
			OUTPUT_VARIABLE _arch
			RESULT_VARIABLE result
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		IF(NOT (result EQUAL 0))
			MESSAGE(FATAL_ERROR "Cannot determine architecture! Set up CMDEF_ARCHITECTURE manually or repair uname")
		ENDIF()
		STRING(REGEX REPLACE "[^a-zA-Z0-9]" "-" _arch_mapped "${_arch}")
		STRING(TOLOWER "${_arch_mapped}" _arch_normalized)
		SET(${arch} "${_arch_normalized}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Cannot get architecture for unknown OS ${CMDEF_OS_NAME}")
ENDFUNCTION()


## Helper
#
# Determine distribution ID
#
# <function>(
#		<distro_id_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_DISTRO_ID distro_id)
	IF(CMDEF_OS_WINDOWS)
		SET(${distro_id} "windows" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_MACOSX)
		SET(${distro_id} "macos" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_LINUX)
		FIND_PROGRAM(CMDEF_LSB_RELEASE lsb_release REQUIRED)
		EXECUTE_PROCESS(COMMAND "${CMDEF_LSB_RELEASE}" -i -s
			OUTPUT_VARIABLE _distro_id
			RESULT_VARIABLE result
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		IF(NOT (result EQUAL 0))
			MESSAGE(FATAL_ERROR "Cannot determine distro ID! Set up CMDEF_DISTRO_ID manually or repair lsb_release")
		ENDIF()
		STRING(REGEX REPLACE "[^a-zA-Z0-9]" "-" _distro_id_mapped "${_distro_id}")
		STRING(TOLOWER "${_distro_id_mapped}" _distro_id_normalized)
		SET(${distro_id} "${_distro_id_normalized}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Cannot get distro id for unknown OS ${CMDEF_OS_NAME}")
ENDFUNCTION()



## Helper
#
# Determine Distro Version ID
#
# <function>(
#		<version_id_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_DISTRO_VERSION_ID version_id)
	FIND_PROGRAM(CMDEF_LSB_RELEASE lsb_release REQUIRED)
	EXECUTE_PROCESS(COMMAND "${CMDEF_LSB_RELEASE}" -r -s
		OUTPUT_VARIABLE _version_id
		RESULT_VARIABLE result
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	IF(NOT (result EQUAL 0))
		MESSAGE(FATAL_ERROR "Cannot determine version ID! Set up CMDEF_DISTRO_VERSION_ID manually or repair lsb_release")
	ENDIF()
	STRING(REGEX REPLACE "[^a-zA-Z0-9]" "-" _version_id_mapped "${_version_id}")
	STRING(TOLOWER "${_version_id_mapped}" _version_id_normalized)
	SET(${version_id} "${_version_id_normalized}" PARENT_SCOPE)
ENDFUNCTION()


CMDEF_ENV_INIT()
