#' Save Environment Variables to the .Renviron File
#'
#' This function takes a named list of environment variables and saves them to the .Renviron file,
#' as determined by `renviron_path()`. If `confirm` is TRUE, the function will ask for user confirmation
#' before overwriting the file. This is useful for programmatically updating or setting environment
#' variables that need to persist across R sessions.
#'
#' @param env A named list where each name is an environment variable key and each value is
#'        the corresponding value for that key. The function expects the list values to be character strings.
#' @param confirm Logical; if TRUE, the function will ask for user confirmation before overwriting
#'        the .Renviron file. Default is FALSE for backward compatibility and non-interactive use cases.
#'
#' @return None. This function performs a file write operation and does not return any value.
#'
#' @examples
#' \dontrun{
#' # Assuming you want to set or update environment variables
#' new_env <- list(CENSUS_API_KEY = "12345", GITHUB_PAT = "abcde")
#'
#' # Save these variables to the .Renviron file, asking for confirmation
#' renviron_save(new_env, confirm = TRUE)
#'}
#'
#' @export
renviron_save <- function(env, confirm = TRUE){
  file_path <- renviron_path()

  if (confirm) {
    cat("You are about to overwrite the .Renviron file at:", file_path, "\n")
    answer <- readline(prompt = "Are you sure you want to proceed? (yes/no): ")
    if (tolower(answer) != "yes") {
      cat("Operation cancelled by user.\n")
      return(invisible())
    }
  }

  # Convert the named list back to a vector
  v <- sapply(names(env), function(k) {
    paste(k, "=", "'", env[[k]], "'", sep="")
  })

  readr::write_lines(v, file_path)
}
