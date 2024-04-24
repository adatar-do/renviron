#' Load Environment Variables from the .Renviron File
#'
#' This function reads the .Renviron file, considering both user and project scopes as defined by the `scope` argument.
#' It loads the variables defined within the file into a named list and sets them in the system environment. Only lines
#' that follow the pattern key='value' or key="value" (where quotes are optional and can be single or double) are processed.
#' Variables should be in the `KEY=VALUE` format, with optional outer quotes around the value. Lines that do not match
#' this format are ignored.
#'
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file.
#'        Valid values are "user" and "project". The function searches in the order provided.
#'        The default order is `c("project", "user")`. The "user" scope refers to the user's home
#'        directory, while the "project" scope refers to the current project directory.
#' @param .file Optional filename to search within the specified scope.
#' @param .vars Optional character vector specifying which variables to load; if NULL, all variables are loaded.
#' @param verbosity An integer specifying the level of verbosity in messages. Default is 1.
#' @param ... Additional arguments passed to other internal functions.
#'
#' @return A named list of environment variables set in the system environment, invisibly returned.
#'
#' @examples
#' \dontrun{
#' # Load and set environment variables from the .Renviron file
#' env_vars <- renviron_load()
#'
#' # Load and set specific environment variables from the .Renviron file
#' env_vars <- renviron_load(.vars = c("CENSUS_API_KEY", "GITHUB_PAT"))
#'
#' # Load and set environment variables from a custom file
#' env_vars <- renviron_load(.file = ".env")
#'
#' # Load and set environment variables from the user scope only
#' env_vars <- renviron_load(scope = "user")
#' }
#'
#' @export
renviron_load <- function(scope = c("project", "user"), .file = ".Renviron", .vars = NULL, verbosity = 1, ...) {
  file_path <- renviron_path(scope, .file, verbosity, ...)
  if (!file.exists(file_path)) {
    if (verbosity > 0) {
      cli::cli_alert_danger("The .Renviron file could not be found in the specified scope(s).")
    }
    return(invisible(NULL))
  }

  lines <- readr::read_lines(file_path)

  # Exclude empty lines and comments
  lines <- lines[!grepl("^\\s*$|^\\s*#", lines)]

  # Return NULL if no valid lines are found
  if (length(lines) == 0) {
    return(invisible(NULL))
  }

  pattern <- "^\\s*(export\\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\\s*=\\s*(['\"])?(.*?)(?:\\3)?\\s*$"
  valid_lines <- grep(pattern, lines, value = TRUE, perl = TRUE)
  parsed_lines <- gsub(pattern, "\\2=\\4", valid_lines, perl = TRUE)

  # Parsing lines into a named list
  lista_env <- stats::setNames(
    lapply(parsed_lines, function(x) gsub("^['\"]|['\"]$", "", strsplit(x, "=")[[1]][2])),
    sapply(parsed_lines, function(x) strsplit(x, "=")[[1]][1])
  )

  if (length(lista_env) == 0) {
    return(invisible(NULL))
  }

  # Setting environment variables safely
  if (!is.null(names(lista_env))) {
    lista_env <- as.list(lista_env)
    names(lista_env) <- sapply(names(lista_env), function(x) gsub("\\s+", "", x))
  } else {
    return(invisible(NULL))
  }

  if (!is.null(.vars)) {
    lista_env <- lista_env[names(lista_env) %in% .vars]
  }

  do.call(Sys.setenv, lista_env)
  invisible(lista_env)
}
