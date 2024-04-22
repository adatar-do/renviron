#' Remove an environment variable from the environment file and system
#'
#' This function removes a specified environment variable from the .Renviron file and the system environment.
#' By default, the change is saved back to the .Renviron file (`in_place = TRUE`), but the function can also
#' operate without saving (`in_place = FALSE`), which allows for temporary modification of environment variables
#' for testing or other purposes. It is designed to handle both user and project scopes effectively when no
#' custom list is provided.
#'
#' @param key A character string specifying the name of the environment variable to remove.
#' @param .renviron An optional named list of environment variables from which to remove the specified variable.
#'        If provided, the function modifies this list instead of automatically loading the .Renviron file.
#'        This can be particularly useful for testing or handling temporary environment changes.
#' @param in_place A logical flag indicating whether to save the changes back to the .Renviron
#'        file (`TRUE`) or just modify the environment variables temporarily (`FALSE`). The default is `TRUE`.
#'        When `FALSE`, changes are made only to the runtime environment and the provided list, without
#'        affecting the .Renviron file.
#' @param ... Additional arguments that are passed to the `renviron_save()` function if `in_place = TRUE`.
#'        This can include:
#'        - `scope`: A character vector specifying the scope(s) to search for the .Renviron file when loading
#'          environment variables. Valid values are "user" and "project", with "project" given priority if not specified.
#'        - `.file`: Specifies the filename to be considered as the environment file within the scope. Default is ".Renviron".
#'        - `confirm`: A logical flag indicating whether to confirm changes before saving the .Renviron file.
#'          Useful for preventing accidental modifications.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment
#'         variables after saving it to the .Renviron file and removes the variable from the system environment.
#'         If `in_place` is `FALSE`, it returns the modified list without saving, allowing further
#'         manipulation or inspection, but still removes the variable from the system environment.
#'
#' @examples
#' \dontrun{
#' # Permanently remove the CENSUS_API_KEY variable from both the .Renviron file and system environment
#' renviron_delete("CENSUS_API_KEY")
#'
#' # Temporarily remove the OBSOLETE_VAR from the current environment settings 
#' without affecting the .Renviron file
#' env_list <- renviron_load() # Load current environment variables
#' modified_env <- renviron_delete("OBSOLETE_VAR", .renviron = env_list, in_place = FALSE)
#' print(modified_env) # OBSOLETE_VAR will not be part of this list
#' }
#'
#' @export
renviron_delete <- function(key, .renviron = NULL, in_place = FALSE, ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(...) # Load environment variables if not provided
  } else {
    env <- .renviron # Use the provided list of environment variables
  }

  env[[key]] <- NULL # Remove the specified key
  Sys.unsetenv(key) # Remove the variable from the system environment

  if (in_place) {
    renviron_save(env, ...) # Save changes back to the .Renviron file
  }

  invisible(env) # Return modified environment invisibly
}
