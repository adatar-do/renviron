% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/renviron_add.R
\name{renviron_add}
\alias{renviron_add}
\title{Add or update an environment variable in the environment file}
\usage{
renviron_add(key, value, .renviron = NULL, in_place = FALSE, ...)
}
\arguments{
\item{key}{A character string specifying the name of the environment variable to add or update.}

\item{value}{The new value for the environment variable, provided as a character string.}

\item{.renviron}{An optional named list of environment variables to modify instead of loading
the environment file using \code{renviron_load()}. This can be useful for testing or batch processing.}

\item{in_place}{A logical flag indicating whether to save the changes back to the environment
file (\code{TRUE}) or to return the modified list without saving (\code{FALSE}). Default is \code{FALSE}.
When \code{FALSE}, the function allows for controlled manipulation of variables without
permanently affecting the environment file.}

\item{...}{Additional arguments:
- \code{scope}: Specifies the scope(s) to search for the environment file when loading variables.
Valid values are "user" and "project", searched in the provided order. Default is \code{c("user", "project")}.
- \code{.file}: Specifies the filename to be considered as the environment file within the scope. Default is ".Renviron".
- \code{confirm}: Indicates whether to confirm changes before saving the environment file. Default is \code{TRUE}.}
}
\value{
If \code{in_place} is \code{TRUE}, the function invisibly returns the modified list of environment variables
after saving it to the environment file. If \code{in_place} is \code{FALSE}, it returns the modified list without saving,
allowing further manipulation or inspection. The current R session's environment reflects the updated values.
}
\description{
This function adds a new environment variable or updates the value of an existing variable
within the specified environment file (.Renviron by default), considering both user and project scopes.
It offers the flexibility to either save the changes back to the environment file
or to manipulate the variables in a more controlled manner by not saving (\code{in_place = FALSE}).
Changes are immediately updated in the current R session's environment, regardless of the \code{in_place} setting.
}
\examples{
\dontrun{
# Add or update the CENSUS_API_KEY variable in the environment file and save it
renviron_add("CENSUS_API_KEY", "new_key_value", in_place = TRUE)

# Add or update the variable in a provided list without saving
env_list <- renviron_load()  # Load current environment variables
modified_env <- renviron_add("NEW_VAR", "some_value", .renviron = env_list, in_place = FALSE)
print(modified_env$NEW_VAR)  # Output the value of NEW_VAR
}

}
