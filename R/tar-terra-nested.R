#' Create a custom targets format for nested terra objects
#'
#' This format recursively searches an R object for nested
#' [terra::SpatRaster-class] and [terra::SpatVector-class] objects.
#'
#' @param raster_filetype Character of length 1. GDAL raster driver passed to
#'   [terra::writeRaster()]. Defaults to `"GTiff"`.
#' @param raster_gdal Character vector or `NULL`. GDAL raster creation options
#'   passed to [terra::writeRaster()] through the `gdal` argument.
#' @param raster_datatype Character of length 1 or `NULL`. Optional datatype
#'   passed to [terra::writeRaster()].
#' @param vector_filetype Character of length 1. GDAL vector driver passed to
#'   [terra::writeVector()]. Defaults to `"GPKG"`.
#' @param vector_gdal Character vector or `NULL`. GDAL vector creation options
#'   passed to [terra::writeVector()] through the `options` argument.
#' @param raster_args Named list of additional arguments passed to
#'   [terra::writeRaster()].
#' @param vector_args Named list of additional arguments passed to
#'   [terra::writeVector()].
#'
#' @return A custom target format object from [targets::tar_format()].
#'
#' @export
tar_format_terra_nested <- function(
    raster_filetype = "GTiff",
    raster_gdal = NULL,
    raster_datatype = NULL,
    vector_filetype = "GPKG",
    vector_gdal = NULL,
    raster_args = list(),
    vector_args = list()
) {
  targets::tar_format(
    write = function(object, path) {
      write_fun <- utils::getFromNamespace(
        x = "write_terra_nested",
        ns = "targets.utils"
      )

      write_fun(
        object = object,
        path = path,
        raster_filetype = TARGETS_UTILS_RASTER_FILETYPE,
        raster_gdal = TARGETS_UTILS_RASTER_GDAL,
        raster_datatype = TARGETS_UTILS_RASTER_DATATYPE,
        vector_filetype = TARGETS_UTILS_VECTOR_FILETYPE,
        vector_gdal = TARGETS_UTILS_VECTOR_GDAL,
        raster_args = TARGETS_UTILS_RASTER_ARGS,
        vector_args = TARGETS_UTILS_VECTOR_ARGS
      )
    },
    read = function(path) {
      read_fun <- utils::getFromNamespace(
        x = "read_terra_nested",
        ns = "targets.utils"
      )

      read_fun(path = path)
    },
    substitute = list(
      TARGETS_UTILS_RASTER_FILETYPE = raster_filetype,
      TARGETS_UTILS_RASTER_GDAL = raster_gdal,
      TARGETS_UTILS_RASTER_DATATYPE = raster_datatype,
      TARGETS_UTILS_VECTOR_FILETYPE = vector_filetype,
      TARGETS_UTILS_VECTOR_GDAL = vector_gdal,
      TARGETS_UTILS_RASTER_ARGS = raster_args,
      TARGETS_UTILS_VECTOR_ARGS = vector_args
    )
  )
}


#' Create a target for nested objects containing terra objects
#'
#' `tar_terra_nested()` is a target factory for objects that contain nested
#' [terra::SpatRaster-class] or [terra::SpatVector-class] objects but are not
#' themselves top-level terra objects. Examples include lists, nested lists,
#' tibbles with list-columns, and many ordinary serialisable R objects.
#'
#' @param name Symbol. Name of the target.
#' @param command R code returning an object that may contain nested
#'   `SpatRaster` and/or `SpatVector` objects.
#' @param pattern Code to define a dynamic branching pattern. See
#'   [targets::tar_target()].
#' @inheritParams tar_format_terra_nested
#' @param packages Character vector of packages to load for the target.
#' @param library Character vector of library paths.
#' @param repository Character of length 1. Storage repository for the target.
#' @param error Character of length 1. Error handling strategy.
#' @param memory Character of length 1. Memory strategy.
#' @param garbage_collection Logical. Whether to run garbage collection.
#' @param deployment Character of length 1. Deployment strategy.
#' @param priority Numeric of length 1. Target priority.
#' @param resources Object returned by [targets::tar_resources()].
#' @param storage Character of length 1. Storage strategy.
#' @param retrieval Character of length 1. Retrieval strategy.
#' @param cue Object returned by [targets::tar_cue()].
#' @param description Character of length 1. Target description.
#'
#' @return A target object for use in a `targets` pipeline.
#'
#' @export
tar_terra_nested <- function(
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
) {
  name_expr <- substitute(name)
  command_expr <- substitute(command)
  pattern_expr <- substitute(pattern)

  if (!is.symbol(name_expr)) {
    stop("`name` must be an unquoted target name.", call. = FALSE)
  }

  if (identical(pattern_expr, quote(NULL))) {
    pattern_expr <- NULL
  }

  targets::tar_target_raw(
    name = as.character(name_expr),
    command = command_expr,
    pattern = pattern_expr,
    packages = unique(c(packages, "terra", "targets.utils")),
    library = library,
    format = tar_format_terra_nested(
      raster_filetype = raster_filetype,
      raster_gdal = raster_gdal,
      raster_datatype = raster_datatype,
      vector_filetype = vector_filetype,
      vector_gdal = vector_gdal,
      raster_args = raster_args,
      vector_args = vector_args
    ),
    repository = repository,
    iteration = "list",
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    storage = storage,
    retrieval = retrieval,
    cue = cue,
    description = description
  )
}


# Internal functions -----------------------------------------------------------
#' @export
#' @keywords internal
write_terra_nested <- function(
    object,
    path,
    raster_filetype,
    raster_gdal,
    raster_datatype,
    vector_filetype,
    vector_gdal,
    raster_args,
    vector_args
) {
  root <- tempfile("targets_utils_terra_nested_write_")
  dir.create(root, recursive = TRUE, showWarnings = FALSE)

  spatial_dir <- file.path(root, "spatial")
  dir.create(spatial_dir, recursive = TRUE, showWarnings = FALSE)

  counter <- new.env(parent = emptyenv())
  counter$n <- 0L

  next_id <- function(prefix) {
    counter$n <- counter$n + 1L
    sprintf("%s_%06d", prefix, counter$n)
  }

  skeleton <- replace_terra_objects(
    x = object,
    spatial_dir = spatial_dir,
    next_id = next_id,
    raster_filetype = raster_filetype,
    raster_gdal = raster_gdal,
    raster_datatype = raster_datatype,
    vector_filetype = vector_filetype,
    vector_gdal = vector_gdal,
    raster_args = raster_args,
    vector_args = vector_args
  )

  saveRDS(
    object = skeleton,
    file = file.path(root, "skeleton.rds"),
    version = 3
  )

  path <- file.path(normalizePath(dirname(path)), basename(path))

  if (file.exists(path)) {
    unlink(path, force = TRUE)
  }

  old <- setwd(root)
  on.exit(setwd(old), add = TRUE)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)

  archive_files <- list.files(
    path = ".",
    all.files = TRUE,
    recursive = FALSE,
    no.. = TRUE
  )

  utils::tar(
    tarfile = path,
    files = archive_files,
    compression = "gzip",
    tar = "internal"
  )

  invisible(path)
}

#' @export
#' @keywords internal
read_terra_nested <- function(path) {
  # terra reads SpatRasters lazily: terra::rast() keeps a pointer to the file
  # on disk rather than loading cell values into memory. The extracted files
  # must therefore outlive this function, or later operations that touch raster
  # values (e.g. plot()) fail because the backing file is gone. Mirroring
  # geotargets' "zip" read mode, we extract into the session-persistent
  # tempdir() and do not delete it. The directory is keyed on the archive so a
  # rebuilt target (new content) extracts afresh rather than reusing stale
  # files, while repeated reads of the same archive reuse the extraction.
  key <- unname(tools::md5sum(path))
  root <- file.path(tempdir(), "targets_utils_terra_nested", key)

  skeleton_path <- file.path(root, "skeleton.rds")

  if (!file.exists(skeleton_path)) {
    dir.create(root, recursive = TRUE, showWarnings = FALSE)

    utils::untar(
      tarfile = path,
      exdir = root,
      tar = "internal"
    )
  }

  if (!file.exists(skeleton_path)) {
    stop(
      "Cannot read nested terra target. Archive does not contain skeleton.rds.",
      call. = FALSE
    )
  }

  skeleton <- readRDS(skeleton_path)

  restore_terra_objects(
    x = skeleton,
    root = root
  )
}


#' @keywords internal
#' @noRd
replace_terra_objects <- function(
    x,
    spatial_dir,
    next_id,
    raster_filetype,
    raster_gdal,
    raster_datatype,
    vector_filetype,
    vector_gdal,
    raster_args,
    vector_args
) {
  if (inherits(x, "SpatRaster")) {
    return(
      replace_spatraster(
        x = x,
        spatial_dir = spatial_dir,
        next_id = next_id,
        raster_filetype = raster_filetype,
        raster_gdal = raster_gdal,
        raster_datatype = raster_datatype,
        raster_args = raster_args
      )
    )
  }

  if (inherits(x, "SpatVector")) {
    return(
      replace_spatvector(
        x = x,
        spatial_dir = spatial_dir,
        next_id = next_id,
        vector_filetype = vector_filetype,
        vector_gdal = vector_gdal,
        vector_args = vector_args
      )
    )
  }

  if (is.environment(x)) {
    stop(
      "tar_terra_nested() does not support environments. ",
      "Return lists or other serialisable R objects instead.",
      call. = FALSE
    )
  }

  if (is.list(x)) {
    out <- x

    for (i in seq_along(x)) {
      out[[i]] <- replace_terra_objects(
        x = x[[i]],
        spatial_dir = spatial_dir,
        next_id = next_id,
        raster_filetype = raster_filetype,
        raster_gdal = raster_gdal,
        raster_datatype = raster_datatype,
        vector_filetype = vector_filetype,
        vector_gdal = vector_gdal,
        raster_args = raster_args,
        vector_args = vector_args
      )
    }

    attributes(out) <- replace_attr_terra_objects(
      attrs = attributes(x),
      spatial_dir = spatial_dir,
      next_id = next_id,
      raster_filetype = raster_filetype,
      raster_gdal = raster_gdal,
      raster_datatype = raster_datatype,
      vector_filetype = vector_filetype,
      vector_gdal = vector_gdal,
      raster_args = raster_args,
      vector_args = vector_args
    )

    return(out)
  }

  if (methods::is(x, "S4")) {
    out <- x

    for (slot_name in methods::slotNames(x)) {
      methods::slot(out, slot_name) <- replace_terra_objects(
        x = methods::slot(x, slot_name),
        spatial_dir = spatial_dir,
        next_id = next_id,
        raster_filetype = raster_filetype,
        raster_gdal = raster_gdal,
        raster_datatype = raster_datatype,
        vector_filetype = vector_filetype,
        vector_gdal = vector_gdal,
        raster_args = raster_args,
        vector_args = vector_args
      )
    }

    return(out)
  }

  x
}


#' @keywords internal
#' @noRd
replace_spatraster <- function(
    x,
    spatial_dir,
    next_id,
    raster_filetype,
    raster_gdal,
    raster_datatype,
    raster_args
) {
  id <- next_id("rast")
  ext <- raster_extension(raster_filetype)
  filename <- file.path(spatial_dir, paste0(id, ext))

  args <- c(
    list(
      x = x,
      filename = filename,
      overwrite = TRUE,
      filetype = raster_filetype
    ),
    raster_args
  )

  if (!is.null(raster_gdal)) {
    args$gdal <- raster_gdal
  }

  if (!is.null(raster_datatype)) {
    args$datatype <- raster_datatype
  }

  do.call(terra::writeRaster, args)

  structure(
    list(
      type = "SpatRaster",
      path = file.path("spatial", paste0(id, ext))
    ),
    class = "targets_utils_terra_nested_ref"
  )
}


#' @keywords internal
#' @noRd
replace_spatvector <- function(
    x,
    spatial_dir,
    next_id,
    vector_filetype,
    vector_gdal,
    vector_args
) {
  id <- next_id("vect")
  ext <- vector_extension(vector_filetype)
  filename <- file.path(spatial_dir, paste0(id, ext))

  args <- c(
    list(
      x = x,
      filename = filename,
      overwrite = TRUE,
      filetype = vector_filetype
    ),
    vector_args
  )

  if (!is.null(vector_gdal)) {
    args$options <- vector_gdal
  }

  do.call(terra::writeVector, args)

  structure(
    list(
      type = "SpatVector",
      path = file.path("spatial", paste0(id, ext))
    ),
    class = "targets_utils_terra_nested_ref"
  )
}


#' @keywords internal
#' @noRd
replace_attr_terra_objects <- function(
    attrs,
    spatial_dir,
    next_id,
    raster_filetype,
    raster_gdal,
    raster_datatype,
    vector_filetype,
    vector_gdal,
    raster_args,
    vector_args
) {
  if (is.null(attrs)) {
    return(NULL)
  }

  skip <- c("names", "class", "row.names")
  recurse <- setdiff(names(attrs), skip)

  for (nm in recurse) {
    attrs[[nm]] <- replace_terra_objects(
      x = attrs[[nm]],
      spatial_dir = spatial_dir,
      next_id = next_id,
      raster_filetype = raster_filetype,
      raster_gdal = raster_gdal,
      raster_datatype = raster_datatype,
      vector_filetype = vector_filetype,
      vector_gdal = vector_gdal,
      raster_args = raster_args,
      vector_args = vector_args
    )
  }

  attrs
}


#' @keywords internal
#' @noRd
restore_terra_objects <- function(x, root) {
  if (inherits(x, "targets_utils_terra_nested_ref")) {
    filename <- file.path(root, x$path)

    if (!file.exists(filename)) {
      stop(
        "Cannot restore nested terra object. Missing file: ",
        filename,
        call. = FALSE
      )
    }

    if (identical(x$type, "SpatRaster")) {
      return(terra::rast(filename))
    }

    if (identical(x$type, "SpatVector")) {
      return(terra::vect(filename))
    }

    stop(
      "Unknown nested terra reference type: ",
      x$type,
      call. = FALSE
    )
  }

  if (is.list(x)) {
    out <- x

    for (i in seq_along(x)) {
      out[[i]] <- restore_terra_objects(
        x = x[[i]],
        root = root
      )
    }

    attributes(out) <- restore_attr_terra_objects(
      attrs = attributes(x),
      root = root
    )

    return(out)
  }

  if (methods::is(x, "S4")) {
    out <- x

    for (slot_name in methods::slotNames(x)) {
      methods::slot(out, slot_name) <- restore_terra_objects(
        x = methods::slot(x, slot_name),
        root = root
      )
    }

    return(out)
  }

  x
}


#' @keywords internal
#' @noRd
restore_attr_terra_objects <- function(attrs, root) {
  if (is.null(attrs)) {
    return(NULL)
  }

  skip <- c("names", "class", "row.names")
  recurse <- setdiff(names(attrs), skip)

  for (nm in recurse) {
    attrs[[nm]] <- restore_terra_objects(
      x = attrs[[nm]],
      root = root
    )
  }

  attrs
}


#' @keywords internal
#' @noRd
raster_extension <- function(filetype) {
  switch(
    toupper(filetype),
    "GTIFF" = ".tif",
    "COG" = ".tif",
    "AAIGRID" = ".asc",
    "ENVI" = ".envi",
    "HFA" = ".img",
    "NETCDF" = ".nc",
    "PCRASTER" = ".map",
    ".tif"
  )
}


#' @keywords internal
#' @noRd
vector_extension <- function(filetype) {
  normalised <- toupper(filetype)

  switch(
    normalised,
    "GPKG" = ".gpkg",
    "GEOJSON" = ".geojson",
    "ESRI SHAPEFILE" = ".shp",
    "FLATGEOBUF" = ".fgb",
    "CSV" = ".csv",
    ".gpkg"
  )
}
