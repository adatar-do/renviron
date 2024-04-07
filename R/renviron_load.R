#' Load and Set Environment Variables from the .Renviron File
#'
#' This function reads the .Renviron file, considering both user and project scopes as defined by the `scope` argument.
#' It loads the variables defined within the file into a named list and sets them in the system environment. Variables
#' should be in the `KEY=VALUE` format. Outer quotes around the value are optionally removed. To minimize the risk of
#' sensitive information exposure, the function can return the list of variables invisibly, or users can capture it
#' in a variable for more controlled access.
#'
#' In RStudio, the project-level .Renviron file is automatically loaded when a project is opened, making the
#' project scope variables readily available. However, this function is particularly useful for loading variables
#' from the user scope, where you might store global secrets or configurations that apply across multiple projects.
#' By explicitly specifying the `user` scope, you can ensure that these global settings are loaded even when
#' working within the context of a specific project in RStudio.
#'
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file.
#'        Valid values are "user" and "project". The function searches in the order provided.
#'        The default order is `c("project", "user")`. The "user" scope refers to the user's home
#'        directory, while the "project" scope refers to the current project directory.
#'
#' @return Invisibly returns a named list where each element corresponds to an environment
#'         variable loaded from the .Renviron file. This list is also set in the system environment.
#'         Users can optionally capture this list in a variable for more controlled access.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load environment variables from the .Renviron file and set them in the system environment
#' renviron_load()
#' Sys.getenv("CENSUS_API_KEY")
#'
#' # Alternatively, capture the list of environment variables for more controlled access
#' env_vars <- renviron_load()
#' print(env_vars$CENSUS_API_KEY)
#' }
renviron_load <- function(scope = c("project", "user")){

  file_path <- renviron_path(scope)

  if (!file.exists(file_path)) {
    cli::cli_alert_danger("The .Renviron file could not be found in the specified scope(s).")
    return(invisible(NULL))
  }

  file <- as.list(readr::read_lines(file_path))

  # Convertir el vector en una lista con claves y valores
  lista_env <- lapply(file, function(x) {
    # Dividir cada elemento por '='
    parts <- strsplit(x, "=")[[1]]
    key <- parts[1]
    value <- parts[2]

    # Eliminar posibles comillas de los valores
    value <- gsub("'", "", value)

    # Asignar el valor a la clave en la lista
    list(key = key, value = value)
  })

  # Para hacer la lista más accesible, podrías querer convertirla en una lista con nombre
  lista_env_named <- stats::setNames(lapply(lista_env, `[[`, "value"), sapply(lista_env, `[[`, "key"))

  # Agregar la lista de variables de entorno al entorno de trabajo
  do.call(Sys.setenv, lista_env_named)


  return(invisible(lista_env_named))
}
