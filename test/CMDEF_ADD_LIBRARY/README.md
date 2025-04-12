# CMDEF_ADD_LIBRARY Tests

Unit tests for the `CMDEF_ADD_LIBRARY` function.

## Directory Structure

### `shared_sources/`

Contains reusable C++ library sources used across multiple test cases:
- `src/` - C++ source files (library.cpp)
- `include/` - Header files (library.h)
- `include1/` - Additional header directory (header1.h)
- `include2/` - Additional header directory (header2.h)

### `test_cases/`

Individual test case directories, each containing a `CMakeLists.txt` file that tests specific functionality:

- **Basic library types** (interface, shared, static libraries)
- **Include directory handling** (single, multiple, install directories)
- **Version and SOVERSION** (validation, platform-specific behavior)
- **Platform-specific features** (Windows MSVC runtime, POSIX SOVERSION)
- **Debug suffix handling** (build type, generator expressions)
- **Cache variable integration** (CMDEF_ENV variable usage)
- **Parameter validation** (missing parameters, invalid inputs)
- **Check function** (CMDEF_ADD_LIBRARY_CHECK validation)

## Functionality Covered by Tests

- Basic library creation (shared, static, interface)
- Multiple include directories handling
- Version validation
- Parameter validation
- Cache variable integration
- Interface library source handling
- Debug suffix handling
- Check function validation

## Functionality Not Covered by Tests

- Cross-platform installation behavior
- Complex dependency chains
- Custom build configurations
- Performance with large source sets

## Usage

Run all CMDEF_ADD_LIBRARY tests:
```bash
cmake .
```
