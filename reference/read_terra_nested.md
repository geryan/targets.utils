# Read nested terra objects from a tar archive

Internal function called by the tar_terra_nested format's read method.
Extracts and reconstructs SpatRaster and SpatVector objects from an
archive created by \[write_terra_nested()\]. Files are extracted to a
session-persistent location so that terra's lazy-loading of rasters
works correctly.

## Usage

``` r
read_terra_nested(path)
```

## Arguments

- path:

  Character. Path to the tar archive.

## Value

The reconstructed object with all nested SpatRaster and SpatVector
objects restored from disk files.
