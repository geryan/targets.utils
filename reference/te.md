# Load all targets and globals from a targets pipeline

Shorthand for \`targets::tar_load_everything(envir = .GlobalEnv)\`.
Loads all targets and globals into the global environment.

## Usage

``` r
te()
```

## Value

Invisibly returns NULL. Called for side effects (loading targets and
globals into the global environment).

## Examples

``` r
if (FALSE) { # \dontrun{
te()  # Load all targets and globals
} # }
```
