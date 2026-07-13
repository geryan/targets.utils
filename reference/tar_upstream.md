# Get upstream targets from a specified target

Find all targets that a given target depends on, either directly or
indirectly. This is useful for understanding the dependencies and
requirements of a target.

## Usage

``` r
tar_upstream(target_name, immediate = FALSE)
```

## Arguments

- target_name:

  Symbol or character. Name of the target to find upstream targets from.

- immediate:

  Logical. If \`TRUE\`, return only first-degree dependencies (targets
  that \`target_name\` directly depends on). If \`FALSE\` (default),
  return all upstream targets, including indirect dependencies.

## Value

Character vector of upstream target names (excluding the target itself).
Returns an empty character vector if there are no upstream targets
(i.e., the target has no dependencies).

## Details

This function is the inverse of \[tar_downstream()\]. While
\`tar_downstream()\` shows what depends on a target, \`tar_upstream()\`
shows what a target depends on.

This function requires the \`igraph\` package, which is listed in
Imports. It queries the current targets pipeline via
\`targets::tar_network()\` and traverses the dependency graph to find
all targets that the specified target depends on.

## Examples

``` r
if (FALSE) { # \dontrun{
# After tar_make(), show what 'final_output' depends on
tar_upstream(final_output)

# Only direct dependencies
tar_upstream("analysis", immediate = TRUE)
} # }
```
