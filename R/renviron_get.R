#' Retrieve a Specific Environment Variable from the .Renviron File
#'
#' This function fetches the value of a specified environment variable from the .Renviron file.
#' It relies on `renviron_load()` to load the environment variables into a named list, from which
#' the value of the specified key is retrieved. If the `.renviron` argument is provided, it uses
#' this list directly, bypassing the need to load from the file.
#'
#' @param key A character string specifying the name of the environment variable to retrieve.
#' @param .renviron An optional named list of environment variables. If provided, the function will
#'        use this list instead of loading the .Renviron file via `renviron_load()`. This can be useful
#'        for testing or when working with a modified set of environment variables that has not been saved back to the file.
#'
#' @return The value of the environment variable corresponding to `key`, if it exists.
#'         Returns `NULL` if the key does not exist in the list.
#'
#' @examples
#' \dontrun{
#' # Assuming the .Renviron file contains:
#' # CENSUS_API_KEY='12345'
#'
#' # Retrieve the CENSUS_API_KEY value
#' api_key <- renviron_get("CENSUS_API_KEY")
#' print(api_key)
#'}
#'
#' @export
renviron_get <- function(key, .renviron = NULL) {
  if (is.null(.renviron)) {
    env <- renviron_load()  # Load environment variables if not provided
  } else {
    env <- .renviron  # Use the provided list of environment variables
  }
  return(env[[key]])  # Retrieve the value for the specified key
}
