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

  targets::tar_load_globals()
  targets::tar_load_everything()

}
