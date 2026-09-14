#' Resolver el archivo de configuración
#'
#' Consulta los ámbitos en el orden indicado, sin fusionar archivos ni cambiar
#' el proyecto activo. `project` es el directorio de trabajo por defecto.
#'
#' @inheritParams renviron_read
#' @param project Directorio para el ámbito de proyecto; por defecto `getwd()`.
#' @param user Directorio para el ámbito de usuario; por defecto el hogar de R.
#' @return Ruta absoluta. Si no existe un archivo, devuelve la primera ruta
#'   candidata, utilizable para crear un archivo con [renviron_save()].
#' @details Una ruta absoluta en `.file` tiene prioridad sobre los ámbitos.
#'   `R_ENVIRON_USER` se respeta solo para el archivo predeterminado del ámbito
#'   `user` cuando no se especifica `user`. Un nombre personalizado no se redirige.
#'   El orden predeterminado sigue siendo usuario, proyecto; use
#'   `scope = c("project", "user")` para dar prioridad al proyecto.
#' @examples
#' renviron_path("project", project = tempdir())
#' @export
renviron_path <- function(scope = c("user", "project"), .file = ".Renviron",
                          verbosity = 1, ..., project = getwd(), user = path.expand("~")) {
  if (length(list(...))) stop("Unknown path arguments.", call. = FALSE)
  rv_scalar(.file, ".file")
  if (!is.numeric(verbosity) || length(verbosity) != 1L || is.na(verbosity) ||
      !verbosity %in% c(0, 1)) stop("verbosity must be 0 or 1.", call. = FALSE)
  if (!is.character(scope) || !length(scope) || anyNA(scope) ||
      any(!scope %in% c("user", "project")) || anyDuplicated(scope))
    stop("scope must contain unique user/project scopes in search order.", call. = FALSE)
  if (fs::is_absolute_path(path.expand(.file))) return(as.character(fs::path_abs(path.expand(.file))))
  rv_scalar(project, "project"); rv_scalar(user, "user")
  user_path <- file.path(user, .file)
  override <- Sys.getenv("R_ENVIRON_USER", unset = "")
  if (missing(user) && identical(.file, ".Renviron") && nzchar(override)) user_path <- path.expand(override)
  paths <- c(user = user_path, project = file.path(project, .file))[scope]
  found <- which(file.exists(paths))
  as.character(fs::path_abs(if (length(found)) paths[[found[[1L]]]] else paths[[1L]]))
}
