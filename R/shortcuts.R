#' Load all globals from a targets pipeline
#'
#' Shorthand for `targets::tar_load_globals(envir = .GlobalEnv)`. Loads all
#' global objects (functions, constants, etc.) defined in the targets script.
#'
#' @return Invisibly returns NULL. Called for side effects (loading globals into
#'   the global environment).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' tg()  # Load globals from the current targets pipeline
#' }
tg <- function() {
  targets::tar_load_globals(envir = .GlobalEnv)
}


#' Load all targets and globals from a targets pipeline
#'
#' Shorthand for `targets::tar_load_everything(envir = .GlobalEnv)`. Loads all
#' targets and globals into the global environment.
#'
#' @return Invisibly returns NULL. Called for side effects (loading targets and
#'   globals into the global environment).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' te()  # Load all targets and globals
#' }
te <- function() {
  targets::tar_load_everything(envir = .GlobalEnv)
}
