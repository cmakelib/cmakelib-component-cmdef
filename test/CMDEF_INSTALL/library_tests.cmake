

##
# 
# Test library installation with complete INSTALL command verification.
#
# Creates a library and verifies all INSTALL commands are called
# with correct destinations and parameters.
#
# <function> (
#   <target_name>
# )
#
FUNCTION(LIBRARY_TESTS target_name)
    TEST_INSTALL_TARGETS_EXPORT_EQUALS(${target_name})
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("ARCHIVE" "${CMDEF_LIBRARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("LIBRARY" "${CMDEF_LIBRARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("RUNTIME" "${CMDEF_BINARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("BUNDLE" "${CMDEF_BINARY_INSTALL_DIR}")
    TEST_INSTALL_TARGETS_DESTINATION_EQUALS("PUBLIC_HEADER" "${CMDEF_INCLUDE_INSTALL_DIR}")
    
    TEST_INSTALL_TARGETS_CONFIGURATIONS_CONTAINS("DEBUG")
    TEST_INSTALL_TARGETS_CONFIGURATIONS_CONTAINS("RELEASE")
    
    TEST_INSTALL_EXPORT_DESTINATION_EQUALS("${CMDEF_LIBRARY_INSTALL_DIR}/cmake//")
    
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("DEBUG")
    TEST_INSTALL_EXPORT_CONFIGURATIONS_CONTAINS("RELEASE")
ENDFUNCTION()