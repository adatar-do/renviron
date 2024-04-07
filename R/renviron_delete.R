#' Remove an Environment Variable
#'
#' This function removes a specified environment variable from the .Renviron file or a provided
#' list of environment variables. It also attempts to remove the variable from the system environment.
#' By default, the change is saved back to the .Renviron file (`in_place = TRUE`), but the function
#' can also return a modified list without saving (`in_place = FALSE`). The function considers both
#' user and project scopes as defined by the `scope` argument when loading the .Renviron file if no
#' list is provided.
#'
#' @param key A character string specifying the name of the environment variable to remove.
#' @param .renviron An optional named list of environment variables from which to remove the variable.
#'        If provided, the function will modify this list instead of the default .Renviron file. This
#'        can be useful for testing or when working with a temporary set of environment variables.
#' @param in_place A logical flag indicating whether to save the changes back to the .Renviron
#'        file (`TRUE`) or to return the modified list without saving (`FALSE`). Default is `TRUE`.
#' @param scope A character vector specifying the scope(s) to search for the .Renviron file when loading
#'        environment variables. This is used only when `.renviron` is `NULL`. Valid values are "user"
#'        and "project". The function searches in the order provided. The default order is `c("project", "user")`.
#' @param ... Additional arguments to be passed to `renviron_save()` if `in_place = TRUE`.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment
#'         variables after saving it to the .Renviron file and removes the variable from the system environment.
#'         If `in_place` is `FALSE`, it returns the modified list without saving, allowing further
#'         manipulation or inspection, but still removes the variable from the system environment.
#'
#' @examples
#' \dontrun{
#' # Remove the CENSUS_API_KEY variable from the .Renviron file and the system environment
#' renviron_delete("CENSUS_API_KEY")
#'
#' # Remove the variable from a provided list without saving and from the system environment
#' env_list <- renviron_load() # Load current environment variables
#' modified_env <- renviron_delete("OBSOLETE_VAR", .renviron = env_list, in_place = FALSE)
#' print(modified_env)
#' }
#'
#' @export
renviron_delete <- function(key, .renviron = NULL, in_place = FALSE, scope = c("project", "user"), ...) {
  if (is.null(.renviron)) {
    env <- renviron_load(scope) # Load environment variables if not provided
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
