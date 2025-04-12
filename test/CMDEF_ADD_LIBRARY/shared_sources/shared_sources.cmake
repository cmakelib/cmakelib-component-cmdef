## Shared Sources Configuration
#
# Defines common paths for CMDEF_ADD_LIBRARY test resources
#
# This file provides standardized variables for accessing shared test resources
# across all CMDEF_ADD_LIBRARY test cases.
#

# Define shared test resource paths
SET(TEST_RESOURCES_DIR "${CMAKE_CURRENT_LIST_DIR}")
SET(LIBRARY_SOURCE_FILE "${TEST_RESOURCES_DIR}/src/library.cpp")
SET(UTILS_SOURCE_FILE "${TEST_RESOURCES_DIR}/src/utils.cpp")
SET(LIBRARY_INCLUDE_DIR "${TEST_RESOURCES_DIR}/include")
