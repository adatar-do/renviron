#' Construir una ruta dentro de un ámbito
#'
#' Función de compatibilidad para resolver un único ámbito. Para buscar archivos
#' en varios ámbitos use [renviron_path()]. No cambia el proyecto activo.
#'
#' @param scope Un ámbito: `"user"` o `"project"`. El valor predeterminado usa user.
#' @param ... Componentes de la ruta.
#' @param envvar Nombre de una variable que puede reemplazar la ruta de usuario.
#' @param project Directorio de proyecto; por defecto `getwd()`.
#' @param user Directorio de usuario; por defecto el hogar de R.
#' @return Ruta absoluta.
#' @examples
#' scoped_path_r("project", "example.env", project = tempdir())
#' @export
scoped_path_r <- function(scope = c("user", "project"), ..., envvar = NULL,
                          project = getwd(), user = path.expand("~")) {
  scope <- match.arg(scope)
  if (!is.null(envvar)) {
    rv_keys(envvar, scalar = TRUE)
    override <- Sys.getenv(envvar, unset = "")
    if (scope == "user" && nzchar(override)) return(as.character(fs::path_abs(path.expand(override))))
  }
  root <- if (scope == "user") user else project
  rv_scalar(root, "root")
  components <- list(...)
  for (part in components) rv_scalar(part, "Path component")
  as.character(fs::path_abs(do.call(file.path, c(list(root), components))))
}
