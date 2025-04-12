# CMDEF_INSTALL Tests

## Test Strategy

The tests use an INSTALL command override mechanism to intercept and verify all INSTALL calls made by CMDEF_INSTALL. The override collects data without executing actual installation, allowing precise verification of command parameters.

## Test Structure

### Core Files

- `install_override.cmake` - INSTALL macro override and verification functions (shared across all tests)
- `shared_sources/` - Common test resources (source files, headers, path definitions)
- `test_cases/` - Individual test case directories

### Test Cases

Each test case is independent and tests one specific aspect of CMDEF_INSTALL:

1. **shared_lib** - Shared library installation with all destinations
2. **static_lib** - Static library installation verification  
3. **interface_lib** - Interface library with source file installation
4. **executable** - Executable installation destinations
5. **with_namespace** - NAMESPACE parameter and export path verification
6. **with_configs** - CONFIGURATIONS parameter verification
7. **include_dirs** - Include directory installation via INSTALL(DIRECTORY)
8. **no_config** - NO_INSTALL_CONFIG option verification
9. **multiple_calls** - Multiple independent CMDEF_INSTALL calls

## CMDEF_ENV Variable Testing

All tests verify that INSTALL destinations use the correct CMDEF_ENV variables:
- `CMDEF_LIBRARY_INSTALL_DIR` for library destinations
- `CMDEF_BINARY_INSTALL_DIR` for executable destinations  
- `CMDEF_INCLUDE_INSTALL_DIR` for header destinations
- `CMDEF_SOURCE_INSTALL_DIR` for interface source destinations

## Running Tests

Tests are executed via the main CMakeLists.txt using TEST_RUN() function:

```cmake
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/shared_lib")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/static_lib")
# ... etc
```

Each test is independent and can be run individually for debugging.
