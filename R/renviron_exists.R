#' Check if an Environment Variable Exists
#'
#' This function checks for the existence of a specified environment variable in the .Renviron file
#' or a provided named list of environment variables.
#'
#' @param key A character string specifying the name of the environment variable to check.
#' @param .renviron An optional named list of environment variables to check.
#'        If not provided, the function will load the variables from the .Renviron file using `renviron_load()`.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when loading
#'        environment variables. This is used only when `.renviron` is `NULL`. Valid values
#'        are "user" and "project". The function searches in the order provided. The default order
#'        is `c("project", "user")`.
#'
#' @return TRUE if the environment variable exists, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' # Check if the CENSUS_API_KEY variable exists in the .Renviron file
#' exists <- renviron_exists("CENSUS_API_KEY")
#' print(exists)
#'
#' # Check for the variable in a provided list
#' env_list <- list(CENSUS_API_KEY='12345', GITHUB_PAT='abcde')
#' exists_in_list <- renviron_exists("CENSUS_API_KEY", .renviron = env_list)
#' print(exists_in_list)
#' }
#'
#' @export
renviron_exists <- function(key, .renviron = NULL, scope = c("project", "user")) {
  if (is.null(.renviron)) {
    .renviron <- renviron_load(scope = scope)  # Load environment variables if not provided
  }

  # Check if the key exists in the list
  exists <- !is.null(.renviron[[key]])

  return(exists)
}
