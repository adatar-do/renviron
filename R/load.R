#' Load Environment Variables from the .Renviron File
#'
#' This function reads the .Renviron file determined by `renviron_path()`, which considers
#' both user and project scopes. It converts the variables defined within the file into a
#' named list in R. Variables should be in the `KEY=VALUE` format, where `KEY` becomes
#' the list name, and `VALUE` is the corresponding list value. Outer quotes around the value
#' are optionally removed.
#'
#' @return A named list where each element corresponds to an environment variable loaded from
#'         the .Renviron file. The list's names are the environment variable names, and the
#'         values are the corresponding variable values, with outer quotes removed if present.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming the .Renviron file contains:
#' # CENSUS_API_KEY='12345'
#' # GITHUB_PAT='abcde'
#'
#' # Load environment variables from the .Renviron file
#' environment <- renviron_load()
#'
#' # Access a specific variable
#' print(environment$CENSUS_API_KEY)
#'}
#'
renviron_load <- function(){

  file_path <- renviron_path()

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


  return(lista_env_named)
}
