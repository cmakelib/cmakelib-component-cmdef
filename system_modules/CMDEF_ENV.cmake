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
# Variables which is defined only as local.
# Is not intended to be modified by user
#
SET(_CMDEF_ENV_ARCH_AMD64 "amd64")
SET(_CMDEF_ENV_ARCH_X86 "x86")



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
		CACHE BOOL
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
	CMAKE_HOST_SYSTEM_INFORMATION(RESULT system_name QUERY OS_NAME)
	MESSAGE(STATUS "System name: ${system_name}")
	SET(os_name "")
	IF("${system_name}" STREQUAL "Darwin" OR
			"${system_name}" STREQUAL "Mac OS X" OR
			"${system_name}" STREQUAL "macOS")
		SET(os_name "macosx")
		SET(_OS_MACOSX  ON)
		SET(_OS_POSIX   ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_LINUX   OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ELSEIF(${system_name} STREQUAL "Linux")
		SET(os_name "linux")
		SET(_OS_LINUX ON)
		SET(_OS_POSIX ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_MACOSX  OFF)
	ELSEIF(${system_name} STREQUAL "Windows")
		SET(os_name "windows")
		SET(_OS_LINUX OFF)
		SET(_OS_POSIX OFF)
		SET(_OS_WINDOWS ON)
		SET(_OS_MACOSX  OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ENDIF()
	SET(CMDEF_OS_NAME ${os_name}
		CACHE STRING
		"String representation of OS name"
	)

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

	_CMDEF_ENV_GET_ARCH(arch)
	IF((arch STREQUAL "unknown") AND (NOT DEFINED CMAKE_SCRIPT_MODE_FILE))
		MESSAGE(FATAL_ERROR "Cannot determine system architecture!")
	ENDIF()
	SET(CMDEF_ARCHITECTURE ${arch}
		CACHE STRING
		"Achitecture for which we will compile"
	)
	MESSAGE(STATUS "Architecture: ${arch}")
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
MACRO(_CMDEF_ENV_GET_ARCH arch)
	IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
		SET(${arch} "${_CMDEF_ENV_ARCH_AMD64}")
	ELSEIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
		SET(${arch} "${_CMDEF_ENV_ARCH_X86}")
	ELSE()
		SET(${arch} "unknown")
	ENDIF()
ENDMACRO()



CMDEF_ENV_INIT()
