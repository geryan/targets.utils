#' Targets load globals and everything
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
