# CMDEF_ADD_EXECUTABLE Tests

Unit tests for the `CMDEF_ADD_EXECUTABLE` function.

## Directory Structure

### `shared_sources/`

Contains reusable C++ application sources used across multiple test cases:
- `src/` - C++ source files (main.cpp, utils.cpp, platform_utils.cpp)
- `include/` - Header files (utils.h, platform_utils.h)

### `error_test_sources/`

Contains source files specifically for testing error conditions that require invalid or problematic code.

### `test_cases/`

Individual test case directories, each containing a `CMakeLists.txt` file that tests specific functionality:

- Basic properties (minimal, includes, output name, check function)
- Debug suffix handling (build type, generator expressions)
- Parameter combinations (multiple sources, all parameters)
- Error conditions (missing parameters, invalid inputs)
- Platform-specific behavior (WIN32, MACOS_BUNDLE flags)
- Windows-specific features (MSVC runtime, resource generation)

## Functionality Covered by Tests

- Basic executable creation
- Include directory handling
- Custom output name
- Multiple source files
- Platform-specific flags (WIN32, MACOS_BUNDLE)
- Debug suffix handling
- Parameter validation
- Check function validation

## Functionality Not Covered by Tests

- Cross-platform deployment

## Usage

Run all CMDEF_ADD_EXECUTABLE tests:
```bash
cmake .
```