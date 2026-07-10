#' NOT WORKING PROPERLY YET
#'
#' @param target_name
#'
#' @returns
#' @export
#'
#' @examples
tar_downstream <- function(target_name){

  network <- targets::tar_network()

  g <- igraph::graph_from_data_frame(network$edges)

  downstream <- igraph::subcomponent(
    g,
    target_name,
    mode = "out"
  )

  names(downstream)[-1]

  # not working

}
