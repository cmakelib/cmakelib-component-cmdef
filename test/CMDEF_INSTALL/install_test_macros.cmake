## Main
#
# CMDEF_INSTALL specific test helper macros
#
# This module provides specialized test macros for verifying target properties
# set by CMDEF_INSTALL. These macros complement the INSTALL command verification
# functions in install_override.cmake by focusing on target property validation.
#

##
# Verify target include directories contain expected interface.
#
# Checks that a target's include directories property contains the expected
# generator expression or path. This is used to verify that CMDEF_INSTALL
# properly adds INSTALL_INTERFACE generator expressions to targets.
#
# <macro>(
#     <target>                // Target name to check
#     <include_type>          // Type of include directories (INTERFACE, PUBLIC, PRIVATE)
#     <expected_interface>    // Expected interface string (e.g., generator expression)
# )
#
MACRO(TEST_CHECK_TARGET_INCLUDE_DIRECTORIES_CONTAINS target include_type expected_interface)
    SET(property_name)
    IF(${include_type} STREQUAL "INTERFACE")
        SET(property_name "INTERFACE_INCLUDE_DIRECTORIES")
    ELSEIF(${include_type} STREQUAL "PUBLIC")
        SET(property_name "INCLUDE_DIRECTORIES")
    ELSEIF(${include_type} STREQUAL "PRIVATE")
        SET(property_name "INCLUDE_DIRECTORIES")
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid include_type '${include_type}'. Must be INTERFACE, PUBLIC, or PRIVATE")
    ENDIF()

    GET_TARGET_PROPERTY(include_dirs ${target} ${property_name})
    IF(NOT include_dirs)
        MESSAGE(FATAL_ERROR "Target ${target} has no ${property_name} property")
    ENDIF()

    STRING(FIND "${include_dirs}" "${expected_interface}" found_pos)
    IF(found_pos EQUAL -1)
        MESSAGE(FATAL_ERROR "${property_name} for target ${target} does not contain '${expected_interface}'. Got: ${include_dirs}")
    ENDIF()
ENDMACRO()

##
# Verify target EXPORT_PROPERTIES contains expected property.
#
# Checks that a target's EXPORT_PROPERTIES list contains the expected property name.
# This is used to verify that CMDEF_INSTALL properly adds properties to the export
# list for interface libraries.
#
# <macro>(
#     <target>              // Target name to check
#     <expected_property>   // Expected property name in EXPORT_PROPERTIES list
# )
#
MACRO(TEST_CHECK_TARGET_EXPORT_PROPERTIES_CONTAINS target expected_property)
    GET_TARGET_PROPERTY(export_props ${target} EXPORT_PROPERTIES)
    IF(NOT export_props)
        SET(export_props "")
    ENDIF()

    IF(NOT "${expected_property}" IN_LIST export_props)
        MESSAGE(FATAL_ERROR "EXPORT_PROPERTIES for target ${target} does not contain '${expected_property}'. Got: ${export_props}")
    ENDIF()
ENDMACRO()

##
# Verify target has specific property set.
#
# Checks that a target has the specified property defined (not empty/unset).
# This is used to verify property dependencies in CMDEF_INSTALL.
#
# <macro>(
#     <target>     // Target name to check
#     <property>   // Property name that should be set
# )
#
MACRO(TEST_CHECK_TARGET_HAS_PROPERTY target property)
    GET_TARGET_PROPERTY(prop_value ${target} ${property})
    IF(NOT prop_value)
        MESSAGE(FATAL_ERROR "Target ${target} should have property ${property} set but it is not set or empty")
    ENDIF()
ENDMACRO()

##
# Verify target does NOT have specific property set.
#
# Checks that a target does not have the specified property defined or it is empty.
# This is used to verify conditional behavior in CMDEF_INSTALL.
#
# <macro>(
#     <target>     // Target name to check
#     <property>   // Property name that should NOT be set
# )
#
MACRO(TEST_CHECK_TARGET_LACKS_PROPERTY target property)
    GET_TARGET_PROPERTY(prop_value ${target} ${property})
    IF(prop_value)
        MESSAGE(FATAL_ERROR "Target ${target} should NOT have property ${property} set but it is set to: ${prop_value}")
    ENDIF()
ENDMACRO()