#' Unset all environment variables from the environment file
#'
#' This function unsets all environment variables that are loaded from the specified
#' .Renviron file within the given scope. It is particularly useful for cleaning up
#' the environment in R sessions during testing or after loading configurations that
#' are no longer needed.
#'
#' @param ... Additional arguments to `renviron_load()`:
#'        - `scope`: A character vector specifying the scope(s) to search for the .Renviron file.
#'          Valid values are "user" and "project". The function searches in the order provided.
#'          The default order is `c("project", "user")`.
#'        - `.file`: Optionally specify a different filename to use within the specified scope.
#'          Defaults to ".Renviron".
#'
#' @return Invisibly returns NULL after unsetting the variables.
#'
#' @examples
#' \dontrun{
#' renviron_unset_all(scope = "project")
#' renviron_unset_all(scope = "user", .file = "custom.env")
#' }
#'
#' @export
renviron_unset_all <- function(...) {
  env_vars <- renviron_load(...)
  var_names <- names(env_vars)

  # Unsetting all variables found in the specified .Renviron file
  sapply(var_names, function(x) Sys.unsetenv(x))

  invisible(NULL)
}
