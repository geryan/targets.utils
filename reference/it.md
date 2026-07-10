# Insert a tar_target() skeleton

Alias for \[insert_tar_target()\].

## Usage

``` r
it()
```

## Value

Invisibly returns \`NULL\`.

## Details

This function is intended for quick interactive use. It calls
\[insert_tar_target()\] and inserts a \`targets::tar_target()\` skeleton
at the current cursor position in RStudio.

## See also

\[insert_tar_target()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# In RStudio, place the cursor in an R script and run:
it()

# This is equivalent to:
insert_tar_target()
} # }
```
