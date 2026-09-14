#' Leer variables sin modificar la sesión
#'
#' Interpreta un archivo con el lector nativo de R en un proceso aislado.
#' Las referencias a variables se resuelven en orden, con el entorno heredado
#' de la sesión. No modifica variables ni ejecuta perfiles de inicio.
#'
#' @param scope Ámbitos que se consultan en orden: `"user"` y `"project"`.
#'   Se usa el primer archivo existente; si ninguno existe, la primera ruta.
#' @param .file Nombre relativo al ámbito o ruta absoluta explícita.
#' @param .vars Nombres que se devuelven; `NULL` selecciona todos. Las referencias
#'   se resuelven con el archivo completo antes de filtrar.
#' @param verbosity `0` suprime el aviso de archivo ausente; `1` lo muestra.
#' @param ... Argumentos de [renviron_path()], como `project` y `user`.
#' @return Lista nombrada, devuelta invisiblemente. Un archivo vacío o ausente
#'   produce `list()`. Las asignaciones inválidas producen un error sin valores.
#' @details Admite comillas, `=`, comentarios de línea, referencias `${VAR}`,
#'   valores predeterminados de R y el prefijo opcional `export`. Un `KEY=` sin
#'   comillas se ignora, como en R; `KEY=''` expresa un valor vacío. Un `#` al
#'   final de una asignación forma parte del valor. No ejecuta sintaxis de shell.
#'   Cada lectura inicia un proceso de R y requiere que Rscript esté disponible.
#'   La lista conserva las claves declaradas aunque su valor resulte vacío.
#'   Windows representa algunas variables vacías como ausentes en el entorno
#'   del proceso; la lista mantiene `""`. Una expansión vacía sin comillas puede
#'   ser ignorada por R y conservar un valor previamente heredado.
#' @examples
#' path <- tempfile()
#' writeLines(c("RNV_DEMO='one=two'", "RNV_COPY='${RNV_DEMO}'"), path)
#' values <- renviron_read(.file = path)
#' stopifnot(identical(values$RNV_COPY, "one=two"))
#' unlink(path)
#' @export
renviron_read <- function(scope = c("user", "project"), .file = ".Renviron",
                          .vars = NULL, verbosity = 1, ...) {
  path <- renviron_path(scope, .file, verbosity, ...)
  document <- rv_document(path)
  if (is.null(document$bytes) && verbosity > 0L) message("Environment file not found.")
  if (!is.null(.vars)) rv_keys(.vars)
  invisible(rv_select(rv_parse(document), .vars))
}
