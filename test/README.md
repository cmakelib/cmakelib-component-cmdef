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

Tests are designed as it run on Linux based systems as an original developemnt platform. Other supported platforms have platform specific directories which are included automatically when running on those platforms.

## Test Framework

- `TEST.cmake` - common test macros and functions to run tests and check required conditions.
- `install_override.cmake` - INSTALL command override to intercept and verify all cmake INSTALL calls use by CMDEF* functions.


## Running Tests

**Run All Tests**

```bash
cmake .
```

**Clean Up**

```bash
git clean -xfd .
```
