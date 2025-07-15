# CMDEF_ADD_EXECUTABLE Tests

Unit tests for the `CMDEF_ADD_EXECUTABLE` function.

## Directory Structure

### `shared_sources/`

Contains reusable test resources:
- C++ source files and headers
- Windows resource files
- Test helper macros and configuration

### `test_cases/`

Individual test cases covering:
- Basic executable creation and parameters
- Multiconfig generator support (Debug/Release/Multiconfig variants)
- Platform-specific features (WIN32, MACOS_BUNDLE, MSVC runtime, resources)
- Error conditions and parameter validation

## Usage

Run all CMDEF_ADD_EXECUTABLE tests:
```bash
cmake .
```