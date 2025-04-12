# CMDEF_PACKAGE Tests

## Test Strategy

- Test all CPACK affected variables
- Test all propoerties and custom targets created
- Test all generated, cmake package files
- Test all error conditions - invalid parametr combination, invalid target combinations etc.

## Test Cases

Each test case is independent and tests one specific aspect of CMDEF_PACKAGE:

1. **executable** - Executable packaging with config file generation
2. **{static,shared,interface}_lib** - library packaging with dev suffix verification
5. **with_configs** - CONFIGURATIONS parameter verification
6. **with_cpack_config** - Custom CPACK_CONFIG_FILE parameter verification
7. **multiconfig_build** - ADD_CUSTOM_TARGET creation for multiconfig builds for PACKAGE creation.
8. **dependency_inclusion** - Dependency finding and namespace verification
9. **invalid_arguments** - Invalid argument handling and error messages

# Run Test

All commands are run inside of test/CMDEF_PACKAGE.

Run tests
```bash
cmake .
```

To clean up
```bash
git clean -xfd .
```