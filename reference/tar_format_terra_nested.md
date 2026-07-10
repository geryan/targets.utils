# Create a custom targets format for nested terra objects

This format recursively searches an R object for nested
\[terra::SpatRaster-class\] and \[terra::SpatVector-class\] objects.

## Usage

``` r
tar_format_terra_nested(
  raster_filetype = "GTiff",
  raster_gdal = NULL,
  raster_datatype = NULL,
  vector_filetype = "GPKG",
  vector_gdal = NULL,
  raster_args = list(),
  vector_args = list()
)
```

## Arguments

- raster_filetype:

  Character of length 1. GDAL raster driver passed to
  \[terra::writeRaster()\]. Defaults to \`"GTiff"\`.

- raster_gdal:

  Character vector or \`NULL\`. GDAL raster creation options passed to
  \[terra::writeRaster()\] through the \`gdal\` argument.

- raster_datatype:

  Character of length 1 or \`NULL\`. Optional datatype passed to
  \[terra::writeRaster()\].

- vector_filetype:

  Character of length 1. GDAL vector driver passed to
  \[terra::writeVector()\]. Defaults to \`"GPKG"\`.

- vector_gdal:

  Character vector or \`NULL\`. GDAL vector creation options passed to
  \[terra::writeVector()\] through the \`options\` argument.

- raster_args:

  Named list of additional arguments passed to \[terra::writeRaster()\].

- vector_args:

  Named list of additional arguments passed to \[terra::writeVector()\].

## Value

A custom target format object from \[targets::tar_format()\].
