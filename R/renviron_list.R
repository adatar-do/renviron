#' List Environment Variables
#'
#' This function lists all environment variables currently set in the .Renviron file or
#' in a provided named list of environment variables. It provides a quick overview of
#' the variables and their values, which can be useful for debugging or auditing.
#'
#' @param .renviron An optional named list of environment variables to list. If not provided,
#'        the function will load the variables from the .Renviron file using `renviron_load()`.
#'
#' @return A named list of all environment variables and their values. If called without
#'         the .renviron argument, it returns the list of variables from the .Renviron file.
#'
#' @examples
#' \dontrun{
#' # List all environment variables from the .Renviron file
#' env_vars <- renviron_list()
#' print(env_vars)
#'
#' # List variables from a provided named list
#' custom_env <- list(API_KEY = "12345", SECRET = "s3cr3t")
#' print(renviron_list(.renviron = custom_env))
#'}
#'
#' @export
renviron_list <- function(.renviron = NULL) {
  if (is.null(.renviron)) {
    env <- renviron_load()  # Load environment variables from the .Renviron file
  } else {
    env <- .renviron  # Use the provided named list of environment variables
  }

  return(env)  # Return the named list of environment variables
}
