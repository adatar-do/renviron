#' Agregar o actualizar una variable
#'
#' Actualiza la clave seleccionada en la sesión. Si se guarda, primero escribe
#' el archivo; una cancelación o fallo de escritura deja la sesión intacta.
#'
#' @param key Nombre de una variable.
#' @param value Un valor de caracteres, sin NA ni saltos de línea.
#' @param .renviron Lista o vector nombrado; `NULL` usa el archivo.
#' @param in_place Guardar también el archivo; el valor predeterminado es `FALSE`.
#' @param ... Argumentos de [renviron_path()].
#' @param confirm Confirmación interactiva del guardado; para scripts use `FALSE`.
#' @return Lista modificada, invisiblemente; la lista original si se cancela.
#' @details Sin `.renviron`, el guardado modifica solo las líneas de la clave;
#'   conserva comentarios, líneas vacías y expresiones de las demás variables.
#'   Elimina duplicados de la clave editada. Los finales de línea se normalizan
#'   a LF y se escribe UTF-8. Si proporciona `.renviron`, el guardado reemplaza
#'   todo el archivo con esa lista modificada. No recalcula otras variables
#'   de la sesión que dependan de la clave; use [renviron_load()] para ello.
#' @examples
#' previous <- Sys.getenv("RNV_ADD_DEMO", unset = NA_character_)
#' values <- renviron_add("RNV_ADD_DEMO", "sample", .renviron = list())
#' if (is.na(previous)) Sys.unsetenv("RNV_ADD_DEMO") else
#'   Sys.setenv(RNV_ADD_DEMO = previous)
#' @export
renviron_add <- function(key, value, .renviron = NULL, in_place = FALSE, ...,
                         confirm = TRUE) {
  rv_keys(key, scalar = TRUE); rv_scalar(value, "value", empty = TRUE)
  rv_flag(in_place, "in_place"); rv_flag(confirm, "confirm")
  rv_edit(key, value, .renviron, in_place, confirm, ...)
}

rv_edit <- function(key, value, supplied, in_place, confirm, ...) {
  from_file <- is.null(supplied)
  path <- NULL; document <- NULL
  if (from_file || in_place) {
    path <- renviron_path(...)
    document <- rv_document(path)
  }
  original <- if (from_file) rv_parse(document) else rv_values(supplied)
  values <- original[rv_key_id(names(original)) != rv_key_id(key)]
  if (!is.null(value)) values[[key]] <- value
  if (in_place) {
    if (from_file) {
      matches <- which(!is.na(document$keys) & rv_key_id(document$keys) == rv_key_id(key))
      replacement <- if (is.null(value)) character() else rv_lines(stats::setNames(list(value), key))
      lines <- document$lines
      if (length(matches)) {
        if (length(replacement)) lines[[matches[[1L]]]] <- replacement
        remove <- if (length(replacement)) matches[-1L] else matches
        if (length(remove)) lines <- lines[-remove]
      } else lines <- c(lines, replacement)
    } else lines <- rv_lines(values)
    if (!rv_confirm(confirm)) return(invisible(original))
    rv_write(path, lines, document$bytes)
  }
  if (is.null(value)) Sys.unsetenv(key) else rv_set(stats::setNames(list(value), key))
  invisible(values)
}
