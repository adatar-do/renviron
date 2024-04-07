#' Add or Update an Environment Variable in the .Renviron File
#'
#' This function adds a new environment variable or updates the value of an existing variable
#' within the .Renviron file, considering both user and project scopes as defined by the `scope` argument
#' in `renviron_load()`. It provides the flexibility to either save the changes back to the .Renviron file
#' or manipulate the variables in a more controlled manner by not saving (`in_place = FALSE`).
#'
#' @param key A character string specifying the name of the environment variable to add or update.
#' @param value The new value for the environment variable, provided as a character string.
#' @param .renviron An optional named list of environment variables to modify instead of loading
#'        the .Renviron file using `renviron_load()`. This can be particularly useful for testing or when
#'        managing variables in a batch process.
#' @param in_place A logical flag indicating whether to save the changes back to the .Renviron
#'        file (`TRUE`) or to return the modified list without saving (`FALSE`). Default is `TRUE`.
#'        When `FALSE`, the function allows for a more controlled manipulation of the variables without
#'        affecting the system environment or the .Renviron file.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when loading
#'        environment variables. This is used only when `.renviron` is `NULL`. Valid values are "user"
#'        and "project". The function searches in the order provided. The default order is `c("project", "user")`.
#' @param ... Additional arguments to be passed to `renviron_save()` if `in_place = TRUE`.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment
#'         variables after saving it to the .Renviron file. If `in_place` is `FALSE`, it returns the modified
#'         list without saving, allowing further manipulation or inspection.
#'
#' @examples
#' \dontrun{
#' # Add or update the CENSUS_API_KEY variable in the .Renviron file
#' renviron_add("CENSUS_API_KEY", "new_key_value")
#'
#' # Add or update the variable in a provided list without saving
#' env_list <- renviron_load()  # Load current environment variables
#' modified_env <- renviron_add("NEW_VAR", "some_value", .renviron = env_list, in_place = FALSE)
#' print(modified_env$NEW_VAR)
#' }
#'
#' @export
renviron_add <- function(key, value, .renviron = NULL, in_place = FALSE, scope = c('project', 'user'), ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(scope) # Load environment variables if not provided
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
