# Create a target for nested objects containing terra objects

\`tar_terra_nested()\` is a target factory for objects that contain
nested \[terra::SpatRaster-class\] or \[terra::SpatVector-class\]
objects but are not themselves top-level terra objects. Examples include
lists, nested lists, tibbles with list-columns, and many ordinary
serialisable R objects.

## Usage

``` r
tar_terra_nested(
  name,
  command,
  pattern = NULL,
  raster_filetype = "GTiff",
  raster_gdal = NULL,
  raster_datatype = NULL,
  vector_filetype = "GPKG",
  vector_gdal = NULL,
  raster_args = list(),
  vector_args = list(),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  repository = targets::tar_option_get("repository"),
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  storage = targets::tar_option_get("storage"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue"),
  description = targets::tar_option_get("description")
)
```

## Arguments

- name:

  Symbol. Name of the target.

- command:

  R code returning an object that may contain nested \`SpatRaster\`
  and/or \`SpatVector\` objects.

- pattern:

  Code to define a dynamic branching pattern. See
  \[targets::tar_target()\].

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

- packages:

  Character vector of packages to load for the target.

- library:

  Character vector of library paths.

- repository:

  Character of length 1. Storage repository for the target.

- error:

  Character of length 1. Error handling strategy.

- memory:

  Character of length 1. Memory strategy.

- garbage_collection:

  Logical. Whether to run garbage collection.

- deployment:

  Character of length 1. Deployment strategy.

- priority:

  Numeric of length 1. Target priority.

- resources:

  Object returned by \[targets::tar_resources()\].

- storage:

  Character of length 1. Storage strategy.

- retrieval:

  Character of length 1. Retrieval strategy.

- cue:

  Object returned by \[targets::tar_cue()\].

- description:

  Character of length 1. Target description.

## Value

A target object for use in a \`targets\` pipeline.
