#' Cargar variables en la sesión actual
#'
#' Lee y valida el archivo completo antes de modificar la sesión. Solo establece
#' las variables seleccionadas; las demás conservan su valor actual.
#'
#' @inheritParams renviron_read
#' @return Lista de variables cargadas, devuelta invisiblemente.
#' @examples
#' path <- tempfile()
#' writeLines("RNV_LOAD_DEMO='sample'", path)
#' previous <- Sys.getenv("RNV_LOAD_DEMO", unset = NA_character_)
#' values <- renviron_load(.file = path, .vars = "RNV_LOAD_DEMO")
#' if (is.na(previous)) Sys.unsetenv("RNV_LOAD_DEMO") else
#'   Sys.setenv(RNV_LOAD_DEMO = previous)
#' unlink(path)
#' @export
renviron_load <- function(scope = c("user", "project"), .file = ".Renviron",
                          .vars = NULL, verbosity = 1, ...) {
  values <- renviron_read(scope, .file, .vars, verbosity, ...)
  rv_set(values)
  invisible(values)
}
