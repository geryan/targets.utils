#' targets.utils
#'
#' Utilities for working with targets pipelines.
#'
#' @keywords internal
#'
#' @importFrom methods is slot slotNames
#' @importFrom targets tar_format tar_option_get tar_target_raw
#' @importFrom utils tar untar
"_PACKAGE"

# Quiet R CMD check: these are substituted at runtime by tar_format()
utils::globalVariables(c(
  "TARGETS_UTILS_RASTER_FILETYPE",
  "TARGETS_UTILS_RASTER_GDAL",
  "TARGETS_UTILS_RASTER_DATATYPE",
  "TARGETS_UTILS_VECTOR_FILETYPE",
  "TARGETS_UTILS_VECTOR_GDAL",
  "TARGETS_UTILS_RASTER_ARGS",
  "TARGETS_UTILS_VECTOR_ARGS"
))
