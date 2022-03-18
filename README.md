
# CMake-lib Basedef component

CMake-lib provides consistent setting for built environment.
It simplifies and maintains built option, libraries and executables.

## Requirements

- [CMLIB] library installed 

## General

The library is not mainly intended for extending CMake functionality.

It's set of wrappers and helpers which enables easily use of existing CMake
features.

### Definition of Main target

Each CMake project has one main target - the target for which the project is
created, compiled, ...

For example we have CMake project for building chrome browser.
Browser is represented by one executable called `chrome`. That executable
must have own target in CMake project.

By that target other project properties are referenced - installer name, application name, documentation etc.
We call this type of target as 'main target' (the 'object' for which we
create the CMake project)

In the library the 'main target' is represented by MAIN_TARGET variable/parameter for macros/functions

## Usage

Let GIT_URI be a GIT URI of this repository.

	FIND_PACKAGE(CMLIB COMPONENTS CMDEF)

### Set build defaults

CMake-lib sets and maintains build/link flags and global wide definitions

Component workflow

- reset CMake default build flags by `CMDEF_CLEANUP`
- set default build and link options  by `CMDEF_COMPILE_OPTIONS`, `CMDEF_LINK_OPTIONS`
- set compile definitions by `CMDEF_COMPIE_DEFINITIONS`

examples can be found at [example] directory

## Function list

Each entry in list represents one feature for CMake.

Most of functions are just wrappers which enclosures base feature of
CMake.

Detailed documentation for each function can be found at appropriate module.

- [CMDEF_ADD_LIBRARY.cmake]
- [CMDEF_ADD_EXECUTABLE.cmake]
- [CMDEF_BUILD_TYPE.cmake]
- [CMDEF_COMPILE_DEFINITION.cmake]
- [CMDEF_COMPILE_OPTION.cmake]
- [CMDEF_ENV.cmake]
- [CMDEF_INSTALL.cmake]
- [CMDEF_LINK_OPTION.cmake]
- [CMDEF_PACKAGE.cmake]

## Config Variables

Configuration variables detailed desc. for the library is located at [doc/CacheVariables.md]

## Coding standards

- We use Uppercase for all keywords and global variables
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
[example]: example/
