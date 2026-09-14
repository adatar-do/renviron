#' Comprobar si una variable está definida
#'
#' Comprueba la presencia de la clave, incluso cuando su valor es vacío. No modifica la sesión.
#' @param key Nombre de una variable.
#' @param .renviron Lista o vector nombrado; `NULL` lee el archivo.
#' @param ... Argumentos de [renviron_read()].
#' @return `TRUE` o `FALSE`.
#' @examples
#' renviron_exists("RNV_EXAMPLE", .renviron = list(RNV_EXAMPLE = ""))
#' @export
renviron_exists <- function(key, .renviron = NULL, ...) {
  rv_keys(key, scalar = TRUE)
  values <- if (is.null(.renviron)) renviron_read(...) else rv_values(.renviron)
  !is.null(rv_lookup(key, values))
}
