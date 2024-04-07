#' Retrieve the Path to the .Renviron File
#'
#' This function utilizes `usethis:::scoped_path_r` to determine the path to the .Renviron file
#' by considering both user and project scopes. The function prioritizes the project-specific
#' .Renviron file if present; otherwise, it falls back to the user-level .Renviron.
#'
#' The search order and precedence are determined by `usethis:::scoped_path_r`, which checks
#' the project directory followed by the user's home directory for the .Renviron file.
#'
#' @return A character string representing the path to the .Renviron file that should be loaded.
#'         If no file is found in either the project or user scope, the function may return `NULL`.
#'
#' @examples
#' \dontrun{
#' # To get the path to the currently active .Renviron file:
#' env_path <- renviron_path()
#' print(env_path)
#' }
#'
#' @export
renviron_path <- function(){
  scoped_path_r(c("user", "project"), ".Renviron", envvar = "R_ENVIRON_USER")
}
