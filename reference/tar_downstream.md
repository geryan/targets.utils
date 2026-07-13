# Get downstream targets from a specified target

Find all targets that depend on a given target, either directly or
indirectly. This is useful for understanding the impact of changes to a
target on the rest of the pipeline.

## Usage

``` r
tar_downstream(target_name, immediate = FALSE)
```

## Arguments

- target_name:

  Symbol or character. Name of the target to find downstream targets
  from.

- immediate:

  Logical. If \`TRUE\`, return only first-degree dependencies (targets
  that directly depend on \`target_name\`). If \`FALSE\` (default),
  return all downstream targets, including indirect dependencies.

## Value

Character vector of downstream target names (excluding the target
itself). Returns an empty character vector if there are no downstream
targets.

## Details

This function requires the \`igraph\` package, which is listed in
Imports. It queries the current targets pipeline via
\`targets::tar_network()\` and traverses the dependency graph to find
all targets that depend on the specified target.

## Examples

``` r
if (FALSE) { # \dontrun{
# After tar_make(), show what depends on 'raw_data'
tar_downstream(raw_data)

# Only direct dependents
tar_downstream("processed_data", immediate = TRUE)
} # }
```
