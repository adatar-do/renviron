
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renviron <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->
<!-- Add some badges here from shields.io, like build status, CRAN status, etc. -->
<!-- badges: end -->

`renviron` is an R package designed to streamline the management of
environment variables within R projects. It facilitates the creation,
modification, and deletion of variables in the `.Renviron` file,
enabling dynamic environment variable handling directly from R. This
toolkit is essential for projects that require precise control over
environment configurations, such as managing API keys, database
credentials, and application-specific settings.

## Installation

You can install the development version of `renviron` from [Adatar’s
r-universe](https://adatar-do.r-universe.dev/renviron) with:

``` r
install.packages("renviron", repos = "https://adatar-do.r-universe.dev")
```

## Usage

### Loading environment variables

Load all environment variables from the `.Renviron` file into a named
list.

``` r
library(renviron)
env_vars <- renviron_load()
```

### Adding a new variable

Add a new environment variable or update an existing one.

``` r
renviron_add("NEW_VAR", "new_value")
```

### Getting a variable’s value

Retrieve the value of a specific environment variable.

``` r
api_key <- renviron_get("API_KEY")
```

### Deleting a variable

Remove an environment variable.

``` r
renviron_delete("OBSOLETE_VAR")
```

### Listing all variables

Get a list of all environment variables currently set.

``` r
all_vars <- renviron_list()
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
