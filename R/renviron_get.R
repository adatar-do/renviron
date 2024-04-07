#' Retrieve a Specific Environment Variable from the .Renviron File
#'
#' This function fetches the value of a specified environment variable from the .Renviron file,
#' considering both user and project scopes as defined by the `scope` argument. It relies on
#' `renviron_load()` to load the environment variables into a named list, from which the value
#' of the specified key is retrieved. If the `.renviron` argument is provided, it uses this list
#' directly, bypassing the need to load from the file. The function is particularly useful for
#' accessing specific environment variables in a secure and controlled manner.
#'
#' @param key A character string specifying the name of the environment variable to retrieve.
#' @param .renviron An optional named list of environment variables. If provided, the function will
#'        use this list instead of loading the .Renviron file via `renviron_load()`. This can be useful
#'        for testing or when working with a modified set of environment variables that has not been
#'        saved back to the file.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when
#'        loading environment variables. This is used only when `.renviron` is `NULL`. Valid values
#'        are "user" and "project". The function searches in the order provided. The default order
#'        is `c("project", "user")`.
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
renviron_get <- function(key, .renviron = NULL, scope = c("project", "user")) {
  if (is.null(.renviron)) {
    env <- renviron_load(scope)  # Load environment variables if not provided
  } else {
    env <- .renviron  # Use the provided list of environment variables
  }
  return(env[[key]])  # Retrieve the value for the specified key
}
