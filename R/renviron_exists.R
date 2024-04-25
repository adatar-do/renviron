#' Check if an environment variable exists
#'
#' This function checks for the existence of a specified environment variable either in the .Renviron file
#' or within a provided named list of environment variables. It is useful for validating configuration
#' before attempting to use environment variables in your application.
#'
#' @param key A character string specifying the name of the environment variable to check.
#' @param .renviron An optional named list of environment variables to check against.
#'        If not provided, the function will load the variables from the .Renviron file using `renviron_load()`,
#'        considering the specified scope.
#' @param ... Additional arguments to `renviron_load()` when `.renviron` is not provided:
#'        - `scope`: A character vector specifying the scope(s) to search for the .Renviron file.
#'          Valid options are "user" and "project". The function searches in the order provided,
#'          defaulting to `c("user", "project")` if not specified. This allows for flexibility in determining
#'          where the environment variables are loaded from based on operational needs.
#'        - `.file`: Specifies the filename to consider as the environment file within the scope.
#'          This can be used to specify a different environment file if needed.
#'
#' @return TRUE if the environment variable exists in the specified scope or list, FALSE otherwise.
#'         This boolean value can be used to make decisions in scripts or applications based on the
#'         availability of required configuration.
#'
#' @examples
#' \dontrun{
#' # Check if the CENSUS_API_KEY variable exists in the .Renviron file within the default scope
#' exists <- renviron_exists("CENSUS_API_KEY")
#' print(exists)  # Prints TRUE if the variable exists, FALSE otherwise
#'
#' # Check for the variable in a provided list
#' env_list <- list(CENSUS_API_KEY='12345', GITHUB_PAT='abcde')
#' exists_in_list <- renviron_exists("CENSUS_API_KEY", .renviron = env_list)
#' print(exists_in_list)  # Expected output: TRUE
#'}
#'
#' @export
renviron_exists <- function(key, .renviron = NULL, ...) {
  if (is.null(.renviron)) {
    .renviron <- renviron_load(...)  # Load environment variables if not provided
  }

  # Check if the key exists in the list
  exists <- !is.null(.renviron[[key]])

  return(exists)
}
