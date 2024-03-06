# CMDef package chain

CMdef provides chain of functions, that lead to standardized installing and packaging.
Each function from this chain is independent and can be used separately, but using the whole chain provides increased functionality.

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
)
```

### CMDEF_ADD_EXECUTABLE

Adds an executable, links its sources and headers.

#### Example

```cmake
CMDEF_ADD_EXECUTABLE(
	TARGET executable
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
The packaging creates `<target>Config.cmake`, `<target>ConfigVersion.cmake` and puts everything into an archive. 

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
