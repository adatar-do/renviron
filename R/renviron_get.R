#' Consultar el valor de una variable
#'
#' Consulta exclusivamente el archivo o la lista indicada, sin cargar variables
#' ni recuperar valores ajenos del entorno de la sesión.
#' @param key Nombre de una variable.
#' @param .renviron Lista o vector nombrado; `NULL` lee el archivo.
#' @param ... Argumentos de [renviron_read()].
#' @return Valor de caracteres, incluyendo `""`; `NULL` si la clave no existe.
#' @examples
#' renviron_get("RNV_EXAMPLE", .renviron = list(RNV_EXAMPLE = ""))
#' @export
renviron_get <- function(key, .renviron = NULL, ...) {
  rv_keys(key, scalar = TRUE)
  values <- if (is.null(.renviron)) renviron_read(...) else rv_values(.renviron)
  rv_lookup(key, values)
}
