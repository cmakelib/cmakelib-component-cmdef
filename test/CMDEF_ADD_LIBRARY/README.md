# CMDEF_ADD_LIBRARY Tests

Unit tests for the `CMDEF_ADD_LIBRARY` function.

## Directory Structure

### `shared_sources/`

Contains reusable test resources:
- C++ source files and headers
- Test helper macros and configuration

### `test_cases/`

Individual test cases covering:
- Basic library creation (interface, shared, static)
- Multiconfig generator support (Debug/Release/Multiconfig variants)
- Platform-specific features (Windows MSVC runtime, POSIX SOVERSION)
- Error conditions and parameter validation

## Usage

Run all CMDEF_ADD_LIBRARY tests:
```bash
cmake .
```
