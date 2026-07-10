# Test Suite for targets.utils

This directory contains comprehensive tests for all functions in the targets.utils package, written using the [testthat](https://testthat.r-lib.org/) framework.

## Test Structure

Tests are organized by function in the `testthat/` directory:

### `test-tl.R` - Tests for `tl()` function
- Tests that `tl()` loads all globals and targets from a targets pipeline
- Verifies that globals are available in the global environment
- Tests behavior with minimal pipelines

### `test-tml.R` - Tests for `tml()` function  
- Tests that `tml()` makes and loads a specific target
- Verifies that dependencies are resolved correctly
- Tests error handling for non-existent targets
- Confirms loaded data matches expected values

### `test-insert-tar-target.R` - Tests for `insert_tar_target()` and `it()`
- Verifies both functions exist and have correct signatures
- Tests that they return `NULL` invisibly
- Confirms `it()` is a proper alias for `insert_tar_target()`
- Tests function availability in RStudio environments

### `test-tar-terra-nested.R` - Tests for `tar_terra_nested()` and related functions
This is the most comprehensive test file with 48 tests covering:

#### Core Functionality
- Creating valid target objects with `tar_terra_nested()`
- Handling lists with `SpatRaster` objects
- Handling lists with `SpatVector` objects
- Handling mixed spatial and non-spatial data

#### Advanced Features
- Deeply nested spatial objects (multiple nesting levels)
- Tibbles with spatial list-columns
- Custom file format options (COG, ESRI Shapefile, etc.)
- Preservation of non-spatial data alongside spatial objects

#### Internal Functions
- `write_terra_nested()` and `read_terra_nested()` roundtrip serialization
- `replace_terra_objects()` recursive object replacement
- `restore_terra_objects()` object reconstruction
- Reference object creation and identification

## Running Tests

### Run all tests:
```r
devtools::test()
```

### Run tests for a specific function:
```r
devtools::test(filter = "tl")
devtools::test(filter = "tml")
devtools::test(filter = "insert-tar-target")
devtools::test(filter = "tar-terra-nested")
```

### Run with detailed output:
```r
devtools::test(reporter = "progress")
devtools::test(reporter = "summary")
devtools::test(reporter = "tap")  # TAP format
```

## Test Coverage

The test suite covers:

| Function | Tests | Coverage |
|----------|-------|----------|
| `tl()` | 2 | Loading behavior with/without targets |
| `tml()` | 3 | Making, loading, dependencies, errors |
| `insert_tar_target()` / `it()` | 5 | Existence, signatures, aliasing |
| `tar_terra_nested()` | 48 | Serialization, formats, nested objects |
| **Total** | **58** | Comprehensive |

## Test Dependencies

Tests require the following packages to be installed:

- `testthat` - Testing framework
- `targets` - Targets pipeline framework
- `terra` - Spatial data handling
- `tibble` - For tibble tests
- `withr` - For temporary directory management

Some tests are skipped if these packages are not available.

## Key Testing Patterns

### Temporary Directories
Tests use `tempfile()` and `withr::with_dir()` to run tests in isolated temporary directories, preventing side effects on the user's file system.

### Target Pipeline Setup
Integration tests create minimal `_targets.R` scripts using `targets::tar_script()` and execute pipelines with `targets::tar_make(callr_function = NULL)` to run in-process for better error reporting.

### Spatial Object Verification
Tests verify spatial objects are properly serialized and deserialized by checking:
- Object class inheritance
- Dimensions (for rasters)
- Geometry types (for vectors)
- Metadata preservation

### Roundtrip Testing
Serialization functions are tested with roundtrip patterns: write → read → verify

## Notes on RStudio Addins

Tests for `insert_tar_target()` and `it()` use `skip_if_not()` to handle cases where:
- `rstudioapi` is not installed
- RStudio is not available (tests run in non-interactive mode)
- The addin cannot insert text (e.g., in CI/CD environments)

These tests verify the function structure and behavior without requiring an active RStudio session.

## Continuous Integration

These tests are designed to work in CI/CD pipelines and automatically skip tests for unavailable packages or interactive features.

## Adding New Tests

When adding new tests:

1. Create a new file `test-[function-name].R` in `testthat/`
2. Use clear, descriptive test names with `test_that()`
3. Include `skip_if_not_installed()` for optional dependencies
4. Use `withr::with_dir()` for file system isolation
5. Include both happy path and error condition tests
6. Document any special setup or teardown requirements

Example:
```r
test_that("function_name() does something specific", {
  skip_if_not_installed("required_package")
  
  # Setup
  input <- list(a = 1, b = 2)
  
  # Test
  result <- function_name(input)
  
  # Verify
  expect_equal(result, expected_value)
})
```
