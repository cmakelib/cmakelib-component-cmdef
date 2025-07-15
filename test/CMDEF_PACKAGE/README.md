# CMDEF_PACKAGE Tests

Unit tests for the `CMDEF_PACKAGE` function.

## Directory Structure

### `shared_sources/`

Contains reusable test resources - C++ source files and headers

### `test_cases/`

Individual test cases covering:
- Package creation (executable, shared, static, interface libraries)
- Configuration file generation and custom targets
- Multiconfig generator support and dependency handling
- Error conditions and parameter validation

## Usage

Run all CMDEF_PACKAGE tests:
```bash
cmake .
```