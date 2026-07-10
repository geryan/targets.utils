#' Targets load globals and everything
#'
#' Runs `targets::tar_load_globals` then `targets::tar_load_everything` to save
#' you the drudgery of typing those thing out again and again and again and
#' again and again et cetera ad nauseum.
#'
#' @returns Nothing
#' @export
#'
#' @examples
#' \dontrun{
#' tl()
#' }
tl <- function(){

  targets::tar_load_globals(envir = .GlobalEnv)

  targets::tar_load_everything(envir = .GlobalEnv)

}
