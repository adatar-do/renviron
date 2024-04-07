
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renviron <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/adatar-do/renviron/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/adatar-do/renviron/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/adatar-do/renviron/branch/main/graph/badge.svg)](https://codecov.io/gh/adatar-do/renviron?branch=main)
[![CRAN
status](https://www.r-pkg.org/badges/version/renviron)](https://CRAN.R-project.org/package=renviron)
![r-universe](https://adatar-do.r-universe.dev/badges/renviron)
<!-- badges: end -->

`renviron` is an R package designed to streamline the management of
environment variables within R projects. It facilitates the creation,
modification, and deletion of variables in the `.Renviron` file,
enabling dynamic environment variable handling directly from R. This
toolkit is essential for projects that require precise control over
environment configurations, such as managing API keys, database
credentials, and application-specific settings.

``` r
devtools::load_all()
#> ℹ Loading renviron
```

## Installation

You can install the development version of `renviron` from [Adatar’s
r-universe](https://adatar-do.r-universe.dev/renviron) with:

``` r
install.packages("renviron", repos = "https://adatar-do.r-universe.dev")
```

## Usage

### Understanding Scope

When working in RStudio, the project-level `.Renviron` file is
automatically loaded upon opening a project, making environment
variables defined at the project scope readily available. However,
`renviron` extends this functionality by allowing management of
environment variables across both project and user scopes:

- **Project Scope**: Variables specific to the current R project.
- **User Scope**: Global variables that apply across all projects for
  the user.

This distinction is crucial for managing environment variables that are
either specific to a project or meant to be globally accessible across
multiple projects.

### The Scope Argument

The `scope` argument is a powerful feature in the `renviron` package
that provides flexibility in managing environment variables across
different levels of your R environment. Available in all main functions
of the package, `scope` allows you to specify whether you want to
interact with environment variables at the project level, the user
level, or both. This feature is especially useful when working within
RStudio, which automatically loads project-level `.Renviron` files.

- **Project Scope**: When `scope` is set to `"project"`, `renviron`
  functions will operate on the `.Renviron` file located in your current
  R project directory. This is useful for setting environment variables
  that are specific to the project you are working on.

- **User Scope**: Setting `scope` to `"user"` directs `renviron`
  functions to work with the `.Renviron` file in your user home
  directory. Variables set at this level are accessible across all your
  R projects, making this scope suitable for global configurations and
  secrets.

- **Both Scopes**: You can also specify both scopes by using
  `scope = c("project", "user")`. In this case, `renviron` functions
  will prioritize the project scope over the user scope when reading,
  adding, or updating environment variables. This ensures that
  project-specific settings take precedence, while still allowing access
  to user-level configurations.

### Usage Across Functions

All main functions in the `renviron` package, including `renviron_load`,
`renviron_list`, `renviron_add`, `renviron_get`, and `renviron_delete`,
support the `scope` argument. This consistency allows you to seamlessly
manage your environment variables with precision, whether you’re loading
variables, adding new ones, retrieving specific variables, or deleting
them.

For example, RStudio will automatically load the project-level
`.Renviron` file when you open a project. To load environment variables
from user scope, you can use:

``` r
renviron_load("user")
```

Now you can access the user-level variables in your R environment.

To add a new variable to the user-level `.Renviron` file, bypassing the
project-level file, you can specify:

``` r
renviron_add("GLOBAL_API_KEY", "12345abcde", scope = "user")
```

This uniform approach to `scope` across the `renviron` package enhances
your control over where and how environment variables are managed within
your R environment, catering to a wide range of use cases from
project-specific configurations to global settings.

### Loading environment variables

Load all environment variables from the `.Renviron` file.

``` r
library(renviron)
renviron_load()
#> ✔ Setting active project to 'C:/Users/drdsd/Documents/Projects/renviron'
```

Now you can access the variables from the system environment

``` r
Sys.getenv("SECRET_1")
#> [1] "123abc"
```

Alternatively, you can capture the variables directly into a named list

``` r
env <- renviron_load()
env$SECRET_1
#> [1] "123abc"
```

### Listing all variables

Get a list of all environment variables currently set. This will return
a named list with all the variables and their values. For security
reasons, the values are masked. So, you can use this function to list
all the variables without revealing their values.

``` r
renviron_list()
#>       SECRET_1   GITHUB_TOKEN DATAFARO_TOKEN        NEW_VAR 
#>         "****"         "****"         "****"         "****"
```

### Adding a new variable

Add a new environment variable or update an existing one.

``` r
renviron_add("NEW_VAR", "new_value")
Sys.getenv("NEW_VAR")
#> [1] "new_value"
```

This will add or update the variable `NEW_VAR` with the value
`new_value` in the system environment, if you want to save it to the
`.Renviron` file, you can use the `in_place` argument.

``` r
renviron_add("NEW_VAR", "new_value", in_place = TRUE, confirm = FALSE)
renviron_list()
#>       SECRET_1   GITHUB_TOKEN DATAFARO_TOKEN        NEW_VAR 
#>         "****"         "****"         "****"         "****"
```

Note: The `confirm` argument is set to `TRUE` by default, which will
prompt you to confirm the changes before saving them to the `.Renviron`
file. If you want to save the changes without confirmation, you can set
`confirm = FALSE`.

Alternatively, you can capture the variables directly into a named list
no matter if you save it to the `.Renviron` file or not.

``` r
env <- renviron_add("NEW_VAR", "new_value")
env$NEW_VAR
#> [1] "new_value"
```

### Getting a variable’s value

Retrieve the value of a specific environment variable.

``` r
renviron_get("SECRET_1")
#> [1] "123abc"
```

### Deleting a variable

Remove an environment variable.

``` r
renviron_delete("SECRET_1")
Sys.getenv("SECRET_1")
#> [1] ""
```

## Contributing

Contributions to `renviron` are welcome from all! Contributions can be
made in the form of feedback, bug reports, or even better - pull
requests. Please adhere to the [Code of Conduct](CODE_OF_CONDUCT.md) for
all interactions with the project.

## License

`renviron` is released under the MIT License. See the bundled
[LICENSE](LICENSE.md) file for details.

## Acknowledgments

- Thanks to all
  [contributors](https://github.com/adatar-do/renviron/graphs/contributors)
  who have helped shape `renviron`.
- Special thanks to [Adatar](https://adatar.do) for their contributions
  to the project.
