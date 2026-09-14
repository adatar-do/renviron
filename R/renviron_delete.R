#' Eliminar una variable de la sesión y, opcionalmente, del archivo
#'
#' Elimina únicamente la clave indicada. El comportamiento de edición,
#' conservación de líneas y cancelación es el de [renviron_add()].
#' @inheritParams renviron_add
#' @return Lista restante, invisiblemente; la original si se cancela.
#' @examples
#' previous <- Sys.getenv("RNV_DELETE_DEMO", unset = NA_character_)
#' values <- renviron_delete("RNV_DELETE_DEMO", .renviron = list())
#' if (!is.na(previous)) Sys.setenv(RNV_DELETE_DEMO = previous)
#' @export
renviron_delete <- function(key, .renviron = NULL, in_place = FALSE, ...,
                            confirm = TRUE) {
  rv_keys(key, scalar = TRUE); rv_flag(in_place, "in_place"); rv_flag(confirm, "confirm")
  rv_edit(key, NULL, .renviron, in_place, confirm, ...)
}
