## Shared Sources Configuration
#
# Defines common paths for CMDEF_ADD_EXECUTABLE test resources
#
# This file provides standardized variables for accessing shared test resources
# across all CMDEF_ADD_EXECUTABLE test cases.
#

# Define shared test resource paths
SET(TEST_RESOURCES_DIR "${CMAKE_CURRENT_LIST_DIR}")
SET(MAIN_SOURCE_FILE "${TEST_RESOURCES_DIR}/src/main.cpp")
SET(UTILS_SOURCE_FILE "${TEST_RESOURCES_DIR}/src/utils.cpp")
SET(PLATFORM_UTILS_SOURCE_FILE "${TEST_RESOURCES_DIR}/src/platform_utils.cpp")
SET(EXECUTABLE_INCLUDE_DIR "${TEST_RESOURCES_DIR}/include")
