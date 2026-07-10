#' NOT WORKING PROPERLY YET
#'
#' @param target_name Unquoted target name.
#'
#' @returns Character vector of downstream target names.
#'
#' @examples
#' \dontrun{tar_downstream(my_target)}
#'
#' @keywords internal
tar_downstream <- function(target_name){

  network <- targets::tar_network()

  # Requires igraph (in Suggests) - not yet complete
  g <- igraph::graph_from_data_frame(network$edges)

  downstream <- igraph::subcomponent(
    g,
    target_name,
    mode = "out"
  )

  names(downstream)[-1]

  # not working
  # will need to iomport igraph

}
