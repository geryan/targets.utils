# targets.utils

A collection of utility functions for interactively working with
[targets](https://books.ropensci.org/targets/) pipelines. These
functions streamline common workflows like loading target outputs,
running specific targets, and handling spatial data.

## Installation

You can install the development version of targets.utils from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("geryan/targets.utils")
```

## Quick Start: Interactive Utilities

These functions make interactive work with targets pipelines faster:

- **[`tl()`](https://geryan.github.io/targets.utils/reference/tl.md)**:
  Load all globals and targets with a single command
- **`tml(x)`**: Make and load a specific target in one call
- **[`insert_tar_target()`](https://geryan.github.io/targets.utils/reference/insert_tar_target.md)**:
  RStudio addin to insert target skeletons

### Loading targets interactively with `tl()`

``` r

# After running tar_make(), load everything at once:
tl()

# Equivalent to running:
targets::tar_load_globals(envir = .GlobalEnv)
targets::tar_load_everything(envir = .GlobalEnv)
```

### Make and load a single target with `tml()`

``` r

# Make and immediately load the 'processed_data' target
tml(processed_data)

# Equivalent to:
targets::tar_make(processed_data)
targets::tar_load(names = processed_data, envir = .GlobalEnv)
```

### Insert tar_target skeletons in RStudio

The
[`insert_tar_target()`](https://geryan.github.io/targets.utils/reference/insert_tar_target.md)
function is an RStudio addin that inserts a
[`tar_target()`](https://docs.ropensci.org/targets/reference/tar_target.html)
skeleton at your cursor:

You really never want to type this youself — sorta defeats the purpose.

You *can* use the Addins menu:

Addins \> Insert tar_target

But this is also tedious.

The main point is to bind it to a shortcut key, e.g. Cmd+t, and blammo,
target skeleton inserted into your list and onward and upward:

Tools \> Modify Keyboard Shortcuts

Find Insert `tar_target`, specify your preferred hotkey and apply away.

This functionality inspired with much admiration by [Mile’s McBain’s
`fnmate` package](https://github.com/MilesMcBain/fnmate)

Inserts:

``` r
tar_target(
   name = ,
   command = 
 ),
```

This is especially useful when building target lists:

``` r

tar_script({
  list(
    tar_target(name = raw_data, command = read.csv("data.csv")),
    # Position cursor here and run it() to insert the next target skeleton
  )
})
```

## Handling nested spatial data with `tar_terra_nested()`

The [`geotargets`
package](https://docs.ropensci.org/geotargets/index.html) handles
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
and
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
objects, but cannot serialize lists containing nested spatial objects.
[`tar_terra_nested()`](https://geryan.github.io/targets.utils/reference/tar_terra_nested.md)
fills this gap by recursively discovering and managing nested spatial
formats within arbitrary R objects.

### Example: Nested spatial data in a list

``` r

library(targets)

tar_dir({

  # tar_dir() runs code from a temporary directory.

  tar_script({

    library(targets)
    library(geotargets)
    library(terra)
    library(tibble)
    library(targets.utils)

    # Create a function that produces a nested object with spatial data
    make_nested_object <- function() {

      r <- terra::rast(
        system.file("ex", "elev.tif", package = "terra")
      )

      v <- terra::vect(
        system.file("ex", "lux.shp", package = "terra")
      )

      # Return a list with nested SpatRaster and SpatVector objects
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
      # Use tar_terra_nested() just like tar_target() to handle the list
      tar_terra_nested(
        nested_spatial,
        make_nested_object()
      )
    )
  })

  tar_make()

  # Load and inspect the nested spatial object
  x <- tar_read(nested_spatial)
  x

})
#> terra 1.9.38
#> + nested_spatial dispatched
#> ✔ nested_spatial completed [12ms, 46.45 kB]
#> ✔ ended pipeline [222ms, 1 completed, 0 skipped]
#> $raster
#> class       : SpatRaster
#> size        : 90, 95, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 5.741667, 6.533333, 49.44167, 50.19167  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> source      : rast_000001.tif
#> name        : elevation
#> min value   :       141
#> max value   :       547
#> 
#> $vector
#> class       : SpatVector
#> geometry    : polygons
#> dimensions  : 12, 6  (geometries, attributes)
#> extent      : 5.74414, 6.528252, 49.44781, 50.18162  (xmin, xmax, ymin, ymax)
#> source      : vect_000002.gpkg
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> names       :  ID_1   NAME_1  ID_2   NAME_2  AREA   POP
#> type        : <num>    <chr> <num>    <chr> <num> <num>
#> values      :     1 Diekirch     1 Clervaux   312 18081
#>                   1 Diekirch     2 Diekirch   218 32543
#>                   1 Diekirch     3  Redange   259 18664
#>               ...
#> 
#> $metadata
#> # A tibble: 1 × 3
#>   dataset n_cells n_features
#> * <chr>     <dbl>      <dbl>
#> 1 example    8550         12
```

### Why `tar_terra_nested()`?

The `targets` package stores objects as RDS files by default, which
cannot serialize
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
or
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
objects. The `geotargets` package solves this for top-level spatial
objects using custom formats that write to GeoTIFF and GeoPackage files.

However, `geotargets` cannot handle objects that *contain* nested
spatial formats, such as:

- Lists with spatial elements
- Data frames with spatial list-columns  
- Nested lists mixing spatial and non-spatial data
- S4 objects with spatial slot data

[`tar_terra_nested()`](https://geryan.github.io/targets.utils/reference/tar_terra_nested.md)
works by:

1.  **Recursively scanning** your object for all `SpatRaster` and
    `SpatVector` objects
2.  **Writing each** to individual files (GeoTIFF for rasters,
    GeoPackage for vectors)
3.  **Replacing them** with lightweight reference objects in a skeleton
4.  **Compressing** the skeleton + spatial files into a single `.tar.gz`
    archive
5.  **Reconstructing** the object by restoring spatial files on read

### Advanced: Custom file formats and options

You can customize how spatial data is written:

``` r

tar_script({
  list(
    tar_terra_nested(
      my_target,
      make_complex_nested_object(),
      # Use Cloud-Optimized GeoTIFF for rasters
      raster_filetype = "COG",
      # Custom raster creation options
      raster_gdal = c("COMPRESS=DEFLATE", "PREDICTOR=2"),
      # Use shapefile instead of GeoPackage for vectors
      vector_filetype = "ESRI SHAPEFILE",
      # Pass additional options to terra functions
      raster_args = list(NAflag = -9999),
      vector_args = list(layer = "myshapes")
    )
  )
})
```

### Example: Nested spatial data in a tibble

You can even use
[`tar_terra_nested()`](https://geryan.github.io/targets.utils/reference/tar_terra_nested.md)
with tibbles containing spatial list-columns:

``` r

tar_script({
  library(targets)
  library(terra)
  library(tibble)
  library(targets.utils)

  make_spatial_tibble <- function() {
    r1 <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
    r2 <- terra::rast(system.file("ex", "elev.tif", package = "terra"))
    
    tibble(
      id = c("location_a", "location_b"),
      raster = list(r1, r2),
      description = c("Elevation at A", "Elevation at B")
    )
  }

  list(
    tar_terra_nested(
      spatial_tibble,
      make_spatial_tibble()
    )
  )
})
```

## Example analytical workflow

Here’s a toy example combining multiple targets.utils functions:

``` r

tar_script({
  library(targets)
  library(targets.utils)
  library(terra)
  library(tibble)

  # A helper function that produces nested spatial data
  process_spatial_data <- function(raster_file, vector_file) {
    list(
      raster = terra::rast(raster_file),
      vector = terra::vect(vector_file),
      processing_date = Sys.Date()
    )
  }

  list(
    # Load raw data
    tar_target(
      raw_spatial,
      process_spatial_data(
        system.file("ex", "elev.tif", package = "terra"),
        system.file("ex", "lux.shp", package = "terra")
      ),
      # Use tar_terra_nested to handle the nested list
      format = "custom_format"
    ),
    
    # Use it() here to insert the next target skeleton
    # Cursor position + it() generates: tar_target(name = , command = ),
  )
})
```

Then interactively:

``` r

# After editing your _targets.R:
tml(raw_spatial)  # Make and load raw_spatial target

# Inspect the loaded data
str(raw_spatial)

# When done with all targets:
tl()  # Load everything into your session
```
