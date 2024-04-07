#' List and Mask Environment Variables
#'
#' This function lists all environment variables currently set in the .Renviron file, considering
#' both user and project scopes as defined by the `scope` argument, or in a provided named list of
#' environment variables, masking their values for security purposes. This provides a quick overview
#' of the variables, which can be useful for debugging or auditing without exposing sensitive information.
#'
#' @param .renviron An optional named list of environment variables to list. If not provided,
#'        the function will load the variables from the .Renviron file using `renviron_load()`
#'        with the specified scope and mask their values.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when
#'        loading environment variables. This is used only when `.renviron` is `NULL`. Valid values
#'        are "user" and "project". The function searches in the order provided. The default order
#'        is `c("project", "user")`.
#'
#' @return A named list of all environment variables with their values masked. For example,
#'         all values might be replaced with "****" to hide sensitive information. If called without
#'         the .renviron argument, it returns the list of variables from the .Renviron file within the
#'         specified scope with masked values.
#'
#' @examples
#' \dontrun{
#' # List and mask all environment variables from the .Renviron file within the specified scope
#' renviron_list()
#'
#' # List and mask variables from a provided named list
#' custom_env <- list(API_KEY = "12345", SECRET = "s3cr3t")
#' renviron_list(.renviron = custom_env)
#'}
#'
#' @export
renviron_list <- function(.renviron = NULL, scope = c("project", "user")) {
  if (is.null(.renviron)) {
    env <- renviron_load(scope)  # Cargar las variables de entorno del archivo .Renviron
  } else {
    env <- .renviron  # Usar la lista de variables de entorno proporcionada
  }

  # Enmascarar los valores de las variables de entorno
  env_masked <- sapply(env, function(x) "****")

  # Retornar la lista de variables de entorno con valores enmascarados
  return(env_masked)
}
