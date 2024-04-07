#' Remove an Environment Variable
#'
#' This function removes a specified environment variable from the .Renviron file or a provided
#' list of environment variables. By default, the change is saved back to the .Renviron file (`in_place = TRUE`),
#' but the function can also return a modified list without saving (`in_place = FALSE`).
#'
#' @param key A character string specifying the name of the environment variable to remove.
#' @param .renviron An optional named list of environment variables from which to remove the variable.
#'        If provided, the function will modify this list instead of the default .Renviron file. This
#'        can be useful for testing or when working with a temporary set of environment variables.
#' @param in_place A logical flag indicating whether to save the changes back to the .Renviron
#'        file (`TRUE`) or to return the modified list without saving (`FALSE`). Default is `TRUE`.
#'
#' @return If `in_place` is `TRUE`, the function invisibly returns the modified list of environment
#'         variables after saving it to the .Renviron file. If `in_place` is `FALSE`, it returns the modified
#'         list without saving, allowing further manipulation or inspection.
#'
#' @examples
#' \dontrun{
#' # Remove the CENSUS_API_KEY variable from the .Renviron file
#' renviron_delete("CENSUS_API_KEY")
#'
#' # Remove the variable from a provided list without saving
#' env_list <- renviron_load()  # Load current environment variables
#' modified_env <- renviron_delete("OBSOLETE_VAR", .renviron = env_list, in_place = FALSE)
#' print(modified_env)
#'}
#'
#' @export
renviron_delete <- function(key, .renviron = NULL, in_place = TRUE) {
  if (is.null(.renviron)) {
    env <- renviron_load()  # Load environment variables if not provided
  } else {
    env <- .renviron  # Use the provided list of environment variables
  }

  env[[key]] <- NULL  # Remove the specified key

  if (in_place) {
    renviron_save(env)  # Save changes back to the .Renviron file
    invisible(env)  # Return modified environment invisibly
  } else {
    return(env)  # Return modified environment without saving
  }
}
