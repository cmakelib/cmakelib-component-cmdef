# CMDEF Test Suite

Comprehensive test suite for the CMDEF (CMake Definition Framework) component library.

## Test Modules

Currently tested functionality

- **`CMDEF_ADD_EXECUTABLE`**
- **`CMDEF_ADD_LIBRARY`**
- **`CMDEF_ENV`**
- **`CMDEF_INSTALL`**
- **`CMDEF_PACKAGE`**

### Test Structure

Tests are organized into subdirectories, each containing a `CMakeLists.txt` file that tests specific functionality.

Each CMDEF_* directory has a test_cases directory which contains individual test cases.

If test resources are shared between test cases, they are placed in a `shared_sources` directory.
(exceptions can apply of reasoned).

In `shared_sources` directory there is a `shared_sources.cmake` file which defines variables for test resources.
This file is included by all test cases which needs test files to implement/run the test.

Tests are designed as it run on Linux based systems as an main developemnt platform. Other supported platforms have platform specific directories which are included automatically when running on those platforms.

## Test Framework

- `TEST.cmake` - common test macros and functions to run tests and check required conditions.
- `install_override.cmake` - INSTALL command override to intercept and verify all cmake INSTALL calls use by CMDEF* functions.
- `cache_var.cmake` - Macros to force set and restore cache variables.

### Platform/OS Detection

To detect platform to execute tests valid only for a given platform
CMDEF_OS* variables are used.

CMDEF_OS* varaibles are properly tested thus it shall have a correct value and can be used to determine the platform to decide which tests shall be run.

### Test Resource Creation and Maintenance

When external resources are needed to test a functionality

- they are created from scratch.
- There are no external dependencies to download or install.
- There shall be no dynamic creation of test resources (C++ files, rc files etc.) during a test run.
  Exceptions can apply if reasoned.

## Running Tests

**All tests are designed to be run from a clean source tree.**

### Run All Tests

```bash
cmake .
```

### Clean Up

```bash
git clean -xfd .
```
