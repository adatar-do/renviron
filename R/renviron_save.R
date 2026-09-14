#' Guardar un conjunto completo de variables
#'
#' Reemplaza el contenido del archivo con valores literales compatibles con R.
#' Valida todos los datos antes de escribir. La sustitución usa un archivo
#' temporal en el mismo directorio y conserva los permisos de un archivo existente.
#'
#' @param .Renviron Lista nombrada o vector de caracteres nombrado, con valores
#'   escalares sin NA ni saltos de línea. `list()` crea un archivo vacío.
#' @param confirm Solicitar confirmación interactiva. Para scripts use `FALSE`.
#' @param ... Argumentos de [renviron_path()].
#' @return Ruta guardada, invisiblemente; `NULL` si se cancela. No cambia la sesión.
#' @details Esta función reemplaza todo el documento, incluidos comentarios.
#'   Para editar una sola clave conservando otras líneas use [renviron_add()] o
#'   [renviron_delete()] con `in_place = TRUE` y sin proporcionar `.renviron`.
#'   Los valores `${...}` se guardan como texto literal. No se admiten enlaces
#'   simbólicos como destino, valores multilínea ni líneas codificadas de más
#'   de 99900 bytes. El directorio debe existir. Los nuevos archivos usan modo
#'   0600 donde el sistema lo soporta; en Windows rigen también las ACL del directorio.
#' @examples
#' path <- tempfile()
#' renviron_save(list(RNV_SAVE_DEMO = "one=two", RNV_EMPTY = ""),
#'               .file = path, confirm = FALSE)
#' renviron_list(.file = path)
#' unlink(path)
#' @export
renviron_save <- function(.Renviron, confirm = TRUE, ...) {
  lines <- rv_lines(.Renviron)
  path <- renviron_path(...)
  expected <- rv_bytes(path)
  if (!rv_confirm(confirm)) return(invisible(NULL))
  rv_write(path, lines, expected)
}
