% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/usethis.R
\name{scoped_path_r}
\alias{scoped_path_r}
\title{Determine Scoped Path for R Environments}
\usage{
scoped_path_r(scope = c("user", "project"), ..., envvar = NULL)
}
\arguments{
\item{scope}{A character string specifying the scope of the path.
Options are "user" for user-level configuration, or "project" for project-level.}

\item{...}{Additional arguments passed to \code{path}.}

\item{envvar}{An optional environment variable that can specify a path.}
}
\value{
A string representing the path scoped as specified.
}
\description{
This function is a utility to find paths scoped to the user or the current project.
It is based on the internal function \code{scoped_path_r} from the \code{usethis} package.
It has been adapted for use here with proper attribution.
}
\details{
This function is particularly useful for managing paths in user or project
specific configurations, such as .Renviron files.
}
\examples{
\dontrun{
# Get the path to the user-level R configuration
scoped_path_r("user")

# Get the path to the current project's root directory
scoped_path_r("project")
}

}
\references{
Function adapted from \code{usethis:::scoped_path_r} for demonstration purposes.
usethis package: \url{https://usethis.r-lib.org/}
}
