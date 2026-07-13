#' Get downstream targets from a specified target
#'
#' Find all targets that depend on a given target, either directly or indirectly.
#' This is useful for understanding the impact of changes to a target on the
#' rest of the pipeline.
#'
#' @param target_name Symbol or character. Name of the target to find downstream
#'   targets from.
#' @param immediate Logical. If `TRUE`, return only first-degree dependencies
#'   (targets that directly depend on `target_name`). If `FALSE` (default),
#'   return all downstream targets, including indirect dependencies.
#'
#' @return Character vector of downstream target names (excluding the target
#'   itself). Returns an empty character vector if there are no downstream
#'   targets.
#'
#' @details
#' This function requires the `igraph` package, which is listed in Imports.
#' It queries the current targets pipeline via `targets::tar_network()` and
#' traverses the dependency graph to find all targets that depend on the
#' specified target.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # After tar_make(), show what depends on 'raw_data'
#' tar_downstream(raw_data)
#'
#' # Only direct dependents
#' tar_downstream("processed_data", immediate = TRUE)
#' }
tar_downstream <- function(target_name, immediate = FALSE) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop(
      "The 'igraph' package is required for tar_downstream(). ",
      "Install it with: install.packages('igraph')",
      call. = FALSE
    )
  }

  # Convert symbol to character if needed
  if (is.symbol(target_name)) {
    target_name <- as.character(target_name)
  }

  network <- targets::tar_network()

  # Check if target exists in the network
  if (!target_name %in% c(network$edges$from, network$edges$to)) {
    stop(
      "Target '", target_name, "' not found in the pipeline.",
      call. = FALSE
    )
  }

  # Create directed graph from edges
  g <- igraph::graph_from_data_frame(
    d = network$edges,
    directed = TRUE
  )

  if (immediate) {
    # Get only direct successors (targets that directly depend on target_name)
    direct_deps <- network$edges[network$edges$from == target_name, "to", drop = TRUE]
    return(as.character(direct_deps))
  }

  # Get all vertices reachable from target_name in the outward direction
  # (mode = "out" means targets that depend on target_name)
  downstream <- igraph::subcomponent(
    g,
    target_name,
    mode = "out"
  )

  # Convert to character vector and exclude the target itself
  downstream_names <- names(downstream)
  downstream_names[downstream_names != target_name]
}


#' Get upstream targets from a specified target
#'
#' Find all targets that a given target depends on, either directly or indirectly.
#' This is useful for understanding the dependencies and requirements of a target.
#'
#' @param target_name Symbol or character. Name of the target to find upstream
#'   targets from.
#' @param immediate Logical. If `TRUE`, return only first-degree dependencies
#'   (targets that `target_name` directly depends on). If `FALSE` (default),
#'   return all upstream targets, including indirect dependencies.
#'
#' @return Character vector of upstream target names (excluding the target
#'   itself). Returns an empty character vector if there are no upstream
#'   targets (i.e., the target has no dependencies).
#'
#' @details
#' This function is the inverse of [tar_downstream()]. While `tar_downstream()`
#' shows what depends on a target, `tar_upstream()` shows what a target depends on.
#'
#' This function requires the `igraph` package, which is listed in Imports.
#' It queries the current targets pipeline via `targets::tar_network()` and
#' traverses the dependency graph to find all targets that the specified target
#' depends on.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # After tar_make(), show what 'final_output' depends on
#' tar_upstream(final_output)
#'
#' # Only direct dependencies
#' tar_upstream("analysis", immediate = TRUE)
#' }
tar_upstream <- function(target_name, immediate = FALSE) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop(
      "The 'igraph' package is required for tar_upstream(). ",
      "Install it with: install.packages('igraph')",
      call. = FALSE
    )
  }

  # Convert symbol to character if needed
  if (is.symbol(target_name)) {
    target_name <- as.character(target_name)
  }

  network <- targets::tar_network()

  # Check if target exists in the network
  if (!target_name %in% c(network$edges$from, network$edges$to)) {
    stop(
      "Target '", target_name, "' not found in the pipeline.",
      call. = FALSE
    )
  }

  # Create directed graph from edges
  g <- igraph::graph_from_data_frame(
    d = network$edges,
    directed = TRUE
  )

  if (immediate) {
    # Get only direct predecessors (targets that target_name directly depends on)
    direct_deps <- network$edges[network$edges$to == target_name, "from", drop = TRUE]
    return(as.character(direct_deps))
  }

  # Get all vertices reachable from target_name in the inward direction
  # (mode = "in" means targets that target_name depends on)
  upstream <- igraph::subcomponent(
    g,
    target_name,
    mode = "in"
  )

  # Convert to character vector and exclude the target itself
  upstream_names <- names(upstream)
  upstream_names[upstream_names != target_name]
}
