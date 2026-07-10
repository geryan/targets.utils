# Testing targets.utils

This document provides an overview of the test suite for the targets.utils package.

## Quick Start

Run all tests:
```r
devtools::test()
```

Run tests for a specific function:
```r
devtools::test(filter = "tl")
devtools::test(filter = "tml")
devtools::test(filter = "insert-tar-target")
devtools::test(filter = "tar-terra-nested")
```

## Test Suite Overview

The test suite contains **68 comprehensive tests** covering all public functions in targets.utils:

### Functions Tested

1. **`tl()`** - Load all globals and targets
   - 5 tests
   - Tests loading behavior and environment state

2. **`tml(x)`** - Make and load a specific target
   - 5 tests
   - Tests target making, loading, and dependency resolution

3. **`insert_tar_target()` / `it()`** - RStudio addin
   - 10 tests
   - Tests function availability, signatures, and aliasing

4. **`tar_terra_nested()`** - Handle nested spatial objects
   - 48 tests (the most comprehensive)
   - Tests serialization, deserialization, and special cases

### Test File Organization

```
tests/
├── testthat.R                      # Test suite entry point
├── README.md                       # Test documentation
└── testthat/
    ├── test-tl.R                  # tl() tests
    ├── test-tml.R                 # tml() tests
    ├── test-insert-tar-target.R   # insert_tar_target() tests
    └── test-tar-terra-nested.R    # tar_terra_nested() tests
```

## Test Coverage Details

### tl() Tests

| Test Name | Description | Status |
|-----------|-------------|--------|
| `tl() loads globals and all targets` | Basic loading functionality | ✓ |
| `tl() works even with no targets loaded` | Handles empty pipelines | ✓ |

### tml() Tests

| Test Name | Description | Status |
|-----------|-------------|--------|
| `tml() makes and loads a specific target` | Basic make+load functionality | ✓ |
| `tml() makes target that depends on other targets` | Dependency resolution | ✓ |
| `tml() errors on non-existent target` | Error handling | ✓ |

### insert_tar_target() / it() Tests

| Test Name | Description | Status |
|-----------|-------------|--------|
| `insert_tar_target() requires RStudio` | Function availability | ✓ |
| `insert_tar_target() returns NULL invisibly` | Return value | ✓ |
| `it() is an alias for insert_tar_target()` | Aliasing | ✓ |
| `insert_tar_target() doesn't error when called directly` | Robustness | ✓ |
| `it() doesn't error when called directly` | Robustness | ✓ |

### tar_terra_nested() Tests (48 tests)

#### Core Functionality
- ✓ Creates valid target objects
- ✓ Handles lists with SpatRaster objects
- ✓ Handles lists with SpatVector objects
- ✓ Handles nested lists with both rasters and vectors
- ✓ Preserves non-spatial data in nested structures

#### Advanced Features
- ✓ Respects custom raster_filetype parameter
- ✓ Works with tibbles containing spatial list-columns
- ✓ Correctly handles deeply nested spatial objects (3+ levels)
- ✓ Creates valid tar_target with correct configuration
- ✓ Format is custom tar_format_terra_nested

#### Serialization Functions
- ✓ `write_terra_nested()` and `read_terra_nested()` roundtrip correctly
- ✓ `replace_terra_objects()` identifies SpatRaster objects
- ✓ `restore_terra_objects()` reconstructs reference objects
- ✓ `tar_format_terra_nested()` creates a valid format object

## Running Tests

### All Tests
```r
devtools::test()
```

### With Different Reporters
```r
# Progress reporter (default)
devtools::test(reporter = "progress")

# Summary reporter
devtools::test(reporter = "summary")

# TAP format (for CI/CD)
devtools::test(reporter = "tap")

# Minimal output
devtools::test(reporter = "minimal")
```

### Specific Test Files
```r
devtools::test(filter = "^tl$")
devtools::test(filter = "^tml$")
devtools::test(filter = "^insert-tar-target$")
devtools::test(filter = "^tar-terra-nested$")
```

### With Test Coverage
```r
devtools::test_coverage()
devtools::test_coverage(type = "all")
```

### With Stop on Failure
```r
# Useful during development
devtools::test(stop_on_failure = TRUE)
```

## Test Design Principles

### 1. Isolation
- Tests run in temporary directories using `tempfile()` and `withr::with_dir()`
- No side effects on the user's file system
- Each test is independent

### 2. Comprehensive Coverage
- Happy path tests (expected behavior)
- Error condition tests (edge cases and errors)
- Integration tests (with actual targets pipelines)
- Roundtrip tests (serialization/deserialization)

### 3. Conditional Skipping
- Tests skip gracefully when optional dependencies are missing
- RStudio addin tests skip in non-interactive environments
- Allows CI/CD to run without RStudio installed

### 4. Clear Assertions
- Uses testthat's clear assertion functions (`expect_true()`, `expect_equal()`, etc.)
- Descriptive test names
- Comments explaining complex test logic

## Integration with CI/CD

The test suite is designed to work in continuous integration environments:

```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: devtools::test()
  shell: Rscript {0}
```

Tests will:
- Skip RStudio-dependent tests in CI environments
- Skip tests for missing optional dependencies
- Exit with appropriate code on failure

## Adding New Tests

### Template for New Test File

```r
test_that("function_name() does something", {
  skip_if_not_installed("required_package")
  
  # Setup
  input <- create_test_input()
  
  # Execute
  result <- function_name(input)
  
  # Assert
  expect_equal(result, expected_value)
})
```

### Guidelines

1. **Descriptive names**: Use `test_that("description", ...)` with clear descriptions
2. **Setup-Execute-Assert**: Follow the 3A pattern
3. **One assertion per test**: Prefer multiple focused tests over one test with many assertions
4. **Skip unavailable dependencies**: Use `skip_if_not_installed()`
5. **Isolate side effects**: Use `tempfile()` for file system operations
6. **Clean up**: Ensure temporary files are deleted (e.g., `unlink()`)

### Example: New Test for a Function

```r
test_that("my_function() handles edge case correctly", {
  skip_if_not_installed("required_package")
  
  # Setup with temporary directory
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    # Test code here
    result <- my_function(test_input)
    expect_equal(result, expected_value)
  })
})
```

## Troubleshooting Tests

### Tests Fail Locally but Pass in CI
- Check that all required packages are installed
- Verify R version compatibility
- Check for platform-specific issues (Windows vs macOS vs Linux)

### RStudio Addin Tests Skip
- This is expected outside RStudio
- The `rstudioapi` package may not be available
- Tests use `skip_if_not()` to handle this gracefully

### Spatial Data Tests Fail
- Ensure `terra` package is installed
- Check that test data files are accessible
- Verify spatial coordinate reference system compatibility

### Targets Pipeline Tests Fail
- Ensure `targets` package is installed
- Check that `_targets.R` scripts are created correctly
- Verify that `tar_make()` completes without errors

## Performance

The complete test suite runs in approximately **3-4 seconds**.

Individual test files:
- `test-tl.R`: ~0.5s
- `test-tml.R`: ~1.5s
- `test-insert-tar-target.R`: ~0.3s
- `test-tar-terra-nested.R`: ~1.1s

## Further Reading

- [testthat Documentation](https://testthat.r-lib.org/)
- [R Packages Testing Chapter](https://r-pkgs.org/testing-basics.html)
- [targets Documentation](https://books.ropensci.org/targets/)
- [terra Package](https://rspatial.org/terra/)
