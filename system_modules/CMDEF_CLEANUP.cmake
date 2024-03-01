## Main
#
# Cleanup compile and link options
#

INCLUDE_GUARD(GLOBAL)



##
#
# Remove all build options.
# No global build options are available after the function call
#
# <function> (
# )
#
MACRO(CMDEF_CLEANUP)
	_CMDEF_CLEANUP_COMPILE(C)
	_CMDEF_CLEANUP_COMPILE(CXX)
	_CMDEF_CLEANUP_LINK(EXE)
	_CMDEF_CLEANUP_LINK(SHARED)
	_CMDEF_CLEANUP_LINK(STATIC)
	_CMDEF_CLEANUP_LINK(MODULE)
ENDMACRO()



## Helper
#
# Set given compile options to empty set
#
# <function>(
#		<type> - one of {C, CXX}
# )
#
MACRO(_CMDEF_CLEANUP_COMPILE type)
	SET(CMAKE_${type}_FLAGS ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${type}_FLAGS_DEBUG ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${type}_FLAGS_RELEASE ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${type}_FLAGS_MINSIZEREL ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${type}_FLAGS_RELWITHDEBINFO ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
ENDMACRO()



## Helper
#
# Set given link options to empty set
#
# <function> (
#		<exe_type> - one of {EXE, SHARED, STATIC, MODULE}
# )
#
MACRO(_CMDEF_CLEANUP_LINK exe_type)
	SET(CMAKE_${exe_type}_LINKER_FLAGS ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${exe_type}_LINKER_FLAGS_DEBUG ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${exe_type}_LINKER_FLAGS_RELEASE ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${exe_type}_LINKER_FLAGS_MINSIZEREL ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
	SET(CMAKE_${exe_type}_LINKER_FLAGS_RELWITHDEBINFO ""
		CACHE STRING "Initialized by CMDEF CLEANUP component"
		FORCE
	)
ENDMACRO()
