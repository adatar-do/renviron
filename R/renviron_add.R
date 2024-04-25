#' Add or update an environment variable in the environment file
#'
#' This function adds a new environment variable or updates the value of an existing variable
#' within the specified environment file (.Renviron by default), considering both user and project scopes.
#' It offers the flexibility to either save the changes back to the environment file
#' or to manipulate the variables in a more controlled manner by not saving (`in_place = FALSE`).
#' Changes are immediately updated in the current R session's environment, regardless of the `in_place` setting.
#'
#' @param key A character string specifying the name of the environment variable to add or update.
#' @param value The new value for the environment variable, provided as a character string.
#' @param .renviron An optional named list of environment variables to modify instead of loading
#'        the environment file using `renviron_load()`. This can be useful for testing or batch processing.
#' @param in_place A logical flag indicating whether to save the changes back to the environment
#'        file (`TRUE`) or to return the modified list without saving (`FALSE`). Default is `FALSE`.
#'        When `FALSE`, the function allows for controlled manipulation of variables without
#'        permanently affecting the environment file.
#' @param ... Additional arguments:
#'        - `scope`: Specifies the scope(s) to search for the environment file when loading variables.
#'          Valid values are "user" and "project", searched in the provided order. Default is `c("user", "project")`.
#'        - `.file`: Specifies the filename to be considered as the environment file within the scope. Default is ".Renviron".
#'        - `confirm`: Indicates whether to confirm changes before saving the environment file. Default is `TRUE`.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment variables
#'         after saving it to the environment file. If `in_place` is `FALSE`, it returns the modified list without saving,
#'         allowing further manipulation or inspection. The current R session's environment reflects the updated values.
#'
#' @examples
#' \dontrun{
#' # Add or update the CENSUS_API_KEY variable in the environment file and save it
#' renviron_add("CENSUS_API_KEY", "new_key_value", in_place = TRUE)
#'
#' # Add or update the variable in a provided list without saving
#' env_list <- renviron_load()  # Load current environment variables
#' modified_env <- renviron_add("NEW_VAR", "some_value", .renviron = env_list, in_place = FALSE)
#' print(modified_env$NEW_VAR)  # Output the value of NEW_VAR
#' }
#'
#' @export
renviron_add <- function(key, value, .renviron = NULL, in_place = FALSE, ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(...) # Load environment variables if not provided
  } else {
    env <- .renviron # Use the provided list of environment variables
  }

  env[[key]] <- value # Add or update the specified key-value pair
  do.call(Sys.setenv, env[key]) # Update the system environment

  if (in_place) {
    renviron_save(env, ...) # Save changes back to the .Renviron file
  }

  invisible(env) # Return modified environment without saving
}
