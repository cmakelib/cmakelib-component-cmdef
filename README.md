
# CMake-lib Definition Framework Component

Linux: ![buildbadge_github], Windows: ![buildbadge_github], Mac OS: ![buildbadge_github]

CMDEF aka **CMake-lib Definition Framework**

CMake-lib provides consistent settings for build environment.
It simplifies and maintains built option, libraries and executables.

## Requirements

CMDEF is intended to be used thru [CMLIB].

CMDEF is not supposed to be used separately.

To use the library install [CMLIB] and call `FIND_PACKAGE(CMLIB COMPONENTS CMDEF)`

## General

The library is not mainly intended for extending CMake functionality.

It's set of wrappers and helpers which enables easily use of existing CMake
features in a more standardised manner across multiple projects.

### Definition of Main target

Each CMake project has one main target - the target for which the project is
created, compiled, ...

For example - CMake project for building chrome browser.
Browser is represented by the executable called `chrome`. The executable
must have own target in CMake project.

By that target other project properties are referenced - installer name, application name, documentation etc.
This type of target is called 'main target' (the 'object' for which the CMake project is created).

The library 'main target' is represented by LIBRARY_GROUP argument with suffix added according to a library type created.

## Usage

```cmake
	FIND_PACKAGE(CMLIB COMPONENTS CMDEF)
```

### Set build defaults

CMake-lib sets and maintains build and link flags and global wide definitions.

Component workflow

- reset CMake default build flags by `CMDEF_CLEANUP`
- set default build and link options  by `CMDEF_COMPILE_OPTIONS`, `CMDEF_LINK_OPTIONS`
- set compile definitions by `CMDEF_COMPILE_DEFINITIONS`

examples can be found at [example] directory.

## Function list

Each entry in list represents one feature for CMake.

Most of the functions are just wrappers which enclosures base feature of
CMake.

Detailed documentation for each function can be found at the appropriate module.

- [CMDEF_ADD_LIBRARY.cmake]
- [CMDEF_ADD_EXECUTABLE.cmake]
- [CMDEF_BUILD_TYPE.cmake]
- [CMDEF_COMPILE_DEFINITION.cmake]
- [CMDEF_COMPILE_OPTION.cmake]
- [CMDEF_ENV.cmake]
- [CMDEF_INSTALL.cmake]
- [CMDEF_LINK_OPTION.cmake]
- [CMDEF_PACKAGE.cmake]

## Documentation

Every function has a comprehensive documentation written as part of the function definition.

Context documentation is located at [doc/README.md]

## Coding standards

- The uppercase letters are used for all keywords and global variables
- Each helper function must begin with '_'

[CMLIB]: https://github.com/cmakelib/cmakelib

[CMDEF_ADD_LIBRARY.cmake]: system_modules/CMDEF_ADD_LIBRARY.cmake
[CMDEF_ADD_EXECUTABLE.cmake]: system_modules/CMDEF_ADD_EXECUTABLE.cmake
[CMDEF_BUILD_TYPE.cmake]: system_modules/CMDEF_BUILD_TYPE.cmake
[CMDEF_COMPILE_DEFINITION.cmake]: system_modules/CMDEF_COMPILE_DEFINITION.cmake
[CMDEF_COMPILE_OPTION.cmake]: system_modules/CMDEF_COMPILE_OPTION.cmake
[CMDEF_ENV.cmake]: system_modules/CMDEF_ENV.cmake
[CMDEF_INSTALL.cmake]: system_modules/CMDEF_INSTALL.cmake
[CMDEF_LINK_OPTION.cmake]: system_modules/CMDEF_LINK_OPTION.cmake
[CMDEF_PACKAGE.cmake]: system_modules/CMDEF_PACKAGE.cmake
[doc/CacheVariables.md]: doc/CacheVariables.md
[doc/README.md]: doc/README.md
[example]: example/

[buildbadge_github]: https://github.com/cmakelib/cmakelib-component-cmdef/actions/workflows/tests.yml/badge.svg