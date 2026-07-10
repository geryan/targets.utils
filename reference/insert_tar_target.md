# Insert a tar_target() skeleton

RStudio addin that inserts a \`targets::tar_target()\` skeleton at the
current cursor position.

## Usage

``` r
insert_tar_target()
```

## Value

Invisibly returns \`NULL\`.

## Details

NB: a comma is intentionally added at the end of the text in order to
facilitate intra-target list insertion which the package author finds is
the most common situation

## Examples

``` r
if (FALSE) { # \dontrun{
# In RStudio, place the cursor in an R script and run:
insert_tar_target()

# Or use the registered RStudio addin:
# Addins > Insert tar_target

# The addin inserts:
# tar_target(
#    name = ,
#    command =
#  ),
} # }
```
