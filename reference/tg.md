# Load all globals from a targets pipeline

Shorthand for \`targets::tar_load_globals(envir = .GlobalEnv)\`. Loads
all global objects (functions, constants, etc.) defined in the targets
script.

## Usage

``` r
tg()
```

## Value

Invisibly returns NULL. Called for side effects (loading globals into
the global environment).

## Examples

``` r
if (FALSE) { # \dontrun{
tg()  # Load globals from the current targets pipeline
} # }
```
