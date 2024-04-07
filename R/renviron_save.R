#' Save Environment Variables to the .Renviron File
#'
#' This function takes a named list of environment variables and saves them to the .Renviron file,
#' considering both user and project scopes as defined by the `scope` argument. The location of the
#' .Renviron file is determined by `renviron_path()`. If `confirm` is TRUE, the function will prompt
#' for user confirmation before overwriting the file. This safety mechanism is useful for programmatically
#' updating or setting environment variables that need to persist across R sessions, while helping to
#' prevent accidental overwrites.
#'
#' @param .Renviron A named list where each name is an environment variable key and each value is
#'        the corresponding value for that key. The function expects the list values to be character strings.
#' @param confirm Logical; if TRUE, the function will prompt for user confirmation before overwriting
#'        the .Renviron file. This is set to TRUE by default to avoid unintentional overwrites, but can
#'        be set to FALSE for automated scripts or non-interactive use cases.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when saving
#'        environment variables. Valid values are "user" and "project". The function will save to the
#'        .Renviron file in the specified scope, with "project" being the default if not specified.
#'
#' @return This function performs a file write operation and does not return any value. It operates
#'         invisibly, emphasizing its side effect of modifying the .Renviron file rather than producing
#'         output.
#'
#' @examples
#' \dontrun{
#' # Assuming you want to set or update environment variables
#' new_env <- list(CENSUS_API_KEY = "12345", GITHUB_PAT = "abcde")
#'
#' # Save these variables to the .Renviron file, with confirmation prompt
#' renviron_save(new_env, confirm = TRUE)
#'
#' # Save variables without confirmation (useful for scripts)
#' renviron_save(new_env, confirm = FALSE)
#'}
#'
#' @export
renviron_save <- function(.Renviron, confirm = TRUE, scope = c("project", "user")){
  file_path <- renviron_path(scope)

  if (confirm) {
    cat("You are about to overwrite the .Renviron file at:", file_path, "\n")
    answer <- readline(prompt = "Are you sure you want to proceed? (yes/no): ")
    if (tolower(answer) != "yes") {
      cat("Operation cancelled by user.\n")
      return(invisible())
    }
  }

  env <- .Renviron

  # Convert the named list back to a vector
  v <- sapply(names(env), function(k) {
    paste(k, "=", "'", env[[k]], "'", sep="")
  })

  readr::write_lines(v, file_path)
}
