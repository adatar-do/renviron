#' Retrieve the Path to the .Renviron File
#'
#' This function determines the path to the .Renviron file by considering both user and project scopes,
#' utilizing an internal approach inspired by `usethis:::scoped_path_r`. It prioritizes the project-specific
#' .Renviron file if present; otherwise, it falls back to the user-level .Renviron. The function allows
#' specifying the desired scope to directly target either the user-level or project-level .Renviron file.
#'
#' @param scope A character string or vector specifying the scope to search for the .Renviron file.
#'        Valid values are "user" and "project". If both are provided, the function will search
#'        in the order provided. The default order is c("project", "user").
#'        The "user" scope refers to the user's home directory, while the "project" scope
#'        refers to the current project directory.
#'
#' @return A character string representing the path to the .Renviron file within the specified scope.
#'         The function returns the path to the project-level .Renviron file if it exists and "project"
#'         is included in the scope; otherwise, it returns the path to the user-level .Renviron.
#'
#' @examples
#' \dontrun{
#' # To get the path to the user-level .Renviron file:
#' user_env_path <- renviron_path("user")
#' print(user_env_path)
#'
#' # To get the path to the project-level .Renviron file, if it exists:
#' project_env_path <- renviron_path("project")
#' print(project_env_path)
#'
#' # To search first in the user scope, then in the project scope:
#' env_path <- renviron_path(c("user", "project"))
#' print(env_path)
#' }
#'
#' @export
renviron_path <- function(scope = c("project", "user")) {
  scoped_path_r(scope, ".Renviron", envvar = "R_ENVIRON_USER")
}
