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

### `test-tar_downstream.R` - Tests for `tar_downstream()` function
Integration tests using real target pipelines with 20 tests covering:

#### Core Functionality
- Finding all downstream targets in linear dependency chains
- Handling branching pipelines with multiple parallel paths
- Complex dependency trees with multiple levels
- Error handling for nonexistent targets

#### Advanced Features
- `immediate = TRUE` argument for first-degree dependencies only
- Symbol and character input handling
- Combining with actual spatial pipelines (terra/geotargets)

#### Testing Patterns
- Uses `tar_dir()` and `tar_script()` to create real pipelines
- Executes with `tar_make(callr_function = NULL)` for in-process execution
- Validates dependency graph traversal with real target networks

### `test-tar_upstream.R` - Tests for `tar_upstream()` function
Integration tests using real target pipelines with 22 tests covering:

#### Core Functionality
- Finding all upstream targets (dependencies) in linear chains
- Handling branching where one target has multiple dependencies
- Complex dependency trees from the opposite direction
- Error handling for nonexistent targets

#### Advanced Features
- `immediate = TRUE` argument for direct dependencies only
- Relationship testing: `tar_upstream()` and `tar_downstream()` as inverses
- Symbol and character input handling
- Complex real-world pipeline scenarios

#### Testing Patterns
- Mirrors `tar_downstream()` test structure for consistency
- Uses actual target pipelines with real dependencies
- Tests both complete transitive closure and immediate dependencies

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
devtools::test(filter = "tar_downstream")
devtools::test(filter = "tar_upstream")
devtools::test(filter = "tar_downstream|tar_upstream")  # Both together
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
| `tar_downstream()` | 20 | Linear chains, branching, immediate mode |
| `tar_upstream()` | 22 | Upstream chains, immediate mode, inverses |
| **Total** | **100** | Comprehensive integration testing |

## Test Dependencies

Tests require the following packages to be installed:

- `testthat` - Testing framework
- `targets` - Targets pipeline framework
- `terra` - Spatial data handling (for spatial tests)
- `tibble` - For tibble tests
- `withr` - For temporary directory management
- `igraph` - For tar_downstream/tar_upstream tests

Some tests are skipped if these packages are not available using `skip_if_not_installed()`.

## Key Testing Patterns

### Temporary Directories
Tests use `tempfile()`, `withr::with_dir()`, and `targets::tar_dir()` to run tests in isolated temporary directories, preventing side effects on the user's file system.

### Target Pipeline Setup
Integration tests create minimal `_targets.R` scripts using `targets::tar_script()` and execute pipelines with `targets::tar_make(callr_function = NULL)` to run in-process for better error reporting. This pattern is especially important for `tar_downstream()` and `tar_upstream()` tests which require real pipeline networks.

### Spatial Object Verification
Tests verify spatial objects are properly serialized and deserialized by checking:
- Object class inheritance
- Dimensions (for rasters)
- Geometry types (for vectors)
- Metadata preservation

### Roundtrip Testing
Serialization functions are tested with roundtrip patterns: write → read → verify

### Dependency Graph Testing
`tar_downstream()` and `tar_upstream()` tests use real target pipelines to validate dependency graph traversal:
- Create actual target definitions with true dependencies
- Execute `tar_make()` to build the real network metadata
- Test graph traversal on live pipeline networks
- Validate both transitive (all dependencies) and immediate (direct only) modes

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
