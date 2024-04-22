#' Save environment variables to the environment file
#'
#' This function takes a named list of environment variables and saves them to the appropriate
#' .Renviron file based on the specified scope. The function prompts for user confirmation before
#' overwriting the file if `confirm` is set to TRUE, helping to prevent accidental data loss.
#' This feature is particularly useful for programmatically updating or setting environment variables
#' that need to persist across R sessions.
#'
#' @param .Renviron A named list where each name is an environment variable key and each value is
#'        the corresponding value for that key. The function expects the list values to be character strings.
#'        Example: `list(CENSUS_API_KEY = "12345", GITHUB_PAT = "abcde")`.
#' @param confirm Logical; if TRUE, the function prompts for user confirmation before overwriting
#'        the .Renviron file. This helps to prevent unintended overwrites. Default is TRUE.
#'        Set this to FALSE for automated scripts or non-interactive session where confirmation is not desired.
#' @param ... Additional arguments to configure the operation:
#'        - `scope`: A character vector specifying the scope(s) where the .Renviron file is located.
#'          Valid options are "user" for the user-level file or "project" for the project-level file.
#'          Default is "project". The function saves to the .Renviron file in the specified scope.
#'        - `.file`: Optionally specify a different filename to save the environment variables to.
#'          Default is ".Renviron".
#'
#' @return This function does not return a value and operates invisibly, with the primary side effect
#'         being the modification of the .Renviron file.
#'
#' @examples
#' \dontrun{
#' # Assume you want to set or update environment variables
#' new_env <- list(CENSUS_API_KEY = "12345", GITHUB_PAT = "abcde")
#'
#' # Save these variables to the .Renviron file, with confirmation
#' renviron_save(new_env, confirm = TRUE)
#'
#' # Automatically save variables without confirmation for automated scripts
#' renviron_save(new_env, confirm = FALSE)
#'}
#'
#' @export
renviron_save <- function(.Renviron, confirm = TRUE, ...){
  file_path <- renviron_path(...)

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
