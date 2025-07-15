## Shared Sources Configuration
#
# Defines common paths and variables for CMDEF_PACKAGE tests
#

SET(SHARED_SOURCES_DIR "${CMAKE_CURRENT_LIST_DIR}")

SET(LIBRARY_SOURCE_FILE "${SHARED_SOURCES_DIR}/src/library.cpp")
SET(MAIN_SOURCE_FILE "${SHARED_SOURCES_DIR}/src/main.cpp")

SET(LIBRARY_INCLUDE_DIR "${SHARED_SOURCES_DIR}/include")

SET(CUSTOM_CPACK_CONFIG_FILE "${SHARED_SOURCES_DIR}/custom_cpack_config.cmake")
