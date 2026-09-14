#' Listar nombres con valores enmascarados
#'
#' Devuelve únicamente los nombres y una máscara constante. No carga variables
#' en la sesión. La máscara no informa la longitud ni el contenido del valor.
#' @param .renviron Lista o vector nombrado; `NULL` lee el archivo.
#' @param ... Argumentos de [renviron_read()].
#' @return Vector de caracteres nombrado con `"*****"` por variable;
#'   `character()` si no hay variables.
#' @examples
#' renviron_list(list(RNV_EXAMPLE = "demo", RNV_EMPTY = ""))
#' @export
renviron_list <- function(.renviron = NULL, ...) {
  values <- if (is.null(.renviron)) renviron_read(...) else rv_values(.renviron)
  if (!length(values)) return(character())
  stats::setNames(rep("*****", length(values)), names(values))
}
