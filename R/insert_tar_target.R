#' Insert a tar_target() skeleton
#'
#' RStudio addin that inserts a `targets::tar_target()` skeleton at the current
#' cursor position.
#'
#' NB: a comma is intentionally added at the end of the text in order to
#' facilitate intra-target list insertion which the package author finds is
#' the most common situation
#'
#' @return Invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' # In RStudio, place the cursor in an R script and run:
#' insert_tar_target()
#'
#' # Or use the registered RStudio addin:
#' # Addins > Insert tar_target
#'
#' # The addin inserts:
#' # tar_target(
#' #    name = ,
#' #    command =
#' #  ),
#' }
#'
#' @export
insert_tar_target <- function() {
  text <- paste0(
    "tar_target(\n",
    "   name = ,\n",
    "   command = \n",
    " ),"
  )

  rstudioapi::insertText(text)

  invisible(NULL)
}

#' Insert a tar_target() skeleton
#'
#' Alias for [insert_tar_target()].
#'
#' This function is intended for quick interactive use. It calls
#' [insert_tar_target()] and inserts a `targets::tar_target()` skeleton at the
#' current cursor position in RStudio.
#'
#' @return Invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' # In RStudio, place the cursor in an R script and run:
#' it()
#'
#' # This is equivalent to:
#' insert_tar_target()
#' }
#'
#' @seealso [insert_tar_target()]
#'
#' @export
it <- function() {
  insert_tar_target()
}
