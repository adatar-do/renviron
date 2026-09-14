#' Retirar de la sesión las claves seleccionadas del archivo
#'
#' Lee sin cargar variables y elimina de la sesión solo las claves resultantes.
#' No modifica el archivo ni otras variables del sistema.
#' @param ... Argumentos de [renviron_read()], incluyendo `.vars` para filtrar.
#' @return `NULL`, invisiblemente.
#' @examples
#' path <- tempfile()
#' writeLines(character(), path)
#' renviron_unset_all(.file = path)
#' unlink(path)
#' @export
renviron_unset_all <- function(...) {
  values <- renviron_read(...)
  if (length(values)) Sys.unsetenv(names(values))
  invisible(NULL)
}
