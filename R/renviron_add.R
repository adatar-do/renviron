#' Add or Update an Environment Variable
#'
#' This function adds a new environment variable or updates the value of an existing variable
#' within the .Renviron file or a provided list of environment variables. By default, changes
#' are saved back to the .Renviron file (`in_place = TRUE`), but the function can also return a modified
#' list without saving (`in_place = FALSE`).
#'
#' @param key A character string specifying the name of the environment variable to add or update.
#' @param value The new value for the environment variable, provided as a character string.
#' @param .renviron An optional named list of environment variables to modify instead of loading
#'        the .Renviron file. This can be useful for testing or batch updates to environment variables.
#' @param in_place A logical flag indicating whether to save the changes back to the .Renviron
#'        file (`TRUE`) or to return the modified list without saving (`FALSE`). Default is `TRUE`.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment
#'         variables after saving it to the .Renviron file. If `in_place` is `FALSE`, it returns the modified
#'         list without saving. This allows for further manipulation or inspection of the modified variables.
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
#'}
#'
#' @export
renviron_add <- function(key, value, .renviron = NULL, in_place = TRUE) {
  if (is.null(.renviron)) {
    env <- renviron_load()  # Load environment variables if not provided
  } else {
    env <- .renviron  # Use the provided list of environment variables
  }

  env[[key]] <- value  # Add or update the specified key-value pair

  if (in_place) {
    renviron_save(env)  # Save changes back to the .Renviron file
    invisible(env)  # Return modified environment invisibly
  } else {
    return(env)  # Return modified environment without saving
  }
}
