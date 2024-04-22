#' Retrieve the path to the .Renviron file
#'
#' This function determines the path to a specified environment file (by default, .Renviron) by
#' considering both user and project scopes, utilizing an internal approach inspired by `usethis:::scoped_path_r`.
#' It prioritizes the project-specific file if present; otherwise, it falls back to the user-level file.
#' The function allows specifying the desired scope to directly target either the user-level or
#' project-level file. Additionally, a specific filename can be specified, allowing for flexible file management.
#'
#' @param scope A character string or vector specifying the scope to search for the environment file.
#'        Valid values are "user" and "project". If both are provided, the function will search
#'        in the order provided. The default order is c("project", "user").
#'        The "user" scope refers to the user's home directory, while the "project" scope
#'        refers to the current project directory.
#' @param .file The name of the environment file to search for within the specified scope(s).
#'        The default is '.Renviron'. This allows the function to be used to find other environment
#'        files as needed.
#' @param ... Additional parameters passed to the internal path finding function.
#'
#' @return A character string representing the path to the specified environment file within the
#'         chosen scope. If the file exists in the 'project' scope and "project" is included in the
#'         scope parameter, that path will be returned; otherwise, it will return the path to the
#'         user-level file. If no file is found, the function will return NULL.
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
#' # To search for a different file first in the user scope, then in the project scope:
#' custom_file_path <- renviron_path(c("user", "project"), .file = ".myenv")
#' print(custom_file_path)
#' }
#'
#' @export
renviron_path <- function(scope = c("project", "user"), .file = '.Renviron', ...) {
  scoped_path_r(scope, .file, envvar = "R_ENVIRON_USER")
}
