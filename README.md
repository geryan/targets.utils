
<!-- README.md is generated from README.Rmd. Please edit that file -->

# targets.utils

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/geryan/targets.utils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/geryan/targets.utils/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/geryan/targets.utils/branch/main/graph/badge.svg)](https://app.codecov.io/gh/geryan/targets.utils?branch=main)

<!-- badges: end -->

A haphazard collection of wildly different utilities with no common
theme but for working with `targets` pipelines. Or as the AI puts it:

A collection of utility functions for interactively working with
[targets](https://books.ropensci.org/targets/) pipelines. These
functions streamline common workflows like loading target outputs,
running specific targets, and handling spatial data.

## Install me

You can install the ~~development~~ *only* version — I’m not dealing
with putting this on fucking cran — of `targets.utils` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("geryan/targets.utils")
```

## Such `<- fun(){}`

**I am a lazy person who doesn’t like the drudgery of typing**

- `tg()`: why bother with `tar_load_globals`?
- `te()`: why bother with `tar_load_everything`?
- `tl()`: why bother with `tar_load_globals` `tar_load_everything`?
- `tml(x)`: why bother with `tar_make(x)` `tar_load(x)`
- `insert_tar_target()`: why bother with
  `tar_target(name = , commmand = )`. WTF that’s barely any shorter?

**Is this the Pompidou? I am lost in the pipeline**

- `tar_upstream(x)`: Find what targets a target depends on
- `tar_downstream(x)`: Find what targets depend on a target

**My data structures are overcomplicated and fussy: spatial edition**

- `tar_terra_nested()`: Create a target with nested spatial `terra`
  objects

## I am a lazy person who doesn’t like the drudgery of typing

### Loading everything with `tl()`

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

The `insert_tar_target()` function is an RStudio addin that inserts a
`tar_target()` skeleton at your cursor:

You really don’t want to type this yourself — sorta defeats the purpose
eh.

You *can* use the Addins menu:

Addins \> Insert tar_target

But this is also tedious.

The main point is to bind it to a shortcut key, e.g. `Cmd + t`, and
**blammo**, target skeleton inserted into your list and onward and
upward:

Tools \> Modify Keyboard Shortcuts

Find Insert tar_target, specify your preferred hotkey and apply away.

This functionality inspired with much admiration by [Mile’s McBain’s
`fnmate` package](https://github.com/MilesMcBain/fnmate)

Inserts:

``` r
tar_target(
   name = ,
   command = 
 ),
```

Note that there is a comma `,` at the end of the skeleton — it is the
author’s strong opinion born of experience that most new targets are
intra-list and therefore this saves user the drudgery of going **all the
way** to the end of the skeleton to insert one and then return to adding
whatever the were going to add; if indeed humans still add code by hand
in the foul year of our lord 20-whatever-this-is.

So:

``` r
tar_script({
  list(
    tar_target(name = raw_data, command = read.csv("data.csv")),
    
    # Position cursor here and slam shortcut key to insert the next target skeleton
    
    tar_target(name = next_data, command = read.csv("next_data.csv"))
  )
})
```

## Is this the Pompidou? I am lost in the pipeline

Navigate your pipeline dependencies with `tar_downstream()` and
`tar_upstream()`

``` r
# See what depends on the 'raw_data' target
tar_downstream(raw_data)
# [1] "processed_data" "summary_stats" "final_model" ...

# See only direct dependents (immediate = TRUE)
tar_downstream(raw_data, immediate = TRUE)
# [1] "processed_data" "summary_stats"

# See what 'final_model' depends on
tar_upstream(final_model)
# [1] "raw_data" "processed_data" "model_config"

# See only direct dependencies
tar_upstream(final_model, immediate = TRUE)
# [1] "processed_data" "model_config"

# Useful for understanding impact of changes and tracing dependencies
```

## My data structures are overcomplicated and fussy: spatial edition

Handling nested spatial data with `tar_terra_nested()`

The fucking excellent [`geotargets`
package](https://docs.ropensci.org/geotargets/index.html) handles
`terra::SpatRaster` and `terra::SpatVector` objects, but chokes on lists
containing nested spatial objects. `tar_terra_nested()` fills that gap
by recursively finding and managing nested spatial formats buried inside
arbitrary R objects. How recursive? How arbitrary? Try me. I’ll probably
break.

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
#> ✔ ended pipeline [214ms, 1 completed, 0 skipped]
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
cannot serialize `terra::SpatRaster` or `terra::SpatVector` objects. The
`geotargets` package solves this for top-level spatial objects with
custom formats that write to GeoTIFF and GeoPackage.

But `geotargets` can’t handle objects that *contain* nested spatial
formats, such as:

- Lists with spatial elements
- Data frames with spatial list-columns  
- Nested lists mixing spatial and non-spatial data
- S4 objects with spatial slot data

`tar_terra_nested()` works by:

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

AI did much of this donkeywork so it will probably break. Trust it at
your own peril.

### Example: Nested spatial data in a tibble

You can even use `tar_terra_nested()` with tibbles containing spatial
list-columns:

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
