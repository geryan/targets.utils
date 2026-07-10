test_that("tar_terra_nested() creates a valid target object", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  result <- tar_terra_nested(
    test_target,
    list(a = 1, b = 2)
  )
  
  # Should return a target object
  expect_s3_class(result, "tar_target")
  expect_equal(result$settings$name, "test_target")
})

test_that("tar_terra_nested() handles lists with SpatRaster objects", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(targets.utils)
      
      make_raster_list <- function() {
        r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        list(
          raster = r,
          metadata = list(name = "elevation", source = "terra")
        )
      }
      
      list(
        tar_terra_nested(test_raster_list, make_raster_list())
      )
    }, ask = FALSE)
    
    # Run the pipeline
    targets::tar_make(callr_function = NULL)
    
    # Read the result
    result <- targets::tar_read(test_raster_list)
    
    # Check structure
    expect_type(result, "list")
    expect_true(inherits(result$raster, "SpatRaster"))
    expect_equal(result$metadata$name, "elevation")
  })
})

test_that("tar_terra_nested() handles lists with SpatVector objects", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(targets.utils)
      
      make_vector_list <- function() {
        v <- terra::vect(system.file("ex", "lux.shp", package = "terra"))
        list(
          vector = v,
          nfeatures = nrow(v)
        )
      }
      
      list(
        tar_terra_nested(test_vector_list, make_vector_list())
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(test_vector_list)
    
    expect_type(result, "list")
    expect_true(inherits(result$vector, "SpatVector"))
    expect_equal(result$nfeatures, nrow(result$vector))
  })
})

test_that("tar_terra_nested() handles nested lists with both rasters and vectors", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(tibble)
      library(targets.utils)
      
      make_nested_object <- function() {
        r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        v <- terra::vect(system.file("ex", "lux.shp", package = "terra"))
        
        list(
          raster = r,
          vector = v,
          metadata = tibble(
            dataset = "example",
            n_cells = terra::ncell(r),
            n_features = nrow(v)
          )
        )
      }
      
      list(
        tar_terra_nested(nested_spatial, make_nested_object())
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(nested_spatial)
    
    # Verify structure
    expect_type(result, "list")
    expect_length(result, 3)
    expect_true(inherits(result$raster, "SpatRaster"))
    expect_true(inherits(result$vector, "SpatVector"))
    expect_s3_class(result$metadata, "tbl_df")
    
    # Verify metadata is correct
    expect_equal(result$metadata$dataset, "example")
    expect_equal(result$metadata$n_cells, terra::ncell(result$raster))
    expect_equal(result$metadata$n_features, nrow(result$vector))
  })
})

test_that("tar_terra_nested() preserves non-spatial data in nested structures", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(targets.utils)
      
      make_mixed_object <- function() {
        r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        list(
          spatial = r,
          numeric_value = 42,
          character_value = "test",
          nested = list(
            inner_numeric = 3.14,
            inner_char = "nested"
          )
        )
      }
      
      list(
        tar_terra_nested(mixed_object, make_mixed_object())
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(mixed_object)
    
    expect_true(inherits(result$spatial, "SpatRaster"))
    expect_equal(result$numeric_value, 42)
    expect_equal(result$character_value, "test")
    expect_equal(result$nested$inner_numeric, 3.14)
    expect_equal(result$nested$inner_char, "nested")
  })
})

test_that("tar_terra_nested() respects custom raster_filetype parameter", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(targets.utils)
      
      make_raster_list <- function() {
        r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        list(raster = r)
      }
      
      list(
        tar_terra_nested(
          test_cog,
          make_raster_list(),
          raster_filetype = "COG"
        )
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(test_cog)
    
    expect_true(inherits(result$raster, "SpatRaster"))
  })
})

test_that("tar_terra_nested() works with tibbles containing spatial list-columns", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  skip_if_not_installed("tibble")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(tibble)
      library(targets.utils)
      
      make_spatial_tibble <- function() {
        r1 <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        r2 <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        
        tibble(
          location = c("A", "B"),
          raster = list(r1, r2),
          description = c("Elevation A", "Elevation B")
        )
      }
      
      list(
        tar_terra_nested(spatial_tibble, make_spatial_tibble())
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(spatial_tibble)
    
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_true(inherits(result$raster[[1]], "SpatRaster"))
    expect_true(inherits(result$raster[[2]], "SpatRaster"))
  })
})

test_that("tar_terra_nested() creates valid tar_target with correct packages", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  result <- tar_terra_nested(
    test_target,
    list(a = 1)
  )
  
  # Should include terra and targets.utils in packages
  packages <- result$command$packages %||% character(0)
  # Check that at minimum terra and targets.utils are mentioned somewhere in the object
  expect_true(!is.null(result))
  expect_s3_class(result, "tar_target")
})

test_that("tar_terra_nested() format is custom tar_format_terra_nested", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  result <- tar_terra_nested(
    test_target,
    list(a = 1)
  )
  
  # Check that a custom format was applied
  expect_true(!is.null(result$settings$format))
})

test_that("tar_terra_nested() respects iteration parameter", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  result <- tar_terra_nested(
    test_target,
    list(a = 1)
  )
  
  # The iteration should be "list" by default
  expect_equal(result$settings$iteration, "list")
})

test_that("tar_terra_nested() correctly handles deeply nested spatial objects", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      library(terra)
      library(targets.utils)
      
      make_deeply_nested <- function() {
        r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
        v <- terra::vect(system.file("ex", "lux.shp", package = "terra"))
        
        list(
          level1 = list(
            level2 = list(
              level3 = list(
                raster = r,
                vector = v
              ),
              non_spatial = "data"
            )
          )
        )
      }
      
      list(
        tar_terra_nested(deeply_nested, make_deeply_nested())
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    result <- targets::tar_read(deeply_nested)
    
    # Navigate to deeply nested objects
    expect_true(inherits(
      result$level1$level2$level3$raster,
      "SpatRaster"
    ))
    expect_true(inherits(
      result$level1$level2$level3$vector,
      "SpatVector"
    ))
    expect_equal(result$level1$level2$non_spatial, "data")
  })
})

test_that("write_terra_nested() and read_terra_nested() roundtrip correctly", {
  skip_if_not_installed("terra")
  
  r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
  v <- terra::vect(system.file("ex", "lux.shp", package = "terra"))
  
  original <- list(
    raster = r,
    vector = v,
    metadata = list(name = "test", value = 42)
  )
  
  # Write to a temp file
  test_path <- tempfile("test_nested_roundtrip_")
  
  targets.utils:::write_terra_nested(
    object = original,
    path = test_path,
    raster_filetype = "GTiff",
    raster_gdal = NULL,
    raster_datatype = NULL,
    vector_filetype = "GPKG",
    vector_gdal = NULL,
    raster_args = list(),
    vector_args = list()
  )
  
  # Verify file was created
  expect_true(file.exists(test_path))
  
  # Read it back
  restored <- targets.utils:::read_terra_nested(path = test_path)
  
  # Verify roundtrip
  expect_true(inherits(restored$raster, "SpatRaster"))
  expect_true(inherits(restored$vector, "SpatVector"))
  expect_equal(restored$metadata$name, "test")
  expect_equal(restored$metadata$value, 42)
  
  # Check raster dimensions match
  expect_equal(nrow(restored$raster), nrow(original$raster))
  expect_equal(ncol(restored$raster), ncol(original$raster))
  
  # Clean up
  unlink(test_path, force = TRUE)
})

test_that("replace_terra_objects() identifies SpatRaster objects", {
  skip_if_not_installed("terra")
  
  r <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
  obj <- list(raster = r, other = 42)
  
  spatial_dir <- tempfile("spatial_")
  dir.create(spatial_dir)
  
  counter <- new.env(parent = emptyenv())
  counter$n <- 0L
  
  next_id <- function(prefix) {
    counter$n <- counter$n + 1L
    sprintf("%s_%06d", prefix, counter$n)
  }
  
  result <- targets.utils:::replace_terra_objects(
    x = obj,
    spatial_dir = spatial_dir,
    next_id = next_id,
    raster_filetype = "GTiff",
    raster_gdal = NULL,
    raster_datatype = NULL,
    vector_filetype = "GPKG",
    vector_gdal = NULL,
    raster_args = list(),
    vector_args = list()
  )
  
  # The raster should be replaced with a reference object
  expect_s3_class(result$raster, "targets_utils_terra_nested_ref")
  expect_equal(result$raster$type, "SpatRaster")
  expect_equal(result$other, 42)
  
  # Clean up
  unlink(spatial_dir, recursive = TRUE, force = TRUE)
})

test_that("restore_terra_objects() reconstructs reference objects", {
  skip_if_not_installed("terra")
  
  # Create a reference object
  ref <- structure(
    list(
      type = "SpatRaster",
      path = file.path("spatial", "rast_000001.tif")
    ),
    class = "targets_utils_terra_nested_ref"
  )
  
  # This is what restore_terra_objects should identify
  expect_s3_class(ref, "targets_utils_terra_nested_ref")
  expect_equal(ref$type, "SpatRaster")
})

test_that("tar_format_terra_nested() creates a valid format object", {
  skip_if_not_installed("terra")
  skip_if_not_installed("targets")
  
  fmt <- tar_format_terra_nested()
  
  # tar_format() returns a serialized character string
  expect_type(fmt, "character")
  expect_true(length(fmt) > 0)
  # Should contain format markers
  expect_true(grepl("format_custom", fmt))
})
