#' Retrieve a specific environment variable from the environment file
#'
#' This function fetches the value of a specified environment variable from the .Renviron file,
#' considering both user and project scopes as defined by the `scope` argument when loading the file.
#' If the `.renviron` argument is provided, it uses this list directly, bypassing the need to load
#' from the file. This is particularly useful for accessing specific environment variables in a secure
#' and controlled manner, especially during testing or when working with a dynamically modified environment.
#'
#' @param key A character string specifying the name of the environment variable to retrieve.
#' @param .renviron An optional named list of environment variables to use instead of loading from
#'        the .Renviron file. This can be useful for testing or when working with a modified set
#'        of environment variables that has not been saved back to the file.
#' @param ... Additional arguments that are passed to the `renviron_load()` function:
#'        - `scope`: A character vector specifying the scope(s) to search for the .Renviron file.
#'          Valid values are "user" and "project", with "project" typically having precedence unless
#'          otherwise specified. This is used only when `.renviron` is `NULL`. The default is `c("project", "user")`.
#'        - `.file`: Specifies the filename to be considered as the environment file within the specified scope.
#'          Default is ".Renviron".
#'
#' @return The value of the environment variable corresponding to `key`, if it exists.
#'         Returns `NULL` if the key does not exist in the list or .Renviron file within the specified scope.
#'
#' @examples
#' \dontrun{
#' # Assuming the .Renviron file contains:
#' # CENSUS_API_KEY='12345'
#'
#' # Retrieve the CENSUS_API_KEY value from the .Renviron file within the default scope
#' api_key <- renviron_get("CENSUS_API_KEY")
#' print(api_key)
#'
#' # Retrieve a variable value from a provided list of environment variables
#' env_vars <- list(CENSUS_API_KEY='67890', GITHUB_PAT='fghij')
#' api_key_from_list <- renviron_get("CENSUS_API_KEY", .renviron = env_vars)
#' print(api_key_from_list)
#' }
#'
#' @export
renviron_get <- function(key, .renviron = NULL, ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(...)  # Load environment variables if not provided
  } else {
    env <- .renviron  # Use the provided list of environment variables
  }
  .res <- env[key]

  if (!is.null(.res)) {
    do.call(Sys.setenv, .res)  # Update the system environment
  }

  Sys.getenv(key)  # Return the value of the specified key
}
