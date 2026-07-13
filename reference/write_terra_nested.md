# Write nested terra objects to a tar archive

Internal function called by the tar_terra_nested format's write method.
Recursively finds and serializes SpatRaster and SpatVector objects
within an arbitrary R structure, archiving them and a skeleton
representation of the original object.

## Usage

``` r
write_terra_nested(
  object,
  path,
  raster_filetype,
  raster_gdal,
  raster_datatype,
  vector_filetype,
  vector_gdal,
  raster_args,
  vector_args
)
```

## Arguments

- object:

  An R object that may contain nested terra objects.

- path:

  Character. Path to write the tar archive to.

- raster_filetype:

  Character. GDAL raster driver.

- raster_gdal:

  Character vector or NULL. GDAL raster options.

- raster_datatype:

  Character or NULL. Raster datatype.

- vector_filetype:

  Character. GDAL vector driver.

- vector_gdal:

  Character vector or NULL. GDAL vector options.

- raster_args:

  Named list of additional terra::writeRaster() arguments.

- vector_args:

  Named list of additional terra::writeVector() arguments.

## Value

Invisibly returns the path to the written archive.
