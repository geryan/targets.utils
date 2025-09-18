#' Target make and load
#' @description Convenience function to make and load an object when working interactively with a targets workflow. Calls `targets::tar_make(x)` then `targets::tar_load(x)`
#'
#' @param x Object name to make and load
#' @author Gerry Ryan
#' @return Nothing
#' @export
#'
#' @examples
#' \dontrun{
#' tml(x)
#' }
tml <- function(x){

  tar_make({{x}})
  tar_load(
    names = {{x}},
    envir = .GlobalEnv
  )

}
