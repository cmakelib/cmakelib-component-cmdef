# CMDef package chain

CMdef provides chain of functions, that lead to consistent, standardized installing and packaging.

Each function from this chain is independent and can be used separately, 
but using the whole chain provides increased functionality, i.e. checking all dependencies for consistency, 
checking and including all linked CMDEF targets to the package.

The chain is represented by a CMDEF functions called in following oreder

- CMDEF_ADD_{EXECUTABLE|LIBRARY} - defines CMake target. Lets call the target as a TARGET.
- CMDEF_INSTALL - installs target TARGET.
- CMDEF_PACKAGE - creates package. It needs to be called exactly once per project as part of the upper most CMakeLists.

## Function description

### CMDEF_ADD_LIBRARY

Adds a library, links its sources and headers.
The created library name is defined as `LIBRARY_GROUP` name and `TYPE` suffix.

#### Example

```cmake
# This will create target mylib-shared
CMDEF_ADD_LIBRARY(
    LIBRARY_GROUP mylib
    TYPE SHARED
    SOURCES main.cpp
    VERSION 1.0.0
    INCLUDE_DIRECTORIES include/    # This is not required 
)
```

### CMDEF_ADD_EXECUTABLE

Adds an executable, links its sources and headers.

#### Example

```cmake
CMDEF_ADD_EXECUTABLE(
    TARGET myexecutable
    SOURCES main.cpp
    VERSION 1.0.0
)
```

### CMDEF_INSTALL

Configure the installation of a target, that will export it and create the targets `.cmake` file.

`NAMESPACE` is **required** when using the whole chain, and it must be **equal** to name of the **main target**.

#### Example

```cmake
CMDEF_INSTALL(
    TARGET mylib-shared
    NAMESPACE mylib-shared::
)
```

### CMDEF_PACKAGE

Configure packaging of the target. 
The packaging creates `<target>Config.cmake`, `<target>ConfigVersion.cmake`, `cpack` then puts everything into an archive. 

The generated files are needed for finding the package using `FIND_PACKAGE` command, it includes all installed **CMDEF** targets into the package.

#### Example

```cmake
CMDEF_PACKAGE(
    MAIN_TARGET mylib-shared
    VERSION "1.0.0"
)

SET(CPACK_GENERATOR ZIP) # This can be any generator
INCLUDE(CPack)
```

## Package usage

### Example

For this example, we will use all previous snippets and add the following to also install myexecutable.

```cmake
CMDEF_INSTALL(
    TARGET myexecutable
    NAMESPACE mylib-shared::
)
TARGET_LINK_LIBRARIES(myexecutable PUBLIC mylib-shared)

```

### Build & Install the package

```bash
mkdir _build && cd _build   # Called in root directory of project
cmake -CMAKE_INSTALL_PREFIX=<install_path> ..
make          # Build mylib-shared.so and myexecutable
make install  # Install cmake files, mylib-shared.so and myexecutable to <install_path>
cpack         # Create archive libmylib-shared-dev_1.0.0_<architecture>.zip
```

> Note that when `CMAKE_BUILD_TYPE=Debug`, the libraries and executables **OUTPUT_NAME** will have a suffix `d` added to them.

The created package have the following structure:

```
<install_path>
├── bin
│   └── myexecutable
├── include
│   ├── mylib_header.h
└── lib
    ├── cmake
    │   └── mylib-shared
    │       ├── mylib-shared.cmake
    │       ├── mylib-sharedConfig.cmake
    │       ├── mylib-sharedConfigVersion.cmake
    │       ├── myexecutable.cmake
    └── libmylib-shared.so
```

### Using the package in different project

Now the package can be used in other projects.

Add the following lines to the `CMakeLists.txt` file:

```cmake
FIND_PACKAGE(mylib-shared)
TARGET_LINK_LIBRARIES(<target> PUBLIC mylib-shared::mylib-shared)
```

Configure the project with CMake option `CMAKE_PREFIX_PATH=<install_path>`.
