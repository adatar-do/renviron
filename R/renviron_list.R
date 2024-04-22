#' List and mask environment variables
#'
#' This function provides a secure way to view all environment variables from the .Renviron file
#' or a provided list, with their values masked for security purposes. It can operate over both
#' user and project scopes as defined by the `scope` argument when loading from the .Renviron file.
#' This feature is useful for debugging or auditing without compromising sensitive information by
#' exposing actual values of the variables.
#'
#' @param .renviron An optional named list of environment variables that should be listed. If not
#'        provided, the function will load the variables from the .Renviron file using `renviron_load()`
#'        and mask their values according to the specified scope.
#' @param ... Additional arguments that are passed to the `renviron_load()` function:
#'        - `scope`: A character vector specifying the scope(s) to search for the .Renviron file.
#'          Valid options are "user" and "project", with "project" typically having precedence unless
#'          otherwise specified. This determines which .Renviron file the variables are loaded from
#'          if `.renviron` is not provided. The default is `c("project", "user")`.
#'        - `.file`: Specifies the filename to be considered as the environment file within the
#'          specified scope. Default is ".Renviron".
#'
#' @return A named list of all environment variables with their values masked as "*****".
#'         This list includes all variables found in the specified scope if `.renviron` is not provided,
#'         or from the provided list otherwise. This method ensures that no sensitive data is displayed,
#'         while still allowing users to understand which variables are set.
#'
#' @examples
#' \dontrun{
#' # List and mask all environment variables from the .Renviron file within the default scope
#' renviron_list()
#'
#' # Directly list and mask variables from a custom provided named list
#' custom_env <- list(API_KEY = "12345", SECRET = "s3cr3t")
#' masked_env <- renviron_list(.renviron = custom_env)
#' print(masked_env)
#'}
#'
#' @export
renviron_list <- function(.renviron = NULL, ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(...)  # Cargar las variables de entorno del archivo .Renviron
  } else {
    env <- .renviron  # Usar la lista de variables de entorno proporcionada
  }

  # Enmascarar los valores de las variables de entorno
  env_masked <- sapply(env, function(x) "*****")

  # Retornar la lista de variables de entorno con valores enmascarados
  return(env_masked)
}
